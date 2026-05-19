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
%token FUN ARROW   (*修改11：Task 5 新加的两个 token*)
%token EOF

%nonassoc IN ELSE   (*解决 if/let 引发的 shift-reduce 冲突，告诉 Menhir 这些 token 不参与结合。*)
%left LEQ
%left PLUS MINUS
%left TIMES

%start main
%type <Ast.expr> main
%%

main:
    expr EOF { $1 }
;

(*修改11：Task 5 重构文法层级
   把 expr 拆成三层：expr / app / simple
   - simple：最小单元（字面量、变量、加括号的 expr）
   - app  ：函数应用，左结合，比二元运算优先级更高（f x + 1 = (f x) + 1）
   - expr ：包含二元运算 / if / let / fun
   这样 application 通过文法本身解决左结合 + 优先级，不需要 %left 声明。*)

expr:
    | app                              { $1 }
    | expr PLUS expr                   { Binop (Add, $1, $3) }
    | expr MINUS expr                  { Binop (Sub, $1, $3) }
    | expr TIMES expr                  { Binop (Mul, $1, $3) }
    | expr LEQ expr                    { Binop (Leq, $1, $3) }
    | IF expr THEN expr ELSE expr      { If ($2, $4, $6) }
    | LET ID EQUALS expr IN expr       { Let ($2, $4, $6) }
    | FUN ID ARROW expr                { Fun ($2, $4) }   (*修改11：fun x -> e*)
;

app:
    | simple                           { $1 }
    | app simple                       { App ($1, $2) }   (*修改11：左递归 = 左结合，f x y = (f x) y*)
;

simple:
    | INT                              { Int $1 }
    | TRUE                             { Bool true }
    | FALSE                            { Bool false }
    | ID                               { Var $1 }
    | LPAREN expr RPAREN               { $2 }
;
