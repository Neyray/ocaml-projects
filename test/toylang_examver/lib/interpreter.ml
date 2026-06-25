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
    else failwith "TODO: Execute optional else branch"
  | RepeatStmt (body, cond) -> failwith "TODO: Execute repeat statement"
  | AssignStmt (lval, rval) ->
    let rval_val = eval_exp env rval in
    StringMap.add lval rval_val env
  | PrintStmt e -> failwith "TODO: Execute print statement"

and eval_exp (env : value_env) : exp -> value = function
  | IntExp n -> n
  | BoolExp b -> if b then 1 else 0
  | VarRefExp name -> StringMap.find name env (* TODO: Handle name not found *)
  | BinaryExp (left, op, right) -> failwith "TODO: Evaluate binary expression"
;;
