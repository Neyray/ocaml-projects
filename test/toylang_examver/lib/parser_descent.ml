(** Recursive descent parser for ToyLang *)

open Ast
open Parser_yacc (* Reuse token definition from yacc parser *)
open Token

let (next_token : token ref) = ref EOF
let (lexbuf : Lexing.lexbuf ref) = ref (Lexing.from_string "")

(** Helper functions *)

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
    expect SEMICOLON;
    [ stmt ]
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

and parse_if_stmt () : stmt = failwith "TODO: Parse if statement"
and parse_repeat_stmt () : stmt = failwith "TODO: Parse repeat statement"
and parse_print_stmt () : stmt = failwith "TODO: Parse print statement"

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

and parse_exp () : exp = failwith "TODO: Parse expression"

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

and parse_factor () : exp = failwith "TODO: Parse factor"

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
