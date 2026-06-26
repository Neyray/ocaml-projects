(** Type checker for ToyLang *)

open Ast

type typ =
  | IntType
  | BoolType

(*类似于C++的map<string, typ>*)
module StringMap = Map.Make (String)

(* Environment to store variable types *)
type type_env = typ StringMap.t
(*type_env 是一个变量类型表,记录变量名 -> 类型*)

(*检查一下有没有错误，没错就行，返回值不要了*)
let rec check_program (prog : program) : unit =
  ignore (check_stmt_seq StringMap.empty prog)

(*从左到右检查每一条语句，并把更新后的环境传给下一条语句*)
and check_stmt_seq (env : type_env) (stmts : stmt_seq) : type_env =
  List.fold_left check_stmt env stmts

and check_stmt (env : type_env) (s : stmt) : type_env =
  match s with
  | AssignStmt (lval, rval) ->
    let rval_type = infer_exp_type env rval in
    (match StringMap.find_opt lval env with
     | Some prev_type ->   (* 变量已定义：重新赋值必须类型一致 *)
      if rval_type=prev_type then env
      else failwith ("Type mismatch in assignment to " ^ lval)   (*！！！^表示连接后面的字符*)
     | None -> StringMap.add lval rval_type env)   (* 首次赋值 = 定义变量 *)

   | IfStmt (cond, then_body, else_body) ->
    if infer_exp_type env cond <> BoolType
    then failwith "Condition of if must be bool";
    ignore (check_stmt_seq env then_body);      (* 内层作用域：检查但丢弃返回的 env *)
    (match else_body with
     | Some stmts -> ignore (check_stmt_seq env stmts)
     | None -> ());
    env                                          (* 返回原 env，内层定义不外泄 *)

  | RepeatStmt (body, cond) ->
    let inner = check_stmt_seq env body in       (* body 的定义对 cond 可见，先检查循环体 *)
    if infer_exp_type inner cond <> BoolType     (* 所以 cond 在 inner 里查 *)
    then failwith "Condition of repeat must be bool";
    env                                          (* 但不外泄 *)

  | PrintStmt e ->
    let _ = infer_exp_type env e in
    env

(*推断表达式类型*)
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
       if left_type = IntType && right_type = IntType then IntType
       else failwith "Operands of arithmetic must be int"
     | LtOp | EqOp ->
       if left_type = right_type
       then BoolType
       else failwith "Operands of comparison must be of same type")
;;
