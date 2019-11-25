(* Recursive values *)

let rec loop x = loop x

let rec ones = 1 :: ones

let rec 
  a = 0 :: b
and 
  b = 1 :: a

(* Not yet right stream rep *)

type 'a stream =
  | Cons of 'a * 'a stream

let rec ones = Cons (1, ones)

let rec from n = 
  Cons (n, from (n+1))

(* let nats = from 0 *) (* stack overflow *)

(* Working stream rep *)

type 'a stream =
    Cons of 'a * (unit -> 'a stream)

let rec from n =
  Cons (n, fun () -> from (n+1))

let nats = from 0

(* [hd s] is the head of [s] *)
let hd (Cons (h, _)) = h

(* [tl s] is the tail of [s] *)
let tl (Cons (_, tf)) = tf ()

(* [take n s] is the list of the first [n] elements of [s] *)
let rec take n s =
  if n=0 then []
  else hd s :: take (n-1) (tl s)

(* [drop n s] is all but the first [n] elements of [s] *)
let rec drop n s =
  if n = 0 then s
  else drop (n-1) (tl s)

(* [square <a;b;c;...>] is [<a*a;b*b;c*c;...]. *)
let rec square (Cons (h, tf)) =
  Cons (h*h, fun () -> square (tf ()))

(* [sum <a1;b1;c1;...> <a2;b2;c2;...>] is
 * [<a1+b1;a2+b2;a3+b3;...>] *)
let rec sum (Cons (h1, tf1)) (Cons (h2, tf2)) =
  Cons (h1+h2, fun () -> sum (tf1 ()) (tf2 ()))

(* [map f <a;b;c;...>] is [<f a; f b; f c; ...>] *)
let rec map f (Cons (h, tf)) =
  Cons (f h, fun () -> map f (tf ()))

let square' = map (fun n -> n*n)

let rec nats' = Cons(0, fun () -> map (fun x -> x+1) nats')

(* [map2 f <a1;b1;c1;...> <a2;b2;c2;...>] is
 * [<f a1 b1; f a2 b2; f a3 b3; ...>] *)
let rec map2 f (Cons (h1, tf1)) (Cons (h2, tf2)) =
  Cons (f h1 h2, fun () -> map2 f (tf1 ()) (tf2 ()))

let sum = map2 (+)
let mult = map2 ( * )