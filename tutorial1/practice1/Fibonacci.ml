(*实现Fibonacci函数*)
let rec fib n =
  if n<0 then failwith "n should be non-negative"
  else if n=0 then 0
  else if n=1 then 1
  else fib(n-1) + fib(n-2)

let()=
   let number = 19 in
   let result = fib number in
   Printf.printf "hello,jerico! Fibonacci %d's result: %d" number result

