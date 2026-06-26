(*4.语法分析*)
(** Recursive descent parser for ToyLang *)
 
open Ast
open Parser_yacc (* Reuse token definition from yacc parser *)
open Token

let (next_token : token ref) = ref EOF
let (lexbuf : Lexing.lexbuf ref) = ref (Lexing.from_string "")

(** Helper functions *)


(*向前读一个token*)
let advance_token () : unit = next_token := Lexer.read !lexbuf

let expect (token : token) : unit =
  if !next_token = token
  then advance_token ()
  else
    failwith
      (Printf.sprintf
         "Expected %s but found %s"
         (string_of_token token)
         (string_of_token !next_token))
;;

(** Core parsing logic according to the grammar *)

let rec parse_program () : program = parse_stmt_seq ()

and parse_stmt_seq () : stmt_seq =
  match !next_token with
  | IF | REPEAT | PRINT | ID _ ->
    let stmt = parse_stmt () in
    expect SEMICOLON;   (*expect函数进行模式匹配,成功就调用advance_token函数，失败了就报错*)
    stmt::parse_stmt_seq()  (*吃完分号继续看下一条*)
    (*每解析完「一条语句 + 分号」，就再回头看 next_token 是不是又一条语句的开头*)
    (* TODO: Handle statement sequence with multiple statements *)
  | _ -> []

and parse_stmt () : stmt =
  match !next_token with
  | IF -> parse_if_stmt ()
  | REPEAT -> parse_repeat_stmt ()
  | PRINT -> parse_print_stmt ()
  | ID _ -> parse_assign_stmt ()
  | _ ->
    failwith
      (Printf.sprintf "Expected statement but found %s" (string_of_token !next_token))

and parse_if_stmt () : stmt =
  expect IF;
  let cond = parse_exp () in
  expect THEN;
  let then_body = parse_stmt_seq () in
  (match !next_token with
   | ELSE -> advance_token ();   (*advance_token是自定义函数，读取后一个字符*)
             let else_body = parse_stmt_seq () in
             expect END; IfStmt (cond, then_body, Some else_body)
   | _    -> expect END; IfStmt (cond, then_body, None))



and parse_repeat_stmt () : stmt =
  expect REPEAT;
  let body = parse_stmt_seq () in
  expect UNTIL;
  let cond = parse_exp () in
  RepeatStmt (body, cond)



and parse_print_stmt () : stmt =
  expect PRINT;
  PrintStmt (parse_exp ())




and parse_assign_stmt () : stmt =
  let lval =
    match !next_token with
    | ID name ->
      advance_token ();
      name
    | _ ->
      failwith
        (Printf.sprintf "Expected identifier but found %s" (string_of_token !next_token))
  in
  expect ASSIGN;
  let rval = parse_exp () in
  AssignStmt (lval, rval)




and parse_exp () : exp =                         (* exp 比 simple_exp 多一层比较 *)
  let left = parse_simple_exp () in
  (match !next_token with
   | LT -> advance_token (); BinaryExp (left, LtOp, parse_simple_exp ())
   | EQ -> advance_token (); BinaryExp (left, EqOp, parse_simple_exp ())
   | _  -> left)



and parse_simple_exp () : exp =
  let rec parse_rest left =
    match !next_token with
    | PLUS ->
      advance_token ();
      let right = parse_term () in
      parse_rest (BinaryExp (left, AddOp, right))
    | MINUS ->
      advance_token ();
      let right = parse_term () in
      parse_rest (BinaryExp (left, SubOp, right))
    | _ -> left
  in
  let left = parse_term () in
  parse_rest left




and parse_term () : exp =
  let rec parse_rest left =
    match !next_token with
    | TIMES ->
      advance_token ();
      let right = parse_factor () in
      parse_rest (BinaryExp (left, MulOp, right))
    | DIVIDE ->
      advance_token ();
      let right = parse_factor () in
      parse_rest (BinaryExp (left, DivOp, right))
    | _ -> left
  in
  let left = parse_factor () in
  parse_rest left




and parse_factor () : exp =
  match !next_token with
  | LPAREN -> advance_token ();
              let e = parse_exp () in expect RPAREN; e
  | NUM n  -> advance_token (); IntExp n
  | ID s   -> advance_token (); VarRefExp s
  | TRUE   -> advance_token (); BoolExp true
  | FALSE  -> advance_token (); BoolExp false
  | _ -> failwith (Printf.sprintf "Expected factor but found %s"
                     (string_of_token !next_token))

(** Entry function *)

let parse (_lexbuf : Lexing.lexbuf) : program =
  (* Set the global lexbuf *)
  lexbuf := _lexbuf;
  (* Set next_token to the first token *)
  advance_token ();
  (* Parse the program *)
  let ast = parse_program () in
  expect EOF;
  ast
;;
