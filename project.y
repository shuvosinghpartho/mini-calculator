%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define HISTORY_SIZE 10
double history[HISTORY_SIZE];
int history_index = 0;

typedef struct {
    char *name;
    double value;
} symbol;

#define MAX_SYMBOLS 100
symbol sym_table[MAX_SYMBOLS];
int sym_count = 0;

void add_symbol(const char *name, double value);
double get_symbol(const char *name);
double get_exact_value(const char *func, double angle);

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
%token SINVAL COSVAL TANVAL SECVAL CSCVAL COTVAL
%token ASIN ACOS ATAN
%token SINH COSH TANH
%token LOG10 CBRT
%token PI E PHI
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
    | expr NEWLINE          {
                                  history[history_index] = $1;
                                  history_index = (history_index + 1) % HISTORY_SIZE;
                                  printf("= %g\n", $1);
                              }
    | NEWLINE               { } // Fixed: Added an explicit empty action
    ;
assignment:
      VARIABLE '=' expr     { add_symbol($1, $3); }
    ;

expr:
      NUMBER                  { $$ = $1; }
    | VARIABLE                { $$ = get_symbol($1); }
    | PI                      { $$ = M_PI; }
    | E                       { $$ = M_E; }
    | PHI                     { $$ = (1 + sqrt(5)) / 2; }
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
    | SEC '(' expr ')'        { $$ = 1.0 / cos($3); }
    | CSC '(' expr ')'        { $$ = 1.0 / sin($3); }
    | COT '(' expr ')'        { $$ = 1.0 / tan($3); }
    | SINVAL '(' expr ')'     { $$ = get_exact_value("sin", $3); }
    | COSVAL '(' expr ')'     { $$ = get_exact_value("cos", $3); }
    | TANVAL '(' expr ')'     { $$ = get_exact_value("tan", $3); }
    | SECVAL '(' expr ')'     { $$ = 1.0 / cos($3); }
    | CSCVAL '(' expr ')'     { $$ = 1.0 / sin($3); }
    | COTVAL '(' expr ')'     { $$ = 1.0 / tan($3); }
    | ASIN '(' expr ')'       { $$ = asin($3); }
    | ACOS '(' expr ')'       { $$ = acos($3); }
    | ATAN '(' expr ')'       { $$ = atan($3); }
    | SINH '(' expr ')'       { $$ = sinh($3); }
    | COSH '(' expr ')'       { $$ = cosh($3); }
    | TANH '(' expr ')'       { $$ = tanh($3); }
    | LOG '(' expr ')'        { $$ = log($3); }
    | LOG10 '(' expr ')'      { $$ = log10($3); }
    | SQRT '(' expr ')'       { $$ = sqrt($3); }
    | CBRT '(' expr ')'       { $$ = cbrt($3); }
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

double get_exact_value(const char *func, double angle) {
    double epsilon = 0.0001;
    // tolerance for floating point comparison

    if (fabs(angle - 0.0) < epsilon) {
        if (strcmp(func, "sin") == 0) return 0.0;
        if (strcmp(func, "cos") == 0) return 1.0;
        if (strcmp(func, "tan") == 0) return 0.0;
        if (strcmp(func, "sec") == 0) return 1.0;
        yyerror("Cosecant or cotangent of 0 is not defined");
        return NAN;
    }
    else if (fabs(angle - M_PI/6.0) < epsilon) { // 30 degrees
        if (strcmp(func, "sin") == 0) return 0.5;
        if (strcmp(func, "cos") == 0) return sqrt(3.0) / 2.0;
        if (strcmp(func, "tan") == 0) return 1.0 / sqrt(3.0);
        if (strcmp(func, "sec") == 0) return 2.0 / sqrt(3.0);
        if (strcmp(func, "csc") == 0) return 2.0;
        if (strcmp(func, "cot") == 0) return sqrt(3.0);
    }
    else if (fabs(angle - M_PI/4.0) < epsilon) { // 45 degrees
        if (strcmp(func, "sin") == 0) return 1.0 / sqrt(2.0);
        if (strcmp(func, "cos") == 0) return 1.0 / sqrt(2.0);
        if (strcmp(func, "tan") == 0) return 1.0;
        if (strcmp(func, "sec") == 0) return sqrt(2.0);
        if (strcmp(func, "csc") == 0) return sqrt(2.0);
        if (strcmp(func, "cot") == 0) return 1.0;
    }
    else if (fabs(angle - M_PI/3.0) < epsilon) { // 60 degrees
        if (strcmp(func, "sin") == 0) return sqrt(3.0) / 2.0;
        if (strcmp(func, "cos") == 0) return 0.5;
        if (strcmp(func, "tan") == 0) return sqrt(3.0);
        if (strcmp(func, "sec") == 0) return 2.0;
        if (strcmp(func, "csc") == 0) return 2.0 / sqrt(3.0);
        if (strcmp(func, "cot") == 0) return 1.0 / sqrt(3.0);
    }
    else if (fabs(angle - M_PI/2.0) < epsilon) { // 90 degrees
        if (strcmp(func, "sin") == 0) return 1.0;
        if (strcmp(func, "cos") == 0) return 0.0;
        if (strcmp(func, "csc") == 0) return 1.0;
        yyerror("Tangent or secant of 90 degrees is not defined");
        return NAN;
    }

    yyerror("Exact value for this angle not available");
    return NAN;
}

int main() {
    printf("\n");
    printf("┌───────────────────────────────────────────────┐\n");
    printf("│        SCIENTIFIC CALCULATOR SHELL            │\n");
    printf("│          (Compiler Design Project)            │\n");
    printf("├───────────────────────────────────────────────┤\n");
    printf("│  Commands:                                    │\n");
    printf("│   - Enter any mathematical expression.        │\n");
    printf("│   - Supported operators: +, -, *, /, ^        │\n");
    printf("│   - Supported functions: sin(), cos(), etc.   │\n");
    printf("│   - Variables: x = 10, y = 20, etc.                │\n");
    printf("│   - Exit: Type 'quit' or press Ctrl+C         │\n");
    printf("└───────────────────────────────────────────────┘\n\n");

    while (1) {
        printf(">>> ");
        yyparse();
    }
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
