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
    | "=" { EQUALS }
    | "if" { IF }
    | "then" { THEN }
    | "else" { ELSE }
    | "in" { IN }
    | "let" { LET }
    | "true" { TRUE }
    | "false" { FALSE }
    | letter+ as id  { ID id }(*letter+表示一个或者多个字符*)
    | eof { EOF }
    | _ { failwith "Invalid character" }
