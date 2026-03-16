(*给定一个数x，判断其是否为质数*)
let rec is_prime_helper x i=
    if i=1 then true
    else
      (x mod i <> 0) && (is_prime_helper x (i-1))

let is_prime x =
  is_prime_helper x (x-1)