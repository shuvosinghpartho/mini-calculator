%{
#include "squarecalc.tab.h"
#include <string.h>
%}

%%

[0-9]+\.[0-9]+  { yylval.val = atof(yytext); return NUMBER; }
[0-9]+          { yylval.val = atof(yytext); return NUMBER; }

"pi"            { return PI; }
"e"             { return E; }
"sin"           { return SIN; }
"cos"           { return COS; }
"tan"           { return TAN; }
"sec"           { return SEC; }
"csc"           { return CSC; }
"cot"           { return COT; }
"log"           { return LOG; }
"sqrt"          { return SQRT; }

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