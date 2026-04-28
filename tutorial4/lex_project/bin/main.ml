open Lex_project.Ast

let rec print_expr = function
  | Num n -> Printf.printf "%d" n
  | Add(a, b) -> Printf.printf "("; print_expr a; Printf.printf " + "; print_expr b; Printf.printf ")"
  | Sub(a, b) -> Printf.printf "("; print_expr a; Printf.printf " - "; print_expr b; Printf.printf ")"
  | Mul(a, b) -> Printf.printf "("; print_expr a; Printf.printf " * "; print_expr b; Printf.printf ")"
  | Div(a, b) -> Printf.printf "("; print_expr a; Printf.printf " / "; print_expr b; Printf.printf ")"

let () =
  let input = "3 + 5 * 2" in
  let lexbuf = Lexing.from_string input in
  let ast = Lex_project.Parser.main Lex_project.Lexer.read lexbuf in
  Printf.printf "Input: %s\nAST: " input;
  print_expr ast;
  print_newline ()
