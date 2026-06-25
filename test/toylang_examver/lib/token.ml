open Parser_yacc (* Reuse token definition from yacc parser *)

(** Token to string *)

let string_of_token : token -> string = function
  | SEMICOLON -> ";"
  | ASSIGN -> ":="
  | PLUS -> "+"
  | MINUS -> "-"
  | TIMES -> "*"
  | DIVIDE -> "/"
  | LPAREN -> "("
  | RPAREN -> ")"
  | LT -> "<"
  | EQ -> "="
  | IF -> "IF"
  | THEN -> "THEN"
  | ELSE -> "ELSE"
  | END -> "END"
  | REPEAT -> "REPEAT"
  | UNTIL -> "UNTIL"
  | PRINT -> "PRINT"
  | TRUE -> "TRUE"
  | FALSE -> "FALSE"
  | NUM n -> string_of_int n
  | ID s -> s
  | EOF -> "EOF"
  | _ -> failwith "Invalid token"
;;
