open Toylanglib

(** Argument parsing *)

let usage = "Usage: toylang [options] <file>"
let file = ref ""
let parser_type = ref "yacc"
let print_ast = ref false
let check_types = ref false

let options =
  [ ( "--parser"
    , Arg.Symbol ([ "yacc"; "descent" ], fun s -> parser_type := s)
    , " Choose parser type: yacc or descent (default: yacc)" )
  ; ( "--print-ast"
    , Arg.Set print_ast
    , " Print the Abstract Syntax Tree (AST) instead of interpreting" )
  ; "--check-types", Arg.Set check_types, " Perform type checking instead of interpreting"
  ]
;;

let parse_args () =
  let anon_fun filename =
    if !file = ""
    then file := filename
    else raise (Arg.Bad "Only one input file can be specified")
  in
  Arg.parse options anon_fun usage;
  if !file = "" then raise (Arg.Bad "No input file specified")
;;

(** Main entry point of ToyLang *)

let () =
  try
    parse_args ();
    (* Open the file and create a lexing buffer *)
    let lexbuf = Lexing.from_channel (open_in !file) in
    (* Parse using the selected parser *)
    let ast =
      match !parser_type with
      | "yacc" -> Parser_yacc.program Lexer.read lexbuf
      | "descent" -> Parser_descent.parse lexbuf
      | _ -> assert false
    in
    (* Print, type-check, or interpret the AST *)
    if !print_ast
    then Printf.printf "%s\n" (Ast.string_of_program ast)
    else if !check_types
    then Typechecker.check_program ast
    else Interpreter.interpret_program ast
  with
  | Arg.Bad msg ->
    Printf.eprintf "%s: %s\n" Sys.argv.(0) msg;
    Arg.usage options usage;
    exit 2
  | Failure msg | Sys_error msg ->
    Printf.eprintf "Error: %s\n" msg;
    exit 1
  | e ->
    Printf.eprintf "Error: %s\n" (Printexc.to_string e);
    exit 1
;;
