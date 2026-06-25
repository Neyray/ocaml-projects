/** Yacc parser for ToyLang */

%{
open Ast

(* Error handling *)
let parse_error _ : unit = failwith "Parse error"
%}

/** Token declarations */
%token <int> NUM
%token <string> ID
%token TRUE FALSE
%token PLUS MINUS TIMES DIVIDE
%token LT EQ
%token LPAREN RPAREN
%token IF THEN ELSE END
%token REPEAT UNTIL
%token ASSIGN
%token PRINT
%token SEMICOLON
%token EOF

%token TODO // Placeholder for unimplemented features

/** Precedence and associativity */
%nonassoc LT EQ
%left PLUS MINUS
%left TIMES DIVIDE

/** Start symbol */
%start program
%type <Ast.program> program

%%

/** Grammar rules */

program:
  | stmt_seq EOF { $1 }
;

stmt_seq:
  | stmt SEMICOLON { [$1] }
  | TODO { failwith "TODO: Parse statement sequence with multiple statements" }
;

stmt:
  | if_stmt { $1 }
  | repeat_stmt { $1 }
  | assign_stmt { $1 }
  | print_stmt { $1 }
;

if_stmt:
  | TODO { failwith "TODO: Parse if statement" }
;

repeat_stmt:
  | TODO { failwith "TODO: Parse repeat statement" }
;

assign_stmt:
  | ID ASSIGN exp { AssignStmt($1, $3) }
;

print_stmt:
  | TODO { failwith "TODO: Parse print statement" }
;

exp:
  | TODO { failwith "TODO: Parse expression" }
;

simple_exp:
  | simple_exp PLUS term { BinaryExp($1, AddOp, $3) }
  | simple_exp MINUS term { BinaryExp($1, SubOp, $3) }
  | term { $1 }
;

term:
  | term TIMES factor { BinaryExp($1, MulOp, $3) }
  | term DIVIDE factor { BinaryExp($1, DivOp, $3) }
  | factor { $1 }
;

factor:
  | TODO { failwith "TODO: Parse factor" }
;
