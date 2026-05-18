type binop =
  | Add
  | Sub
  | Mul
  | Leq

type expr =
  | Int of int
  | Bool of bool
  | Var of string
  | Binop of binop * expr * expr
  | If of expr * expr * expr
  | Let of string * expr * expr
