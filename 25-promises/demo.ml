(* Demo of Lwt *)

let p, r = Lwt.wait();;
let (p : int Lwt.t), r = Lwt.wait ();;
Lwt.state p;;
Lwt.wakeup r 42;;
Lwt.state p;;
Lwt.wakeup r 42;; (* can't fill again *)
let (p : int Lwt.t), r = Lwt.wait ();;
Lwt.wakeup_exn r (Failure "nope");;
Lwt.state p;;

(** A signature for Lwt-style promises, with better names *)
module type Promise = sig

  type 'a state = Pending | Resolved of 'a | Rejected of exn
  type 'a promise
  type 'a resolver

  (** [state p] is the state of the promise *)
  val state : 'a promise -> 'a state

  (** [resolve r x] resolves the promise [p] associated with [r]
      with value [x]. Requires: [p] is pending. *)
  val resolve : 'a resolver -> 'a -> unit

  (** [reject r x] rejects the promise [p] associated with [r]
      with exception [x]. Requires: [p] is pending. *)
  val reject : 'a resolver -> exn -> unit

  (** [make ()] is a new promise and resolver. The promise is pending. *)
  val make : unit -> 'a promise * 'a resolver

  (** [return x] is a new promise that is already resolved with value [x]. *)
  val return : 'a -> 'a promise

end

module Promise : Promise = struct

  type 'a state = Pending | Resolved of 'a | Rejected of exn

  type 'a promise = 'a state ref

  type 'a resolver = 'a promise

  (** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
      are both pending, that has no effect.
      Raises: [Invalid_arg] if the state of [p] is not pending. *)
  let write_once p s = 
    if !p = Pending
    then p := s
    else invalid_arg "cannot write twice"  

  let make () = 
    let p = ref Pending in
    p, p

  let return x = ref (Resolved x)

  let state p = !p

  let resolve p x = write_once p (Resolved x)

  let reject p x = write_once p (Rejected x)

end;;

(* Demo blocking vs. non-blocking I/O *)

(* This code contains some UTop commands that will
   cause VS Code to display errors.  That's okay; this code 
   is meant to run in utop not to be compiled.

   #require "lwt.unix";;
   Lwt_io.read_char;; (* returns a promise *)
   let pc = Lwt_io.(read_char stdin);;
   pc;; (* wait, did the type of [pc] change? *)

   let p, r = Lwt.wait ();;
   p;;  (* C-c *)
   UTop.set_auto_run_lwt false;;
   p;;

   let pc = Lwt_io.(read_char stdin);;
   (* type a character *)
   pc;;
   Lwt.state pc;;
*)

(* Demo [bind] *)

open Lwt_io;;

(* v1, using [bind] function *)
Lwt.bind 
  (read_line stdin) 
  (fun str -> printlf "You typed %S" str);;

open Lwt.Infix;;

(* v2, using [>>=] operator *)
read_line stdin >>= fun str ->
printlf "You typed %S" str;;

(* v3, using [let%lwt syntax extension *)
let%lwt str = read_line stdin in
printlf "You typed %S" str;;