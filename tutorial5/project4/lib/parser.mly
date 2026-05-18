%{
    open Ast
%}

%token <int> INT
%token <string> ID
%token TRUE FALSE
%token IF THEN ELSE
%token LET IN EQUALS
%token PLUS MINUS TIMES LEQ
%token LPAREN RPAREN
%token EOF

%nonassoc IN ELSE(*解决 if/let 引发的 shift-reduce 冲突，告诉 Menhir 这些 token 不参与结合。*)
%left LEQ
%left PLUS MINUS
%left TIMES

%start main
%type <Ast.expr> main
%%

main:
    expr EOF { $1 }
;

expr:
    | INT                              { Int $1 }
    | TRUE                             { Bool true }
    | FALSE                            { Bool false }
    | ID                               { Var $1 }
    | expr PLUS expr                   { Binop (Add, $1, $3) }(*$1、$2、$3 是 语法规则右边第几个成分的值*)
    | expr MINUS expr                  { Binop (Sub, $1, $3) }
    | expr TIMES expr                  { Binop (Mul, $1, $3) }
    | expr LEQ expr                    { Binop (Leq, $1, $3) }
    | IF expr THEN expr ELSE expr      { If ($2, $4, $6) }
    | LET ID EQUALS expr IN expr       { Let ($2, $4, $6) }
    | LPAREN expr RPAREN               { $2 }
;