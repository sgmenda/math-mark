/*
 * mmd.y parser for math-mark
 * Copyright (C) 2020 Sanketh <c1own.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

%{
#include <stdio.h>
#include <string.h>

#include "mmd.tab.h"
#include "lex.yy.h"

extern int yyparse();
extern int yyerror(char *s);

// const char *math_begin = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">";
const char *math_inline_begin = "<math display=\"inline\"><mtable>";
const char *math_inline_end = "</mtable></math>";
const char *math_display_begin = "<math display=\"block\"><mtable>";
const char *math_display_end = "</mtable></math>";

const char *eqn = "<mlabeledtr id=\"[label]\"><mtd><mtext> (2.1) </mtext></mtd><mtd>[body; mathrow]</mtd></mlabeledtr>";

char *concatFourStrings(const char *s1, const char *s2, const char *s3, const char *s4){
    char *concatedString = malloc(1 + strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4));
    sprintf(concatedString, "%s%s%s%s", s1, s2, s3, s4); 
    return concatedString;
}
char *concatThreeStrings(const char *s1, const char *s2, const char *s3){
    return concatFourStrings("", s1, s2, s3);
}

char *resolveFunction(const char *func_name, const char *argument) {
    if (!strcmp(func_name, "\\sqrt")) {
        return concatThreeStrings("<msqrt>", argument, "</msqrt>");
    } else {
        fprintf(stderr, "Unrecognized function %s\n", func_name);
        return NULL;
    }
}

%}

/* declare types */
%union{
  char *string;
  char character;
  int value;
}

/* markdown tokens */
%token <string> TEXT
%token <string> PRE_TEXT
%token <string> PUNCTUATION
%token <string> HEADING1
%token <string> HEADING2
%token <string> HEADING3
%token <string> HEADING4
%token CODE_BEGIN
%token CODE_END
%token EMPH_BEGIN
%token EMPH_END
%token STRONG_BEGIN
%token STRONG_END
%token PRE_BEGIN
%token PRE_END
%token EOP

/* math tokens */
%token START_INLINE_MATH
%token END_INLINE_MATH
%token START_DISPLAY_MATH
%token END_DISPLAY_MATH
%token <value> MATHDIGIT
%token <character> MATHCHAR
%token <character> MATHSYMB
%token MATH_LBRACE
%token MATH_RBRACE
%token MATH_SUP
%token MATH_SUB
%token <string> MATH_FUNC
// identifiers (mi), 
// numbers (mn), 
// operators (mo), 
// text (mtext), 
// strings (ms) and 
// spacing (mspace).
%type <string> text
%type <string> math
%type <string> mathrow
%%

document: /* nothing */
        | document text { printf("%s", $2); }
        | document EOP { printf("\n\n"); }
        ;

math: MATHDIGIT {
                    // Corresponds to a math number.
                    char* mathdigit = malloc(1+1);
                    sprintf(mathdigit, "<mn>%1d</mn>", $1);
                    $$ = mathdigit;
                }
    | MATHCHAR  {
                    // Corresponds to a math identifier.
                    char* mathchar = malloc(1+1);
                    sprintf(mathchar, "<mi>%c</mi>", $1);
                    $$ = mathchar;
                }
    | MATHSYMB  {
                    // Corresponds to a math operator.
                    char* mathchar = malloc(1+1);
                    sprintf(mathchar, "<mo>%c</mo>", $1);
                    $$ = mathchar;
                }
    | math math {
                    $$ = concatThreeStrings($1, "", $2);   
                }
    | mathrow MATH_SUP mathrow {
                    $$ = concatFourStrings("<msup>", $1, $3, "</msup>");
                }
    | MATH_FUNC mathrow {
                    $$ = resolveFunction($1, $2);
                }
    ;

mathrow: MATH_LBRACE math MATH_RBRACE {
                    $$ = concatThreeStrings("<mrow>", $2, "</mrow>");
                }

text: TEXT {$$ = $1;}
    | text text {
            $$ = concatThreeStrings($1, " ", $2);
        }
    | text PUNCTUATION {
            $$ = concatThreeStrings($1, "", $2);
        }
    | EMPH_BEGIN text EMPH_END {
            $$ = concatThreeStrings("<emph>", $2, "</emph>");
        }
    | STRONG_BEGIN text STRONG_END {
            $$ = concatThreeStrings("<strong>", $2, "</strong>");
        }
    | CODE_BEGIN text CODE_END {
            $$ = concatThreeStrings("<code>", $2, "</code>");
        }
    | PRE_BEGIN PRE_TEXT PRE_END {
            $$ = concatThreeStrings("<pre>", $2, "</pre>");
        }
    | START_INLINE_MATH math END_INLINE_MATH { 
            $$ = concatThreeStrings(math_inline_begin, $2, math_inline_end);
        }
    | START_DISPLAY_MATH math END_DISPLAY_MATH { 
            $$ = concatThreeStrings(math_display_begin, $2, math_display_end);
        }
    | HEADING1 {
            $$ = concatThreeStrings("<h1>", $1, "</h1>");
        }
    | HEADING2 {
            $$ = concatThreeStrings("<h2>", $1, "</h2>");
        }
    | HEADING3 {
            $$ = concatThreeStrings("<h3>", $1, "</h3>");
        }
    | HEADING4 {
            $$ = concatThreeStrings("<h4>", $1, "</h4>");
        }
    ;
%%

int main(int argc, char **argv) {
    if ( argc <= 1 ) {
        fprintf(stderr, "Expected 1 argument.\n");
        return -1;
    }
    yyin = fopen(argv[1], "r");
    yyparse();
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "error: %s\n", s);
    return -1;
}
