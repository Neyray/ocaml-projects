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
  (*修改1*)
  | If (e1,e2,e3) when is_value e1 -> (match e1 with   (*只有is_value的才能进行判断*)
                                                        | Bool true -> e2
                                                        | Bool false -> e3(*这里用的是parser里的expr！也就是ast*)  (*之所以直接返回e2,e3是因为eval函数对不是value的值再次进行了step调用*)
                                                        | _ -> failwith "If condition must be a boolean") (*！！！用括号把内部match包起来，防止下面的分支被吞并；同时补全Int等非Bool情形*)
  | If (e1,e2,e3) -> If(step e1,e2,e3)   (*别的需要先对e1进行处理*)
  | Let _ -> failwith "TODO: implement let in step (Task 3)"

  (*small,big最大的区别就是这个辅助函数有没有递归调用step本身*)
  (*small需要一步步化完之后才能进行计算*)
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
(*都是parser生成的ast*)
let rec eval_big (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  (*不需要在eval_big函数化完，直接调用辅助函数，在辅助函数里再调用本身直接递归出最后结果*)
  | Binop (binop, e1, e2) -> eval_bop binop e1 e2(*直接调用计算函数eval_bop*)
  (*修改2*)
  | If (e1,e2,e3) -> eval_bop2 e1 e2 e3
  | Let _ -> failwith "TODO: Task 3"

(*专门为binop e1,e2服务*)
and eval_bop binop e1 e2 = match binop, eval_big e1, eval_big e2 with   (*在内部递归调用eval_big函数，递归直接得到最终结果，隐藏过程*)
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"

  (*修改3*)
(*为If e1,e2,e3服务*)
and eval_bop2 e1 e2 e3 = match eval_big e1 with
  | Bool true -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "If condition must be a boolean" (*补全非Bool情形，避免Match_failure*)

let interp_big (s : string) : string =
  s |> parse |> eval_big |> string_of_expr

let () =
  let filename = "test/simpl_test2.in" in
  (* let filename = "test/simpl_test2.in" in *)
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;

  let res = interp file_content in
  Printf.printf "Result of interpreting %s:\n%s\n\n" filename res;

  let res = interp_big file_content in
  Printf.printf "Result of interpreting %s with big-step model:\n%s\n\n" filename res; 

  let ast = parse file_content in
  Printf.printf "AST: %s\n" (string_of_expr ast)
