(* main.ml *)
open Arith_project

let () =
  let input = "if iszero 0 then succ 0 else pred succ 0" in
  let tokens = Lexer.tokenize input in
  let ast = Parser.parse tokens in
  print_endline (Ast.print_ast ast)
  (* 输出: (if (iszero 0) then (succ 0) else (pred (succ 0))) *)