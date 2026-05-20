open Simpl_riscv
open Ast

let rec string_of_expr (e : expr) : string = 
  match e with
  | Int n -> Printf.sprintf "Int %d" n
  | Var id -> Printf.sprintf "Var %s" id
  | Bool b -> 
    let b_str = 
      match b with 
      | true -> "true"
      | false -> "false"
    in
    Printf.sprintf "Bool %s" b_str
  | Binop (binop, e1, e2) ->
    let binop_str = 
      match binop with 
      | Add -> "Add"
      | Mul -> "Mul"
      | Sub -> "Sub"
      | Div -> "Div"
      | Leq -> "Leq"
    in
    Printf.sprintf "Binop (%s, %s, %s)" binop_str (string_of_expr e1) (string_of_expr e2)
  | Let (var, e1, e2) -> Printf.sprintf "Let (%s, %s, %s)" var (string_of_expr e1) (string_of_expr e2)
  | If (e1, e2, e3) -> Printf.sprintf "If (%s, %s, %s)" (string_of_expr e1) (string_of_expr e2) (string_of_expr e3)
  | Func (var, e) -> Printf.sprintf "Func (%s, %s)" var (string_of_expr e)
  | App (e1, e2) -> Printf.sprintf "App (%s, %s)" (string_of_expr e1) (string_of_expr e2)

let parse s : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.main Lexer.read lexbuf in
  ast


(* 全局标签计数器，用于生成唯一标签 *)
let label_count = ref 0
let fresh_label prefix = 
  incr label_count;
  Printf.sprintf "%s_%d" prefix !label_count

(* 全局列表：保存所有生成的函数代码，最终附加在程序末尾 *)
let functions : string list ref = ref []

(* 简单的自由变量分析（不去重，仅适用于教学示例） *)
let rec free_vars expr bound = 
  match expr with
  | Int _ | Bool _ -> []
  | Var x -> if List.mem x bound then [] else [x]
  | Binop (_, e1, e2) -> free_vars e1 bound @ free_vars e2 bound
  | Let (x, e1, e2) -> free_vars e1 bound @ free_vars e2 (x :: bound)
  | If (cond, e_then, e_else) ->
    free_vars cond bound @ free_vars e_then bound @ free_vars e_else bound
  | Func (x, body) -> free_vars body (x :: bound)
  | App (e1, e2) -> free_vars e1 bound @ free_vars e2 bound

(*
  compile_expr env cur_offset expr
  env: (variable, offset) 的关联列表，其中 offset 是相对于 fp 的偏移（单位：字节）
  cur_offset: 当前已经分配的 let 变量字节数（每个变量占 8 字节）
  返回的汇编代码保证计算结果存放在寄存器 a0 中
*)
let rec compiler_expr (env : (string * int) list) (cur_offset : int) (expr : expr) : string = 
  match expr with
  | Int n -> 
    Printf.sprintf "\tli a0, %d\n" n
  | Bool b ->
    if b then "\tli a0, 1\n" else "\tli a0, 0\n"
  | Var x ->
    (try
      let offset = List.assoc x env in
      Printf.sprintf "\tld a0, -%d(fp)\n" offset
    with Not_found ->
      failwith ("Unbound variable: " ^ x))
  | Binop (op, e1, e2) ->
    let code1 = compiler_expr env cur_offset e1 in 
    let push_left = "\taddi sp, sp, -8\n\tsd a0, 0(sp)\n" in
    let code2 = compiler_expr env cur_offset e2 in
    let pop_left = "\tld t0, 0(sp)\n\taddi sp, sp, 8\n" in
    let op_code = match op with
      | Add -> "\tadd a0, t0, a0\n"
      | Sub -> "\tsub a0, t0, a0\n"
      | Mul -> "\tmul a0, t0, a0\n"
      | Div -> "\tdiv a0, t0, a0\n"
      | Leq -> "Not implemented"
    in
    code1 ^ push_left ^ code2 ^ pop_left ^ op_code
  | Let (x, e1, e2) ->
    let code1 = compiler_expr env cur_offset e1 in
    let new_offset = cur_offset + 8 in
    let alloc = Printf.sprintf "\taddi sp, sp, -8\n\tsd a0, -%d(fp)\n" new_offset in
    let env' = (x, new_offset) :: env in
    let code2 = compiler_expr env' new_offset e2 in
    let free = "\taddi sp, sp, 8\n" in
    code1 ^ alloc ^ code2 ^ free
  | If (cond, e_then, e_else) ->
    let label_else = fresh_label "Lelse" in
    let label_end = fresh_label "Lend" in
    let code_cond = compiler_expr env cur_offset cond in
    let code_then = compiler_expr env cur_offset e_then in
    let code_else = compiler_expr env cur_offset e_else in
    code_cond ^ 
    Printf.sprintf "\tbeq a0, x0, %s\n" label_else ^
    code_then ^
    Printf.sprintf "\tj %s\n" label_end ^
    Printf.sprintf "%s:\n" label_else ^
    code_else ^
    Printf.sprintf "%s:\n" label_end
  | Func (x, body) ->
    let fvs = free_vars body [x] in
    let num_free = List.length fvs in
    let func_id = fresh_label "func" in

    let local_env = [(x, 8)] in
    let closure_env = List.mapi (fun i v -> (v, 8 * i)) fvs in
    let func_body_code = compile_expr_func local_env closure_env 0 body in
    let func_prologue = 
      Printf.sprintf "%s:\n\taddi sp, sp, -16\n\tsd ra, 8(sp)\n\tsd fp, 0(sp)\n\tmv fp, sp\n" func_id
    in
    let func_epilogue = 
      "\tld ra, 8(sp)\n\tld fp, 0(sp)\n\taddi sp, sp, 16\n\tret\n"
    in
    let func_code = func_prologue ^ func_body_code ^ func_epilogue in
    functions := !functions @ [func_code];

    let closure_size = 8 * (1 + num_free) in
    let alloc_code = Printf.sprintf "\tli a0, %d\n\tjal ra, malloc\n" closure_size in
    let move_closure = "\tmv t0, a0\n" in
    let store_code_ptr = Printf.sprintf "\tla t1, %s\n\tsd t1, 0(t0)\n" func_id in
    let store_free_vars = 
      List.mapi (fun i v ->
        let outer_offset =
          try List.assoc v env with Not_found -> failwith ("Unbound free var: " ^ v)
        in
        Printf.sprintf "\tld t1, -%d(fp)\n\tsd t1, %d(t0)\n" outer_offset (8 * (i + 1))
      ) fvs |> String.concat ""
      in
    let ret_code = "\tmv a0, t0\n" in
    alloc_code ^ move_closure ^ store_code_ptr ^ store_free_vars ^ ret_code
  | App (e1, e2) ->
    let code_f = compiler_expr env cur_offset e1 in
    let save_closure = "\tmv t0, a0\n" in
    let code_arg = compiler_expr env cur_offset e2 in
    let load_env = "\taddi a1, t0, 8\n" in
    let load_code_ptr = "\tld t1, 0(t0)\n" in
    let call = "\tjalr ra, 0(t1)\n" in
    code_f ^ save_closure ^ code_arg ^ load_env ^ load_code_ptr ^ call

and compile_expr_func (local_env : (string * int) list) (closure_env : (string * int) list) (cur_offset : int) (expr : expr) : string =
  match expr with
  | Int n -> 
    Printf.sprintf "\tli a0, %d\n" n
  | Bool b ->
    if b then "\tli a0, 1\n" else "\tli a0, 0\n"
  | Var x ->
    if List.mem_assoc x local_env then
      Printf.sprintf "\tld a0, -%d(fp)\n" (List.assoc x local_env)
    else if List.mem_assoc x closure_env then
      Printf.sprintf "\tld a0, %d(a1)\n" (List.assoc x closure_env)
    else
      failwith ("Unbound variable in function: " ^ x)
  | Binop (op, e1, e2) ->
    let code1 = compile_expr_func local_env closure_env cur_offset e1 in
    let push_left = "\taddi sp, sp, -8\n\tsd a0, 0(sp)\n" in
    let code2 = compile_expr_func local_env closure_env cur_offset e2 in
    let pop_left = "\tld t0, 0, 0(sp)\n\taddi sp, sp, 8\n" in
    let op_code = match op with
      | Add -> "\tadd a0, t0, a0\n"
      | Sub -> "\tsub a0, t0, a0\n"
      | Mul -> "\tmul a0, t0, a0\n"
      | Div -> "\tdiv a0, t0, a0\n"
      | Leq -> "Not implemented"
    in
    code1 ^ push_left ^ code2 ^ pop_left ^ op_code
  | If _ -> failwith "Not implemented"
  | Func _ | App _ -> failwith "Nested functions not supported in function bodies" 

let compiler_program (e : expr) : string =
  let body_code = compiler_expr [] 0 e in
  let prologue = 
    ".text\n\
    .global main\n\
    main:\n\
    \taddi sp, sp, -64\n\
    \tmv fp, sp\n"
  in
  let epilogue = 
    "\
    \tmv sp, fp\n\
    \taddi sp, sp, 64\n\
    \tret\n"
  in
  let func_code = String.concat "\n" !functions in
  prologue ^ body_code ^ epilogue ^ "\n" ^ func_code
  
let () =
  let filename = "test/simpl_test4.in" in
  (* let filename = "test/simpl_test2.in" in *)
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;

  (* let res = interp file_content in
  Printf.printf "Result of interpreting %s:\n%s\n\n" filename res;

  let res = interp_big file_content in
  Printf.printf "Result of interpreting %s with big-step model:\n%s\n\n" filename res; *)

  let ast = parse file_content in 
  Printf.printf "AST: %s\n" (string_of_expr ast);

  let output_file = Sys.argv.(1) in
  let oc = open_out output_file in

  let asm_code = compiler_program ast in

  output_string oc asm_code;
  close_out oc;
  Printf.printf "Generated RISC-V code saved to: %s\n" output_file