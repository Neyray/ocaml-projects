type expr = 
  | Const of int(*整数常量*)
  | Add of expr*expr(*加法运算*)
  | Sub of expr*expr(*减法运算*)
  (*Const,Add,Sub都是expr类型，只不过传入的参数不同*)
  | Mul of expr*expr(*乘法运算*)
  | Div of expr*expr(*除法运算*)

  (*int option有两个构造器：None,Some 42---表示有值*)
  (*int option 是 option 填入 int 之后得到的具体类型。*)
let rec evaluate : expr -> int option = fun e ->
  match e with
  | Const n -> Some n
  | Add (e1, e2) ->
    (*match的对象是求值后的结果*)
    (match evaluate e1, evaluate e2 with
     | Some v1, Some v2 -> Some (v1 + v2)
     | _ -> None)
  | Sub (e1, e2) ->
    (match evaluate e1, evaluate e2 with
     | Some v1, Some v2 -> Some (v1 - v2)
     | _ -> None)(*如果存在一个None，那么直接返回None*)
  | Mul (e1, e2) ->
    (match evaluate e1, evaluate e2 with
     | Some v1, Some v2 -> Some (v1 * v2)
     | _ -> None)
  | Div (e1, e2) ->
    (match evaluate e1, evaluate e2 with
     | Some v1, Some v2 ->
       if v2 = 0 then None      (* 除以零返回 None *)
       else Some (v1 / v2)
     | _ -> None)


let()=
  let expr = Add (Const 3, Mul (Const 2, Const 5)) in
  let result = evaluate expr in
  match result with
  | Some v -> Printf.printf("Result:%d\n") v
  | None -> Printf.printf("Error result")