(* Higher-order functions *)

let double x = 2 * x
let square x = x * x

let quad x = 4 * x
let quad' x = double (double x)
let quad'' x = x |> double |> double

let fourth x = x * x * x * x
let fourth' x = square (square x)
let fourth'' x = x |> square |> square

(* Note repeated code: applying a function twice.
   Let's write a function for that. *)

let twice f x = f (f x)  
(* : ('a -> 'a) -> 'a -> 'a 
   takes a function as input *)
let twice' f x = x |> f |> f

let quad''' x = twice double x
let fourth''' x = twice square x

(* The argument is unnecessary thanks to partial application: produce
   a function as output. *)

let quad'''' = twice double
let fourth'''' = twice square

(* Map *)

let rec add1 = function
  | [] -> []
  | h :: t -> (h + 1) :: add1 t

let rec concat3110 = function
  | [] -> []
  | h :: t -> (h ^ "3110") :: concat3110 t

(* Factor out repeated code... *)

let rec map f = function
  | [] -> []
  | h :: t -> f h :: map f t

let add1' = map (fun x -> x + 1)
let add1'' = map ((+) 1)
let concat3110' = map (fun x -> x ^ "3110")
let concat3110'' = map ((^) "3110") (* wrong: does not append; prepends *)

(* Combine *)

let rec sum = function
  | [] -> 0
  | h :: t -> h + sum t

let rec concat = function
  | [] -> ""
  | h :: t -> h ^ concat t

(* Factor out repeated code... *)

let rec combine init op = function
  | [] -> init
  | h :: t -> op h (combine init op t)

let sum' = combine 0 (+)
let concat' = combine "" (^)

(* Fold *)

let rec fold_right f lst acc =
  match lst with 
  | [] -> acc
  | h :: t -> 
    f h (fold_right f t acc)

let rec fold_left f acc lst =
  match lst with 
  | [] -> acc
  | h :: t ->
    fold_left f (f acc h) t

(* Those are available in the List module of the standard library 
   as List.fold_left and List.fold_right *)
