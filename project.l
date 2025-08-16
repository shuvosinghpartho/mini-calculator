%{
#include "project.tab.h"
#include <string.h>
%}

%%

[0-9]+\.[0-9]+([Ee][+-]?[0-9]+)? { yylval.val = atof(yytext); return NUMBER; }
[0-9]+([Ee][+-]?[0-9]+)?          { yylval.val = atof(yytext); return NUMBER; }

"pi"            { return PI; }
"e"             { return E; }
"phi"           { return PHI; }
"sin"           { return SIN; }
"cos"           { return COS; }
"tan"           { return TAN; }
"sec"           { return SEC; }
"csc"           { return CSC; }
"cot"           { return COT; }
"asin"          { return ASIN; }
"acos"          { return ACOS; }
"atan"          { return ATAN; }
"sinh"          { return SINH; }
"cosh"          { return COSH; }
"tanh"          { return TANH; }
"log"           { return LOG; }
"log10"         { return LOG10; }
"sqrt"          { return SQRT; }
"cbrt"          { return CBRT; }

[a-zA-Z][a-zA-Z0-9]* {
    yylval.str = strdup(yytext);
    return VARIABLE;
}

[ \t\r]+       ;
\n             { return NEWLINE; }
"+"            { return '+'; }
"-"            { return '-'; }
"*"            { return '*'; }
"/"            { return '/'; }
"^"            { return '^'; }
"("            { return '('; }
")"            { return ')'; }
"="            { return '='; }
.              { return yytext[0]; }

%%

int yywrap() {
    return 1;
}