let rec list_max lst =
  match lst with
   | [] -> failwith "empty list!"
   | [x] -> x
   | h :: t -> max h (list_max t)

