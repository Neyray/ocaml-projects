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
     | Some prev_type -> 
      if prev_type=rval_type then env
      else failwith "Type mismatch in assignment to " ^ lval
     | None -> StringMap.add lval rval_type env)
  | IfStmt (cond, then_body, else_body) ->
    if infer_exp_type env cond <> BoolType then failwith "Condition of if must be bool"
      check_program then_body;
    match else_body with
    | Some stmt -> check_program stmt
    | None -> ();
    env
  | RepeatStmt (body, cond) ->
    let inner=check_stmt_seq env body in
    if infer_exp_type inner cond <> BoolType 
      then failwith "Condition of repeat must be bool";
    env
  | PrintStmt e ->
    let _ = infer_exp_type env e in
    env

and infer_exp_type (env : type_env) (e : exp) : typ =
  match e with
  | IntExp _ -> IntType
  | BoolExp _ -> BoolType
  | VarRefExp name ->
    (try StringMap.find name env with
     | Not_found -> failwith ("Undefined variable " ^ name))
  | BinaryExp (left, op, right) ->
    let left_type = infer_exp_type env left in
    let right_type = infer_exp_type env right in
    (match op with
     | AddOp | SubOp | MulOp | DivOp ->
      if left_type=IntType && right_type=IntType then IntType
      else failwith "Operands of arithmetic must be int"
     | LtOp | EqOp ->
       if left_type = right_type
       then BoolType
       else failwith "Operands of comparison must be of same type")
;;
