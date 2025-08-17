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
%token SEC CSC COT // agulo amra reciprocal functions gulo likhsi. sec = 1/cos, csc = 1/sin, cot = 1/tan.
%token SINVAL COSVAL TANVAL SECVAL CSCVAL COTVAL // amra exect value ber korar jonno alada token use kortesi. like sin(π/6)=0.5.
%token ASIN ACOS ATAN // inverse trig function
%token SINH COSH TANH // hyperbolic trig function
%token LOG10 CBRT // amra LOG10 bolte base 10 logarithm bujaici, CBRT mane cube root.
%token PI E PHI // PI → π = 3.14159, E → e = 2.71828, and PHI (Golden Ratio) = 1.6180339887... eta akta irrational number mane ja kokkhno ses hobe na.
                                                      // PHI { $$ = (1 + sqrt(5)) / 2; }
                                                      // user jodi sudhu PHI likhe enter dei tobe parser sorasori golden ratio r man 1.618 return korbe.
%token '='
%token <str> VARIABLE 

%type <val> expr line

%left '+' '-'
%left '*' '/'
%right UMINUS
%right '^'

%%

input:  // start symbol, mane integer input dhorar jonno. 
      /* empty */  // mane inout akebare khali thakte pare. like user jodi kisu nau likhe tau parser valid input dhorbe.
    | input line  // like recursive rule, er mane input ak line er por r akta line aste pare. 
    ;



line:
      assignment NEWLINE    { printf("Variable assigned.\n"); }
    | expr NEWLINE          {
                                  history[history_index] = $1;
                                  history_index = (history_index + 1) % HISTORY_SIZE;
                                  printf("= %g\n", $1);
                              }
    | NEWLINE               { } 
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



// ei function symbol table e variable jug kortese or update kortese.
// zodi variable like x, jodi age tekei thake tobe ter man update korbe.
// zodi na thake notun variable hisebe add korbe
// zodi jaiga na thake tobe error dibe

void add_symbol(const char *name, double value) {
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(sym_table[i].name, name) == 0) {
            sym_table[i].value = value;
            return;
        }
    } // zodi x = 10 age tekei symbol table e thake, r notun kore x = 20 add hoi, tokhon 10 overwrite hoia 20 hoia jabe.

    // notun varibale zug kora
    if (sym_count < MAX_SYMBOLS) {
        sym_table[sym_count].name = strdup(name); // strdup(name) → variable er nam copy kore rakhe,
                                                  // cz, direct pointer dile pore somossa hote pre.
        sym_table[sym_count].value = value;
        sym_count++;
    } else {
        yyerror("Symbol table overflow");
    }
}

// ei function ta symbol table teke knu variable er man ber kore ane.
double get_symbol(const char *name) {
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(sym_table[i].name, name) == 0) {
            return sym_table[i].value;
        }
    }
    yyerror("Undefined variable");
    return 0.0;
}


// bished kisu koner(special angles) trigonometric function er exact value return kre.
// zemon 30°, 45°, 60°, 90° ect.
// floating point comparison sorasori kora jai na tai epsilon use kora hoiase
// fabs holo float, double er absulute value return kortese.

double get_exact_value(const char *func, double angle) {  // angle = 0 kine ta check kortese.
    double epsilon = 0.0001; // epsilon holo khub choto akta value (like 1e-9) jeno loating-point er rounding error erano jai. 

    if (fabs(angle - 0.0) < epsilon) { // 00 degree
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
    printf("│   - Variables: x = 10, y = 20, etc.           │\n");
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
