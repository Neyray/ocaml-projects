(*parser.ml*)
(*写递归下降Parser*)
open Ast
open Token

(* 返回 (term, 剩余tokens) *)
let rec parse_term tokens=
  match tokens with
  | TRUE :: rest -> (TmTrue,rest)
  | FALSE :: rest -> (TmFalse,rest)
  | ZERO :: rest -> (TmZero,rest)
  | IF :: rest ->
      (* if t1 then t2 else t3 *)
      let (t1,rest1)=parse_term rest in
      (match rest1 with
      | THEN :: rest2 ->
          let (t2,rest3)=parse_term rest2 in
          (match rest3 with
          | ELSE :: rest4 ->
              let (t3,rest5)=parse_term rest4 in
              (TmIf(t1,t2,t3),rest5)
          | _ -> failwith "expected 'else'")
      | _ -> failwith "expected 'then'")
  | SUCC ::rest ->
    let (t,rest') =parse_term rest in
    (TmSucc t,rest')
  | PRED :: rest ->
    let (t,rest')=parse_term rest in
    (TmPred t,rest')
  | ISZERO :: rest ->
    let (t,rest')=parse_term rest in
    (TmIsZero t,rest')
  | _ -> failwith "unexpected token"

let parse tokens=
  let (term,remaining)=parse_term tokens in
  match remaining with
  | [] | [EOF] -> term
  | _ -> failwith "unexpected tokens after expression"