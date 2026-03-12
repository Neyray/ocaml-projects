let fact x =
  let rec fact_tail x acc =
    if x = 0 then 
      acc
    else 
      (fact_tail (x - 1) (x * acc) [@tailcall]) (* 注意这里的括号 *)
  in (* 内部函数定义需要用 in *)
  fact_tail x 1

let () =
  Printf.printf "5 的阶乘 (尾递归): %d\n" (fact 5)

  (*尾递归：由于递归调用是函数的最后一个动作，编译器意识到当前函数的栈帧已经不再需要了。*)
  (*编译器不会开辟新的栈帧，而是直接复用当前的栈帧，或者将其转换成类似于 while 或 for 的迭代（Iteration）结构。*)
  (*无论递归运行多少次（哪怕是无限次），它始终只占用固定大小的内存空间*)