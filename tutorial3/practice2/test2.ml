(*定义异常*)
exception InvalidDeposit
exception InsufficientFunds
exception InvalidWithdrawal

type transaction=
  | Deposit of int(*存款*)
  | Withdrawal of int(*取款*)

(*账户类型*)
type bank_account={
  name:string;
  id:int;
  mutable balance:int;
  (*这不是嵌套类型，只是把自定义类型当作列表的元素类型。相当于int list*)
  mutable transactions:transaction list;(*可以理解为C++的结构体数组*)
}

(*创建账号*)
let create_account name id={
  name;id;balance=0;transactions=[]
}

(*存款*)
let deposit:bank_account -> int -> unit =fun b amount ->
  if amount<0 then raise InvalidDeposit
  else begin
    b.balance <- b.balance+amount;
    b.transactions <- Deposit amount :: b.transactions
  end 

(*取款*)
let withdraw:bank_account -> int -> unit=fun b amount ->
  if amount<0 then raise InvalidWithdrawal
  else if amount>b.balance then raise InsufficientFunds
  else begin
    b.balance <- b.balance-amount;
    b.transactions <- Withdrawal amount :: b.transactions
  end 

(*查询余额*)
let get_balance : bank_account -> int=fun b->
  b.balance


(*打印流水*)
let print_transactions:bank_account -> unit=fun b->
  (*对列表里的每个元素，依次执行一个函数*)
  (*格式：List.iter fun list*)
  List.iter (fun t ->
    match t with 
    | Deposit msg -> Printf.printf "Deposit:+%d\n" msg
    | Withdrawal msg -> Printf.printf "Withdrawal:-%d\n" msg
  )(List.rev b.transactions)

(* 测试 *)
let () =
  let acc = create_account "Alice" 1 in
  deposit acc 100;
  deposit acc 50;
  withdraw acc 30;
  Printf.printf "Balance: %d\n" (get_balance acc);
  print_transactions acc;


  (* 测试异常 *)
  try deposit acc (-10)
  with InvalidDeposit -> print_endline "Error: invalid deposit amount";

  try withdraw acc 9999
  with InsufficientFunds -> print_endline "Error: insufficient funds"