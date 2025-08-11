%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

typedef struct {
    char *name;
    double value;
} symbol;

#define MAX_SYMBOLS 100
symbol sym_table[MAX_SYMBOLS];
int sym_count = 0;

void add_symbol(const char *name, double value);
double get_symbol(const char *name);

int yylex(void);
void yyerror(const char *s);

%}

%union {
    double val;
    char *str;
}

%token <val> NUMBER
%token NEWLINE
%token SIN COS TAN LOG SQRT
%token SEC CSC COT
%token PI E
%token '='
%token <str> VARIABLE

%type <val> expr line

%left '+' '-'
%left '*' '/'
%right UMINUS
%right '^'

%%

input:
      /* empty */
    | input line
    ;

line:
      assignment NEWLINE    { printf("Variable assigned.\n"); }
    | expr NEWLINE          { printf("= %g\n", $1); }
    ;

assignment:
      VARIABLE '=' expr     { add_symbol($1, $3); }
    ;

expr:
      NUMBER                  { $$ = $1; }
    | VARIABLE                { $$ = get_symbol($1); }
    | PI                      { $$ = M_PI; }
    | E                       { $$ = M_E; }
    | expr '+' expr           { $$ = $1 + $3; }
    | expr '-' expr           { $$ = $1 - $3; }
    | expr '*' expr           { $$ = $1 * $3; }
    | expr '/' expr           {
                                  if ($3 == 0) {
                                      yyerror("Division by zero");
                                      YYABORT;
                                  } else {
                                      $$ = $1 / $3;
                                  }
                              }
    | expr '^' expr           { $$ = pow($1, $3); }
    | '-' expr  %prec UMINUS  { $$ = -$2; }
    | '(' expr ')'            { $$ = $2; }
    | SIN '^' NUMBER '(' expr ')' { $$ = pow(sin($5), $3); }
    | COS '^' NUMBER '(' expr ')' { $$ = pow(cos($5), $3); }
    | TAN '^' NUMBER '(' expr ')' { $$ = pow(tan($5), $3); }
    | SIN '(' expr ')'        { $$ = sin($3); }
    | COS '(' expr ')'        { $$ = cos($3); }
    | TAN '(' expr ')'        { $$ = tan($3); }
    | LOG '(' expr ')'        { $$ = log($3); }
    | SQRT '(' expr ')'       { $$ = sqrt($3); }
    | SEC '(' expr ')'        { $$ = 1.0 / cos($3); }
    | CSC '(' expr ')'        { $$ = 1.0 / sin($3); }
    | COT '(' expr ')'        { $$ = 1.0 / tan($3); }
    ;

%%

void add_symbol(const char *name, double value) {
    int i;
    for (i = 0; i < sym_count; i++) {
        if (strcmp(sym_table[i].name, name) == 0) {
            sym_table[i].value = value;
            return;
        }
    }
    if (sym_count < MAX_SYMBOLS) {
        sym_table[sym_count].name = strdup(name);
        sym_table[sym_count].value = value;
        sym_count++;
    } else {
        yyerror("Symbol table overflow");
    }
}

double get_symbol(const char *name) {
    int i;
    for (i = 0; i < sym_count; i++) {
        if (strcmp(sym_table[i].name, name) == 0) {
            return sym_table[i].value;
        }
    }
    yyerror("Undefined variable");
    return 0.0;
}

int main() {
    printf("Enter an expression (e.g :  x = 10, sin^2(pi/2)):\n");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}