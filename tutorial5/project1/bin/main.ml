open Interpreterlib
open Ast

let rec string_of_expr (e : expr) : string =
  match e with
  | Int n -> Printf.sprintf "Int %d" n
  | Bool b -> Printf.sprintf "Bool %b" b
  | Var x -> Printf.sprintf "Var %s" x
  | Binop (binop, e1, e2) ->
    let binop_str =
      match binop with
      | Add -> "Add"
      | Sub -> "Sub"
      | Mul -> "Mul"
      | Leq -> "Leq"
    in
    Printf.sprintf "Binop (%s, %s, %s)"
      binop_str (string_of_expr e1) (string_of_expr e2)
  | If (e1, e2, e3) ->
    Printf.sprintf "If (%s, %s, %s)"
      (string_of_expr e1) (string_of_expr e2) (string_of_expr e3)
  | Let (x, e1, e2) ->
    Printf.sprintf "Let (%s, %s, %s)"
      x (string_of_expr e1) (string_of_expr e2)

let parse s : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.main Lexer.read lexbuf in
  ast


(* Small-step semantics *)

let is_value : expr -> bool = function
  | Int _ | Bool _ -> true
  | _ -> false

let rec step : expr -> expr = function
  | Int _ | Bool _ -> failwith "Does not step on a value"
  | Var _ -> failwith "Unbound variable"
  | Binop (binop, e1, e2) when is_value e1 && is_value e2 ->
    step_binop binop e1 e2
  | Binop (binop, e1, e2) when is_value e1 -> Binop (binop, e1, step e2)
  | Binop (binop, e1, e2) -> Binop (binop, step e1, e2)
  | If _ -> failwith "TODO: implement if in step (Task 2)"
  | Let _ -> failwith "TODO: implement let in step (Task 3)"

and step_binop binop v1 v2 = match binop, v1, v2 with
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"

(* fully evaluate [e] to a value [v] *)
let rec eval (e : expr) : expr =
  if is_value e then e else
    e |> step |> eval

let interp (s : string) : string =
  s |> parse |> eval |> string_of_expr


(* Big-step semantics *)

let rec eval_big (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (binop, e1, e2) -> eval_bop binop e1 e2
  | If _ -> failwith "TODO: Task 2"
  | Let _ -> failwith "TODO: Task 3"

and eval_bop binop e1 e2 = match binop, eval_big e1, eval_big e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"

let interp_big (s : string) : string =
  s |> parse |> eval_big |> string_of_expr

let () =
  let filename = "test/simpl_test1.in" in
  (* let filename = "test/simpl_test2.in" in *)
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;

  (* let res = interp file_content in
  Printf.printf "Result of interpreting %s:\n%s\n\n" filename res;

  let res = interp_big file_content in
  Printf.printf "Result of interpreting %s with big-step model:\n%s\n\n" filename res; *)

  let ast = parse file_content in
  Printf.printf "AST: %s\n" (string_of_expr ast)
