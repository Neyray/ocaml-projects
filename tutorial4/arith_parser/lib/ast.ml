(*ast.ml*)
(*定义AST类型*)
type term=
  | TmTrue
  | TmFalse
  | TmIf of term * term * term
  | TmZero
  | TmSucc of term
  | TmPred of term
  | TmIsZero of term

let rec print_ast = function
  | TmTrue        -> "true"
  | TmFalse       -> "false"
  | TmZero        -> "0"
  | TmSucc t      -> "(succ " ^ print_ast t ^ ")"
  | TmPred t      -> "(pred " ^ print_ast t ^ ")"
  | TmIsZero t    -> "(iszero " ^ print_ast t ^ ")"
  | TmIf(t1,t2,t3) ->
      "(if " ^ print_ast t1 ^
      " then " ^ print_ast t2 ^
      " else " ^ print_ast t3 ^ ")"