{
    open Parser
}

let letter = ['a'-'z' 'A'-'Z']

rule read = parse
    | [' ' '\t' '\n'] { read lexbuf }
    | ['0'-'9']+ as num { INT (int_of_string num) }
    | '+' { PLUS }
    | '-' { MINUS }
    | '*' { TIMES }
    | '(' { LPAREN }
    | ')' { RPAREN }
    | "<=" { LEQ }
    | "->" { ARROW }   (*修改10：lambda calculus 用 -> 分隔参数和函数体*)
    | "=" { EQUALS }
    | "if" { IF }
    | "then" { THEN }
    | "else" { ELSE }
    | "in" { IN }
    | "let" { LET }
    | "fun" { FUN }    (*修改10：fun 关键字，进入 lambda 抽象*)
    | "true" { TRUE }
    | "false" { FALSE }
    | letter+ as id  { ID id }
    | eof { EOF }
    | _ { failwith "Invalid character" }
