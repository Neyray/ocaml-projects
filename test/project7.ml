(*7.Limited Set.Make*)
module type LIMIT_TYPE = sig
  val max_limit : int
end

module type LIMITED_SET = sig
  type t
  val empty : t
  val add : int -> t -> t
  val elements : t -> int list
end


module Make (L:LIMIT_TYPE) : LIMITED_SET= struct
  type t= int list
  let empty=[]
  let add n lst=
  if List.length lst >= L.max_limit then lst
  else begin
    let rec aux acc n lst=
    match lst with
    | [] -> List.rev (n::acc)
    | x::t -> if x<n then aux (x::acc) n t
    else if x=n then (List.rev acc)@lst 
    else (List.rev (n::acc))@lst 
  in aux [] n lst
  end 

  let elements n=n 
end