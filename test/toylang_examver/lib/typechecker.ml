(** Type checker for ToyLang *)

open Ast

type typ =
  | IntType
  | BoolType

module StringMap = Map.Make (String)

(* Environment to store variable types *)
type type_env = typ StringMap.t

let rec check_program (prog : program) : unit =
  ignore (check_stmt_seq StringMap.empty prog)

and check_stmt_seq (env : type_env) (stmts : stmt_seq) : type_env =
  List.fold_left check_stmt env stmts

and check_stmt (env : type_env) (s : stmt) : type_env =
  match s with
  | AssignStmt (lval, rval) ->
    let rval_type = infer_exp_type env rval in
    (match StringMap.find_opt lval env with
     | Some prev_type -> failwith "TODO: Handle variable reassignment"
     | None -> StringMap.add lval rval_type env)
  | IfStmt (cond, then_body, else_body) ->
    failwith "TODO: Check if statement";
    env
  | RepeatStmt (body, cond) ->
    failwith "TODO: Check repeat statement";
    env
  | PrintStmt e ->
    let _ = infer_exp_type env e in
    env

and infer_exp_type (env : type_env) (e : exp) : typ =
  match e with
  | IntExp _ -> failwith "TODO: Infer type for integer literal expression"
  | BoolExp _ -> failwith "TODO: Infer type for boolean literal expression"
  | VarRefExp name ->
    (try StringMap.find name env with
     | Not_found -> failwith ("Undefined variable " ^ name))
  | BinaryExp (left, op, right) ->
    let left_type = infer_exp_type env left in
    let right_type = infer_exp_type env right in
    (match op with
     | AddOp | SubOp | MulOp | DivOp ->
       failwith "TODO: Infer type and do type checking for binary arithmetic expression"
     | LtOp | EqOp ->
       if left_type = right_type
       then BoolType
       else failwith "Operands of comparison must be of same type")
;;
