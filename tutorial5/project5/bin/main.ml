open Interpreterlib
open Ast

(*修改12：Task 5 加入 Fun / App 的可视化*)
let rec string_of_expr (e : expr) : string =
  match e with
  | Int n -> Printf.sprintf "Int %d" n
  | Bool b -> Printf.sprintf "Bool %b" b
  | Var x -> Printf.sprintf "Var %s" x
  | Binop (binop, e1, e2) ->
    let binop_str =
      match binop with
      | Add -> "Add"
      | Sub -> "Sub"
      | Mul -> "Mul"
      | Leq -> "Leq"
    in
    Printf.sprintf "Binop (%s, %s, %s)"
      binop_str (string_of_expr e1) (string_of_expr e2)
  | If (e1, e2, e3) ->
    Printf.sprintf "If (%s, %s, %s)"
      (string_of_expr e1) (string_of_expr e2) (string_of_expr e3)
  | Let (x, e1, e2) ->
    Printf.sprintf "Let (%s, %s, %s)"
      x (string_of_expr e1) (string_of_expr e2)
  (*修改12*)
  | Fun (x, e) ->
    Printf.sprintf "Fun (%s, %s)" x (string_of_expr e)
  | App (e1, e2) ->
    Printf.sprintf "App (%s, %s)" (string_of_expr e1) (string_of_expr e2)

let parse s : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.main Lexer.read lexbuf in
  ast


(* Small-step semantics *)

(*修改13：Task 5 — Fun 自身就是 value (lambda 抽象本身就是值)*)
let is_value : expr -> bool = function
  | Int _ | Bool _ | Fun _ -> true
  | _ -> false


(*修改14：Task 5 — 生成新鲜变量名，用于 capture-avoiding subst*)
(* gensym () 每次返回 "$x1", "$x2", "$x3"... 保证全局唯一 *)
let gensym =
  let counter = ref 0 in
  fun () -> incr counter; "$x" ^ string_of_int !counter

(*修改15：Task 5 — 计算自由变量集合 FV(e)
   FV(x)          = {x}
   FV(i) = FV(b)  = {}
   FV(e1 bop e2)  = FV(e1) ∪ FV(e2)
   FV(if/let/app) = 子表达式 FV 之并（let / fun 要去掉绑定变量）
   FV(fun x -> e) = FV(e) \ {x}
   返回 string list（去重）*)
let rec fv (e : expr) : string list =
  let union a b = List.fold_left (fun acc x -> if List.mem x acc then acc else x :: acc) a b in
  let remove x lst = List.filter (fun y -> y <> x) lst in
  match e with
  | Int _ | Bool _ -> []
  | Var x -> [x]
  | Binop (_, e1, e2) -> union (fv e1) (fv e2)
  | If (e1, e2, e3) -> union (union (fv e1) (fv e2)) (fv e3)
  | Let (x, e1, e2) -> union (fv e1) (remove x (fv e2))
  | Fun (x, e) -> remove x (fv e)
  | App (e1, e2) -> union (fv e1) (fv e2)


(*修改4（保留）*)
(** [subst e v x] is [e{v/x}]，即把 e 里所有 x 替换成 v。
    Task 3 阶段先放占位，让上层的 Let 规则可以调它；真正实现留到 Task 4。*)
(*修改7（保留）：Task 4 把上面的占位换成真正的代换实现*)
(*修改16：Task 5 — 给 subst 扩展 App / Fun 分支，并对 Fun 做 capture-avoiding*)
let rec subst (e : expr) (v : expr) (x : string) : expr =
  match e with
  (* 常量没有变量可替换，原样返回 *)
  | Int _ | Bool _ -> e
  (* 同名变量 x：替换成 v；不同名变量 y：保持不动 *)
  | Var y when y = x -> v
  | Var _ -> e
  (* 二元运算与 if：递归对每个子表达式做替换 *)
  | Binop (op, e1, e2) -> Binop (op, subst e1 v x, subst e2 v x)
  | If (e1, e2, e3) -> If (subst e1 v x, subst e2 v x, subst e3 v x)
  (* let 语句要看绑定变量名：
     - 若绑定的就是 x，e2 里的 x 已被 shadow，只替换 e1
     - 否则，e1 e2 都要替换 *)
  | Let (y, e1, e2) when y = x -> Let (y, subst e1 v x, e2)
  | Let (y, e1, e2) -> Let (y, subst e1 v x, subst e2 v x)
  (*修改16：App 直接对两边都做替换*)
  | App (e1, e2) -> App (subst e1 v x, subst e2 v x)
  (*修改16：Fun 三种情况
     1. 绑定的就是 x  ：x 已被 shadow，停止替换
     2. 绑定的 y ∉ FV(v)：安全，直接进入函数体替换
     3. 绑定的 y ∈ FV(v)：会发生 capture！先把 y 重命名成 fresh y'，再继续替换*)
  | Fun (y, body) when y = x -> Fun (y, body)
  | Fun (y, body) when not (List.mem y (fv v)) ->
      Fun (y, subst body v x)
  | Fun (y, body) ->
      (* y 出现在 v 的自由变量里：先 α-rename *)
      let y' = gensym () in
      let body' = subst body (Var y') y in
      Fun (y', subst body' v x)


let rec step : expr -> expr = function
  | Int _ | Bool _ | Fun _ -> failwith "Does not step on a value"  (*修改13：Fun 也是 value*)
  | Var _ -> failwith "Unbound variable"
  | Binop (binop, e1, e2) when is_value e1 && is_value e2 ->
    step_binop binop e1 e2
  | Binop (binop, e1, e2) when is_value e1 -> Binop (binop, e1, step e2)
  | Binop (binop, e1, e2) -> Binop (binop, step e1, e2)
  (*修改1（保留）*)
  | If (e1,e2,e3) when is_value e1 -> (match e1 with   (*只有is_value的才能进行判断*)
                                                        | Bool true -> e2
                                                        | Bool false -> e3(*这里用的是parser里的expr！也就是ast*)  (*之所以直接返回e2,e3是因为eval函数对不是value的值再次进行了step调用*)
                                                        | _ -> failwith "If condition must be a boolean") (*！！！用括号把内部match包起来，防止下面的分支被吞并；同时补全Int等非Bool情形*)
  | If (e1,e2,e3) -> If(step e1,e2,e3)   (*别的需要先对e1进行处理*)
  (*修改5（保留）*)
  (* let x = v1 in e2 --> e2{v1/x}：e1 已经是值，做代换 *)
  | Let (x, e1, e2) when is_value e1 -> subst e2 e1 x
  (* let x = e1 in e2 --> let x = e1' in e2：e1 还能 step，先 step e1 *)
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  (*修改17：Task 5 — small-step 对 App 的规则
     I. (fun x -> e) v2  --> e{v2/x}   两边都是值时，做 beta-reduction
     II. v1 e2 --> v1 e2'              左侧已是值，step 右侧
     III. e1 e2 --> e1' e2             否则 step 左侧 *)
  | App (Fun (x, body), v2) when is_value v2 -> subst body v2 x
  | App (e1, e2) when is_value e1 -> App (e1, step e2)
  | App (e1, e2) -> App (step e1, e2)

  (*small,big最大的区别就是这个辅助函数有没有递归调用step本身*)
  (*small需要一步步化完之后才能进行计算*)
and step_binop binop v1 v2 = match binop, v1, v2 with
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"

(* fully evaluate [e] to a value [v] *)
let rec eval (e : expr) : expr =
  if is_value e then e else
    e |> step |> eval

let interp (s : string) : string =
  s |> parse |> eval |> string_of_expr


(* Big-step semantics *)
(*都是parser生成的ast*)
let rec eval_big (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  (*不需要在eval_big函数化完，直接调用辅助函数，在辅助函数里再调用本身直接递归出最后结果*)
  | Binop (binop, e1, e2) -> eval_bop binop e1 e2(*直接调用计算函数eval_bop*)
  (*修改2（保留）*)
  | If (e1,e2,e3) -> eval_bop2 e1 e2 e3
  (*修改6（保留）*)
  (* let x = e1 in e2 ==> v2，需要 e1 ==> v1 且 e2{v1/x} ==> v2 *)
  | Let (x, e1, e2) ->
    let v1 = eval_big e1 in
    eval_big (subst e2 v1 x)
  (*修改18：Task 5 — big-step 对 lambda calculus
     Fun 直接返回自身（lambda 抽象是 value）
     App (e1, e2) 走 call-by-value：
       e1 ==> fun x -> body
       e2 ==> v2
       body{v2/x} ==> v
     上面三步合起来记为 e1 e2 ==> v *)
  | Fun _ -> e
  | App (e1, e2) ->
    (match eval_big e1 with
     | Fun (x, body) ->
       let v2 = eval_big e2 in
       eval_big (subst body v2 x)
     | _ -> failwith "Cannot apply a non-function value")

(*专门为binop e1,e2服务*)
and eval_bop binop e1 e2 = match binop, eval_big e1, eval_big e2 with   (*在内部递归调用eval_big函数，递归直接得到最终结果，隐藏过程*)
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"

  (*修改3（保留）*)
(*为If e1,e2,e3服务*)
and eval_bop2 e1 e2 e3 = match eval_big e1 with
  | Bool true -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "If condition must be a boolean" (*补全非Bool情形，避免Match_failure*)

let interp_big (s : string) : string =
  s |> parse |> eval_big |> string_of_expr

(*修改8（保留）：跑一个测试文件，把小步、大步、AST 都打印出来*)
let run_one filename =
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;

  let res = interp file_content in
  Printf.printf "Result of interpreting %s:\n%s\n\n" filename res;

  let res = interp_big file_content in
  Printf.printf "Result of interpreting %s with big-step model:\n%s\n\n" filename res;

  let ast = parse file_content in
  Printf.printf "AST: %s\n\n" (string_of_expr ast)

(*修改19：Task 5 — lambda 专用版本，给可能 raise 的样例（如 sample 3）兜底*)
let run_lambda filename =
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;

  Printf.printf "=== %s ===\nSource: %s\n" filename file_content;
  (try
     let res = interp_big file_content in
     Printf.printf "Result (big-step): %s\n" res
   with Failure msg ->
     Printf.printf "Result (big-step): Failure(%s)\n" msg);
  (try
     let ast = parse file_content in
     Printf.printf "AST: %s\n\n" (string_of_expr ast)
   with Failure msg ->
     Printf.printf "AST: Failure(%s)\n\n" msg)

let () =
  run_one "test/simpl_test1.in";  (* let x = 3110 in x + x        --> Int 6220 *)
  run_one "test/simpl_test2.in";  (* 嵌套 let + if                 --> Int 7    *)
  (*修改19：跑 5 个 lambda 样例*)
  run_lambda "test/lambda_test1.in";  (* (fun x -> x) (fun y -> y)           --> Fun(y, Var y)        *)
  run_lambda "test/lambda_test2.in";  (* 三层应用                              --> Fun(a, Fun(b, Var b))*)
  run_lambda "test/lambda_test3.in";  (* 含未绑定 z                           --> Failure "Unbound variable" *)
  run_lambda "test/lambda_test4.in";  (* (fun y -> y + 1) 5                  --> Int 6   *)
  run_lambda "test/lambda_test5.in"   (* 含 let / if 的混合 lambda            --> Int 8   *)
