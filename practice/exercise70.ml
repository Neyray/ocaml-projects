(*70.TAPL 算术语言：设计 AST 和 parser 入口*)
(* ==========================================
   第一问：定义 AST 类型 term
   ========================================== *)

   (*这个token实际上是parser自己定义的字符，ast是最终要表示出来的字符，省略了lexer的作用（把输入字符串转化为token类型）*)
type term =
  | TmTrue
  | TmFalse
  | TmIf of term * term * term
  | TmZero
  | TmSucc of term
  | TmPred of term
  | TmIsZero of term

(* 给定的 Token 类型 *)
type token =
  | TRUE
  | FALSE
  | IF
  | THEN
  | ELSE
  | ZERO
  | SUCC
  | PRED
  | ISZERO
  | EOF

(* ==========================================
   第二问：设计递归下降 Parser
   ========================================== *)

let rec parseT tokens =
  match tokens with
  | TRUE :: rest -> 
      Some (TmTrue, rest)

  | FALSE :: rest -> 
      Some (TmFalse, rest)

  | ZERO :: rest -> 
      Some (TmZero, rest)

  | SUCC :: rest -> begin
      match parseT rest with
      | Some (t, rest1) -> Some (TmSucc t, rest1)
      | None -> None
    end

  | PRED :: rest -> begin
      match parseT rest with
      | Some (t, rest1) -> Some (TmPred t, rest1)
      | None -> None
    end

  | ISZERO :: rest -> begin
      match parseT rest with
      | Some (t, rest1) -> Some (TmIsZero t, rest1)
      | None -> None
    end

  | IF :: rest -> begin
      (* 1. 解析 if 后面的条件表达式 *)
      match parseT rest with
      | Some (t_cond, THEN :: rest1) -> begin
          (* 2. 确保成功匹配并消耗 THEN，接着解析 then 分支 *)
          match parseT rest1 with
          | Some (t_then, ELSE :: rest2) -> begin
              (* 3. 确保成功匹配并消耗 ELSE，接着解析 else 分支 *)
              match parseT rest2 with
              | Some (t_else, rest3) -> Some (TmIf (t_cond, t_then, t_else), rest3)
              | None -> None
            end
          | _ -> None (* 缺少 ELSE 或者 then 分支解析失败 *)
        end
      | _ -> None (* 缺少 THEN 或者 条件分支解析失败 *)
    end

  | _ -> None

(* 最终入口函数：只有当剩余 Token 刚好是 [EOF] 时才算完全解析成功 *)
let parse tokens =
  match parseT tokens with
  | Some (t, [EOF]) -> Some t
  | _ -> None