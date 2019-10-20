(*** Functional Stacks ***)

(* Here is an interface for stacks: *)

module type Stack = sig
  (* The type of a stack whose elements are type 'a *)
  type 'a stack

  (* The empty stack *)
  val empty : 'a stack

  (* Whether the stack is empty*)
  val is_empty : 'a stack -> bool

  (* [push x s] is the stack [s] with [x] pushed on the top *)
  val push : 'a -> 'a stack -> 'a stack

  (* [peek s] is the top element of [s]. 
     Raises Failure if [s] is empty. *)
  val peek : 'a stack -> 'a

  (* [pop s] pops and discards the top element of [s]. 
     Raises Failure if [s] is empty. *)
  val pop : 'a stack -> 'a stack
end

(* Here are two implementations of that interface, both
   of which we examined in lecture: *)

module ListStack : Stack = struct
  type 'a stack = 'a list

  let empty = []
  let is_empty s = s = []
  let push x s = x :: s
  let peek = function 
    | []   -> failwith "Empty"
    | x::_ -> x
  let pop = function 
    | []    -> failwith "Empty"
    | _::xs -> xs
end

module MyStack : Stack = struct
  type 'a stack = 
    | Empty 
    | Entry of 'a * 'a stack

  let empty = Empty
  let is_empty s = s = Empty
  let push x s = Entry (x, s)
  let peek = function
    | Empty -> failwith "Empty"
    | Entry(x,_) -> x
  let pop = function
    | Empty -> failwith "Empty"
    | Entry(_,s) -> s
end

(*** Functional Queues ***)

(* Here is an interface for queues.  Note that this time we chose
   to return options instead of raising exceptions. *)

module type Queue = sig
  (* An ['a queue] is a queue whose elements have type ['a]. *)
  type 'a queue

  (* The empty queue. *)
  val empty : 'a queue

  (* Whether a queue is empty. *)
  val is_empty : 'a queue -> bool

  (* [enqueue x q] is the queue [q] with [x] added to the front. *)
  val enqueue : 'a -> 'a queue -> 'a queue

  (* [peek q] is [Some x], where [x] is the element at the front of the queue,
     or [None] if the queue is empty. *)
  val peek : 'a queue -> 'a option

  (* [dequeue q] is [Some q'], where [q'] is the queue containing all the elements
     of [q] except the front of [q], or [None] if [q] is empty. *)
  val dequeue : 'a queue -> 'a queue option
end

(* Here is a first implementation of that interface, using
   lists to represent queues. *)

module ListQueue : Queue = struct
  (* Represent a queue as a list.  The list [x1; x2; ...; xn] represents
     the queue with [x1] at its front, followed by [x2], ..., followed
     by [xn]. *)
  type 'a queue = 'a list

  let empty = []

  let is_empty q = q = []

  (* Although the implementation of [enqueue] is correct, its efficiency
     is linear:  the [@] operator will walk down the entire queue
     to add an element at the end. *)
  let enqueue x q = q @ [x] 

  let peek = function
    | [] -> None
    | x::_ -> Some x

  (* The efficiency of [dequeue] is constant time. *)
  let dequeue = function
    | [] -> None
    | _::q -> Some q
end

(* Here is a second, more efficient implementation of the Queue interface, 
   using two lists to represent a single queue. This representation was invented
   by Robert Melville as part of his PhD dissertation at Cornell, *Asymptotic
   Complexity of Iterative Computations*, Jan 1981, which was advised by Prof.
   David Gries. *)

module TwoListQueue : Queue = struct
  (* [{front=[a;b]; back=[e;d;c]}] represents the queue containing the elements
     a,b,c,d,e. That is, the back of the queue is stored in reverse order.
     [{front; back}] is in *normal form* if [front] being empty implies [back]
     is also empty. All queues passed into or out of the module must be in
     normal form. *)
  type 'a queue = {front:'a list; back:'a list}

  let empty = {front=[]; back=[]}

  let is_empty = function
    | {front=[]; back=[]} -> true
    | _ -> false

  (* Helper function to ensure that a queue is in normal form. *)
  let norm = function
    | {front=[]; back} -> {front=List.rev back; back=[]}
    | q -> q

  (* We now get a constant time [enqueue] operation: just cons
     the new elements onto the [back]. *)
  let enqueue x q = norm {q with back=x::q.back} 

  let peek = function 
    | {front=[]; _} -> None
    | {front=x::_; _} -> Some x

  (* [dequeue] has to call [norm] to ensure the queue it
     returns is in normal form.  It might seem as though 
     [dequeue] no longer has constant time efficiency.
     But with a technique called *amortized analysis*,
     covered later in the semester, it is possible to conclude
     that this implementation of [dequeue] is essentially
     constant time. *)
  let dequeue = function
    | {front=[]; _} -> None
    | {front=_::xs; back} -> Some (norm {front=xs; back})
end

