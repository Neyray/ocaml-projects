(** Abstract Syntax Tree for ToyLang *)

type program = stmt_seq
and stmt_seq = stmt list

(* Statements *)
and stmt =
  | IfStmt of
      exp * stmt_seq * stmt_seq option (* IF exp THEN stmt_seq [ELSE stmt_seq] END *)
  | RepeatStmt of stmt_seq * exp (* REPEAT stmt_seq UNTIL exp *)
  | AssignStmt of string * exp (* ID := exp *)
  | PrintStmt of exp (* PRINT exp *)

(* Expressions *)
and exp =
  | IntExp of int (* Integer literal (Non-negative integer) *)
  | BoolExp of bool (* Boolean literal (TRUE/FALSE) *)
  | VarRefExp of string (* Variable reference *)
  | BinaryExp of exp * binop * exp (* Binary operation *)

(* Binary operators *)
and binop =
  | AddOp (* Add, + *)
  | SubOp (* Subtract, - *)
  | MulOp (* Multiply, * *)
  | DivOp (* Divide, / *)
  | LtOp (* Less than, < *)
  | EqOp (* Equals, = *)

(** AST to string *)

let rec string_of_program (prog : program) = string_of_stmt_seq prog

and string_of_stmt_seq stmt_seq =
  String.concat ";\n" (List.map string_of_stmt stmt_seq) ^ ";"

and string_of_stmt = function
  | IfStmt (cond, then_body, else_body) ->
    "IF "
    ^ string_of_exp cond
    ^ " THEN\n    "
    ^ String.concat "\n    " (String.split_on_char '\n' (string_of_stmt_seq then_body))
    ^ "\n"
    ^ (match else_body with
       | Some stmts ->
         "ELSE\n    "
         ^ String.concat "\n    " (String.split_on_char '\n' (string_of_stmt_seq stmts))
         ^ "\n"
       | None -> "")
    ^ "END"
  | RepeatStmt (body, cond) ->
    "REPEAT\n    "
    ^ String.concat "\n    " (String.split_on_char '\n' (string_of_stmt_seq body))
    ^ "\n"
    ^ "UNTIL "
    ^ string_of_exp cond
  | AssignStmt (id, e) -> id ^ " := " ^ string_of_exp e
  | PrintStmt e -> "PRINT " ^ string_of_exp e

and string_of_exp = function
  | IntExp n -> string_of_int n
  | BoolExp true -> "TRUE"
  | BoolExp false -> "FALSE"
  | VarRefExp s -> s
  | BinaryExp (e1, op, e2) ->
    "(" ^ string_of_exp e1 ^ " " ^ string_of_binop op ^ " " ^ string_of_exp e2 ^ ")"

and string_of_binop = function
  | AddOp -> "+"
  | SubOp -> "-"
  | MulOp -> "*"
  | DivOp -> "/"
  | LtOp -> "<"
  | EqOp -> "="
;;
