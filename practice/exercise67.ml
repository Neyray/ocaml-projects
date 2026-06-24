(*67.加法和乘法优先级*)
(*
E  -> T E'
E' -> + T E' | ε
T  -> F T'
T' -> * F T' | ε
F  -> INT | '(' E ')'
*)

(*parser类型*)
type token =
  | INT of int
  | PLUS
  | TIMES
  | LPAREN
  | RPAREN
  | EOF

(*ast类型*)
type expr =
  | Int of int
  | Add of expr * expr
  | Mul of expr * expr

let rec parseE tokens=
  match parseT tokens with
  (*由于parseE'需要e_left，自然而然地这里要写成Some (e_left,rest)*)
  | Some (e_left,rest) -> parseE' e_left rest
  | None -> None 

and parseE' e_left tokens=
  (*parseE'是+ T + T + T ...的形式*)
  match tokens with
  | PLUS::rest -> begin
    match parseT rest with
    | Some (e_right,rest1) -> parseE' (Add(e_left,e_right)) rest1 
    | None -> None
  end
  | _ -> Some (e_left,tokens)   (*表示空*)

and parseT tokens=
  match parseF tokens with
  | Some (e_left,rest) -> parseT' e_left rest
  | None -> None

and parseT' e_left tokens=
  match tokens with
  | TIMES::rest -> begin
    match parseF tokens with
    | Some (e_right,rest1) -> parseT' (Mul(e_left,e_right)) rest1
    | None -> None
  end
  | _ -> Some (e_left,tokens)

and parseF tokens=
  match tokens with
  | INT n::rest -> Some (Int n,rest)
  | LPAREN::rest1 -> begin
    match parseE rest1 with
    | Some (e,RPAREN::rest2) -> Some (e,rest2)
    | _ -> None
  end
  | _ -> None 