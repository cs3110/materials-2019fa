module type Monad = sig
  type 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val return : 'a -> 'a t
end

(* Example 1: Loggable functions *)

let inc x = x + 1
let dec x = x - 1

let (>>) f g x = x |> f |> g

let id = inc >> dec

let inc_log x = (x + 1, "incremented " ^ string_of_int x ^ "; ")
let dec_log x = (x - 1, "decremented " ^ string_of_int x ^ "; ")

let _ = inc_log 42;;
let _ = dec_log 42;;

(* let id_log = inc_log >> dec_log *)
(* 5 |> inc_log |> inc_log *)

let id_log x =
  let (y, s1) = inc_log x in
  let (z, s2) = dec_log y in
  (z, s1^s2)

let upgrade f_log (x,s1) =
  let (y, s2) = f_log x in
  (y, s1 ^ s2)

let id_log = inc_log >> (upgrade dec_log)

let trivial x = (x, "")
let lift f = f >> trivial

module Loggable : Monad = struct
  type 'a t = 'a * string
  let bind (x, s1) f =
    let (y, s2) = f x in
    (y, s1 ^ s2)
  let return x = (x, "")
end

(* Example 2: Functions that produce errors *)

type 'a err = Val of 'a | Err
let div x y = if y = 0 then Err else Val (x / y)
let neg x = Val ~-x

let neg_err = function
  | Err -> Err
  | Val x -> Val ~-x

let div_err x y =
  match x, y with
  | Err, _ | _, Err -> Err
  | Val a, Val b -> Val (a / b)

let (|>?) v f =
  match v with
  | Val x -> f x
  | Err -> Err

let neg_err' x =
  x |>? (fun a -> Val ~-a)

let neg_err' x =
  x |>? fun a -> 
  Val ~-a

let value x = Val x

let neg_err' x =
  x |>? fun a -> 
  value ~-a

let div_err' x y =
  x |>? fun a ->
  y |>? fun b ->
  value (a / b)

module Error : Monad = struct
  type 'a t = Val of 'a | Err
  let return x = Val x
  let bind m f =
    match m with
    | Val x -> f x
    | Err -> Err
end
