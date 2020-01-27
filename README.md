# Math-Mark (Under Construction)

A variant of John Gruber's
[Markdown](https://daringfireball.net/projects/markdown/) with some built-in
support for math with LaTeX-like syntax. Compiles to HTML+MathML (i.e., a
static webpage).

Inspired by Jeff Lee's ANSI C grammar: [lex
specification](https://www.lysator.liu.se/c/ANSI-C-grammar-l.html), [yacc
grammar](https://www.lysator.liu.se/c/ANSI-C-grammar-y.html), and Jacques
Distler's [itex2MML](https://golem.ph.utexas.edu/~distler/blog/itex2MML.html).

Currently, supports basic markdown, exponentiation (`\({1}^{23453}\)`), and
square roots (`\(\sqrt{10}\)`).

**Requires:** [flex](https://github.com/westes/flex) and
[bison](https://www.gnu.org/software/bison/).

**License:** GPLv3.

**Standards:** Compiles to
[REC-MathML3-20140410](https://www.w3.org/TR/2014/REC-MathML3-20140410/).

## Syntax

Markdown as usual, with inline TeX-style math enclosed in `\(` and `\)`, and
displaystyle TeX-style math enclosed in `\[` `\]`.

## Installation

Clone the repository.
```
git clone [...]
```
Run make.
```
make
```

## Usage
Write a file in math-mark, and compile it to HTML+MathML using
```
./mmd [input file] >[output file]
```
