(* 定义了一个 “基类” People*)
module type PeopleSig = sig
 type person
 val create : string -> person
 val name : person -> string
end

module People : PeopleSig = struct
 type person = {name: string}
 let create n = {name = n}
 let name p = p.name
end


(* 定义了一个 “派生类” TeachAssisant，TeachAssisant 包含 People 所有的项，同时增加了一个
role 项*)
module type TeachAssisantSig = sig
 include PeopleSig
 val role : person -> string
end

module TeachAssisant : TeachAssisantSig = struct
 include People
 let role p = "Teaching Assistant"
end


let ella = TeachAssisant.create "Ella"
let () = Printf.printf "%s is a %s\n" (TeachAssisant.name ella)
(TeachAssisant.role ella)