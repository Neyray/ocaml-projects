(*68.左递归改写 + 递归下降*)
(* 假设已定义好相关的 token 和 expr 类型 *)
type binop = Add | Mul
type token = INT of int | PLUS | TIMES | LPAREN | RPAREN | EOF
type expr = Int of int | Binop of binop * expr * expr

(* 核心解析函数族 *)
let rec parseE tokens =
  (* E -> T E' *)
  match parseT tokens with
  | Some (e_left, rest) -> parseE_tail e_left rest
  | None -> None

and parseE_tail e_left tokens =
  (* E' -> + T E' | ε *)
  match tokens with
  | PLUS :: rest -> begin
      match parseT rest with
      | Some (e_right, rest1) -> 
          (* 将当前结合好的 Add 树作为新的左子树，继续向后传递 *)
          let new_left = Binop (Add, e_left, e_right) in
          parseE_tail new_left rest1
      | None -> None
    end
  | _ -> Some (e_left, tokens) (* ε 分支：不消耗 token，直接返回已有的左子树 *)

and parseT tokens =
  (* T -> F T' *)
  match parseF tokens with
  | Some (e_left, rest) -> parseT_tail e_left rest
  | None -> None

and parseT_tail e_left tokens =
  (* T' -> * F T' | ε *)
  match tokens with
  | TIMES :: rest -> begin
      match parseF rest with
      | Some (e_right, rest1) -> 
          (* 将当前结合好的 Mul 树作为新的左子树，继续向后传递 *)
          let new_left = Binop (Mul, e_left, e_right) in
          parseT_tail new_left rest1
      | None -> None
    end
  | _ -> Some (e_left, tokens) (* ε 分支 *)

and parseF tokens =
  (* F -> INT | '(' E ')' *)
  match tokens with
  | INT n :: rest -> 
      Some (Int n, rest)
  | LPAREN :: rest -> begin
      match parseE rest with
      | Some (e, RPAREN :: rest1) -> Some (e, rest1)
      | _ -> None
    end
  | _ -> None