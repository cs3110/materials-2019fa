(******************************************************)
(* Example 0: Simple functors                         *)
(******************************************************)

module type X = sig 
  val x : int
end

module IncX = functor (M : X) -> struct
  let x = M.x + 1
end

module A = struct let x = 0 end
module B = IncX(A) (* B.x is 1 *)
module C = IncX(B) (* C.x is 2 *)

(* Alternative syntax *)
module IncX (M : X) = struct
  let x = M.x + 1
end

(******************************************************)
(* Example 1: Parameterizing a test suite on a module *)
(******************************************************)

module type StackSig = sig
  type 'a t
  val empty : 'a t
  val push  : 'a -> 'a t -> 'a t
  val peek  : 'a t -> 'a
end

module ListStack : StackSig = struct
  type 'a t = 'a list
  let empty = []
  let push x s = x :: s
  let peek = function [] -> failwith "empty" | x::_ -> x
end

let _ = assert (ListStack.(empty |> push 1 |> peek) = 1)

module MyStack : StackSig = struct
  type 'a t = Empty | Entry of 'a * 'a t
  let empty = Empty
  let push x s = Entry (x, s)
  let peek = function Empty -> failwith "empty" | Entry(x,_) -> x
end

let _ = assert (MyStack.(empty |> push 1 |> peek) = 1)

(* Can we get rid of duplicated code in asserts? Yes! *)

module StackTester (S : StackSig) = struct
  let _ = assert (S.(empty |> push 1 |> peek) = 1)
end

module ListStackTester = StackTester(ListStack)
module MyStackTester = StackTester(MyStack)

(******************************************************)
(* Example 2: Parameterized collection.               *)
(******************************************************)

type day = Sun | Mon | Tue (* ... *)

let int_of_day = function
  | Sun -> 1
  | Mon -> 2
  | Tue -> 3

module DayKey = struct
  type t = day
  let compare day1 day2 =
    int_of_day day1 - int_of_day day2
end

module DayMap = Map.Make(DayKey)
open DayMap

let m = empty 
        |> add Sun "Sunday"
        |> add Mon "Monday"
let _ = assert (find Sun m = "Sunday")

(******************************************************)
(* Example 3: Rings and Fields                        *)
(******************************************************)

module type Ring = sig
  type t
  val zero  : t
  val one   : t
  val (+)   : t -> t -> t
  val ( * ) : t -> t -> t
  val (~-) : t -> t
  val to_string : t -> string
end

module type Field = sig
  include Ring
  val (/) : t -> t -> t
end

module FloatRingRep = struct 
  type t = float
  let zero = 0.
  let one = 1.
  let (+) = (+.)
  let (~-) = (~-.)
  let ( * ) = ( *. )
  let to_string = string_of_float
end

module FloatRing : Ring = FloatRingRep

module FloatField : Field = struct
  include FloatRingRep
  let (/) = (/.)
end
