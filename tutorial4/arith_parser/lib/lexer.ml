(*lexer.ml*)
(*手写词法分析*)
(*做真正的转换工作：字符串 → token list*)
open Token

let tokenize s =
  let words = String.split_on_char ' ' s
    |> List.concat_map (String.split_on_char '\n')
    |> List.filter (fun w -> w <> "") in
  List.map (function
    | "true"   -> TRUE
    | "false"  -> FALSE
    | "if"     -> IF
    | "then"   -> THEN
    | "else"   -> ELSE
    | "0"      -> ZERO
    | "succ"   -> SUCC
    | "pred"   -> PRED
    | "iszero" -> ISZERO
    | w -> failwith ("Unknown token: " ^ w)
  ) words