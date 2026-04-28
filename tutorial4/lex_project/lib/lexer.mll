{
  open Parser
}

rule read = parse
  | [' ' '\t' '\n'] { read lexbuf }
  | ['0'-'9']+ as num { INT (int_of_string num) }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { TIMES }
  | '/' { DIV }
  | eof { EOF }
  | _   { failwith "Unknown character" }
