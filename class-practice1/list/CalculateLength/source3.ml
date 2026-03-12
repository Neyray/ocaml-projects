(*进行过尾递归优化的版本2*)
let length lst=
    (*创建尾递归的版本一般都是要新建一个函数，包含两个变量---核心变量x,中间计算变量acc*)
    let rec len sum lst=
      match lst with
      | [] -> sum
      | _ :: t -> len (sum+1) lst
    in len 0 lst

    
let () =
  Printf.printf "source3 长度: %d\n" (length [1; 2; 3; 4; 5])