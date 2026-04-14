exception NegativeNumber

let rec factorial n =
  if n<0 then raise NegativeNumber
  else if n=0 then 1
  else n*factorial(n-1)

let () =
  try
    let result=factorial(-5) in
    Printf.printf("Result:%d\n") result
  with
  | NegativeNumber -> 
      Printf.eprintf "Error: Negative input to factorial!\n"
  | exn ->
    Printf.eprintf "Unexpected error: %s\n" (Printexc.to_string exn);
    raise exn  (* 重新抛出未处理的异常 *)
