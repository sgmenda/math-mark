%{
#include "mmd.tab.h"
#include <string.h>

int displaymode = 0;

%}

/* Use start condition stacks, this allows us to nest modes. */
%option stack

DIGIT    [0-9]
LETTER   [a-zA-Z]
TEXT     [0-9a-zA-Z]
PUNC     [,\.?!'"]

HTEXT    [0-9a-zA-Z ]+

/* Math mode symbols adapted from itexToMML */
SYMBOLS  "."|","|":"|"!"|"="|"~"|";"|"?"|"#"|"`"|"*"|"<"|">"|"+"|"-"

/* declare start conditions (ie modes) */
%x math
%x mathtext
%x comment

%x code
%x emph
%x strong
%x pre

%%
   /* From flex manual */
"/*"                 { yy_push_state(comment); }
<comment>[^*]*       {}
<comment>"*"+[^*/]*  {}
<comment>"*/"        { yy_pop_state(); }

"\\\("               { yy_push_state(math); displaymode = 0; return START_INLINE_MATH; }
<math>"\\\)"         { 
                        if (!displaymode) { 
                           yy_pop_state(); 
                           return END_INLINE_MATH; 
                        } else { 
                           fprintf(stderr, "Closing displaymode with \\)\n");
                        } 
                     }
"\\\["               { yy_push_state(math); displaymode = 1; return START_DISPLAY_MATH; }
<math>"\\\]"         { 
                        if (displaymode) { 
                           yy_pop_state(); 
                           return END_DISPLAY_MATH; 
                        } else { 
                           fprintf(stderr, "Closing inlinemode with \\]\n");
                        } 
                     }

<math>{
   {DIGIT}     {
                     // fprintf(stderr, "Mathdigit %c\n", *yytext);
                     yylval.value = atoi(yytext);
                     return MATHDIGIT;
               }
   {LETTER}    {
                     // fprintf(stderr, "Mathchar %c\n", *yytext);
                     yylval.character = *yytext;
                     return MATHCHAR;
               }
   {SYMBOLS}   {
                     // fprintf(stderr, "Mathsymb %c\n", *yytext);
                     yylval.character = *yytext;
                     return MATHSYMB;
               }
   " "         {/* ignore spaces in math mode. */}
   "{"   { return MATH_LBRACE; }
   "}"   { return MATH_RBRACE; }
   "^"   { return MATH_SUP; }
   "_"   { return MATH_SUB; }
   "\\"+{LETTER}+   {
                     // fprintf(stderr, "Mathfunc %s\n", yytext);
                     yylval.string = strdup(yytext);
                     return MATH_FUNC;
                  }
}

^"# "+{HTEXT}$    {
                     // fprintf(stderr, "Heading1 %s\n", (yytext+2));
                     yylval.string = strdup(yytext+2);
                     return HEADING1;
                  }
^"## "+{HTEXT}$   {
                     // fprintf(stderr, "Heading2 %s\n", (yytext+3));
                     yylval.string = strdup(yytext+3);
                     return HEADING2;
                  }
^"### "+{HTEXT}$  {
                     // fprintf(stderr, "Heading3 %s\n", (yytext+4));
                     yylval.string = strdup(yytext+4);
                     return HEADING3;
                  }
^"#### "+{HTEXT}$ {
                     // fprintf(stderr, "Heading4 %s\n", (yytext+5));
                     yylval.string = strdup(yytext+5);
                     return HEADING4;
                  }

"```"          { yy_push_state(pre); return PRE_BEGIN; }
<pre>"```"     { yy_pop_state(); return PRE_END; }
<pre>[^```]*   {
                  yylval.string = strdup(yytext);
                  return PRE_TEXT;
               }

"`"         { yy_push_state(code); return CODE_BEGIN; }
<code>"`"   { yy_pop_state(); return CODE_END; }

<INITIAL,emph>"**"   { yy_push_state(strong); return STRONG_BEGIN; }
<strong>"**"         { yy_pop_state(); return STRONG_END; }

<INITIAL,strong>"*"  { yy_push_state(emph); return EMPH_BEGIN; }
<emph>"*"            { yy_pop_state(); return EMPH_END; }

<INITIAL,emph,strong,code>{
   {PUNC}   { 
               yylval.string = strdup(yytext);
               return PUNCTUATION;
            }
   {TEXT}+  {
               yylval.string = strdup(yytext);
               return TEXT;
            }
   "\n\n"   { return EOP; }
   [ \t\n]  { /* ignore whitespace */ }
   .        { fprintf(stderr, "Mystery character %c\n", *yytext); }
}

%%

