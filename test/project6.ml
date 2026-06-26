(** Interpreter for ToyLang *)

open Ast

type value = int

module StringMap = Map.Make (String)

(* Environment to store variable values *)
type value_env = value StringMap.t

let rec interpret_program (prog : program) : unit =
  ignore (exec_stmt_seq StringMap.empty prog)

and exec_stmt_seq (env : value_env) (stmts : stmt_seq) : value_env =
  List.fold_left exec_stmt env stmts

and exec_stmt (env : value_env) : stmt -> value_env = function
  | IfStmt (cond, then_body, else_body) ->
    let cond_val = eval_exp env cond in
    if cond_val <> 0
    then exec_stmt_seq env then_body
    else (match else_body with
    | Some stmts -> exec_stmt_seq env stmts 
    | None -> env )

  | RepeatStmt (body, cond) -> 
    let rec loop env =
      let env' = exec_stmt_seq env body in
      if eval_exp env' cond <> 0 then env'       (* 条件为真(非0)就停 *)
      else loop env'                             (* 否则带着新 env 再来一轮 *)
    in
    loop env

  | AssignStmt (lval, rval) ->
    let rval_val = eval_exp env rval in
    StringMap.add lval rval_val env

  | PrintStmt e -> 
    Printf.printf "%d\n" (eval_exp env e);
    env

and eval_exp (env : value_env) : exp -> value = function
  | IntExp n -> n
  | BoolExp b -> if b then 1 else 0
  | VarRefExp name ->
    (try StringMap.find name env
     with Not_found -> failwith ("Unbound name " ^ name))
  | BinaryExp (left, op, right) ->
    let l = eval_exp env left and r = eval_exp env right in
    (match op with
     | AddOp -> l + r
     | SubOp -> l - r
     | MulOp -> l * r
     | DivOp -> if r = 0 then failwith "Division by zero" else l / r
     | LtOp -> if l < r then 1 else 0           (* 关系运算返回 1/0 *)
     | EqOp -> if l = r then 1 else 0)
     
;;
