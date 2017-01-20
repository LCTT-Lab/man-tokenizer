// man-tokenizer
//
// Copyright (C) 2017  LCTT
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* lexical grammar */

%lex

%%

[.']?[\\]["].*   return 'COMMENT'
// https://github.com/zaach/jison/issues/67#issuecomment-31093442
[.'][^ \n]+[ ]*  %{
                     this.yy_ = this;
                     return (this.yylloc.first_column === 0) ? 'CTRL' : 'TEXT';
                 %}
[\\]([(]..|.)    return 'SPEC'
[\n]             return 'EOL'
[^\\\n]+         return 'TEXT'
[\\]             return 'SPEC' // '\' at end of line.
<<EOF>>          return 'EOF'
.                return 'INV'

/lex

/* language grammar */

%start expressions

%%

expressions
    : e EOF
        { typeof console !== 'undefined' ? console.log($1) : print($1);
          return $1; }
    ;

e
    : e t
        { $$ = $1 + '\n' + $2; }
    | t
        { $$ = $1; }
    ;

t
    : COMMENT
        { $$ = 'COMMENT: |' + yytext + '|'; }
    | CTRL
        { $$ = 'CTRL: |' + yytext + '|'; }
    | SPEC
        { $$ = 'SPEC: |' + yytext + '|'; }
    | EOL
        { $$ = ''; }
    | TEXT
        { $$ = 'TEXT: |' + yytext + '|'; }
    ;
