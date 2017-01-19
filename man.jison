/* lexical grammar */

%lex

%%

[.']?[\\]["].*   return 'COMMENT'
[.'][^ \n]+[ ]*  return 'CONTROL'
[\\]([(]..|.)    return 'SPECIAL'
[\n]             return 'EOL'
[^\\\n]+         return 'TEXT'
[\\]             return 'SPECIAL' // '\' at end of line.
<<EOF>>          return 'EOF'
.                return 'INVALID'

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
    | CONTROL
        { $$ = 'CONTROL: |' + yytext + '|'; }
    | SPECIAL
        { $$ = 'SPECIAL: |' + yytext + '|'; }
    | EOL
        { $$ = ''; }
    | TEXT
        { $$ = 'TEXT: |' + yytext + '|'; }
    ;
