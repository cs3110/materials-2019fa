open Ast

(** The error message produced if a variable is unbound. *)
let unbound_var_err = "Unbound variable"

(** The error message produced if binary operators and their
    operands do not have the correct types. *)
let bop_err = "Operator and operand type mismatch"

(** The error message produced if the guard
    of an [if] does not have type [bool]. *)
let if_guard_err = "Guard of if must have type bool"

(** The error message produced if the two branches
    of an [if] does not have the same type. *)
let if_branch_err = "Branches of if must have same type"

(** The error message produced if the binding expression
    of a [let] does not have the same type as the
    annotation on the variable name. *)
let annotation_err = "Let expression type mismatch"

(** [Type_error s] is raised during type checking to indicate
    a type error.  The error message is [s]. *)
exception Type_error of string

(** [Env] is a static environment. *)
module type Env = sig
  (** [t] is the type of an environment. *)
  type t

  (** [empty] is the empty environment. *)
  val empty : t

  (** [lookup env x] gets the binding of [x] in [env]. 
      Raises: [Failure] if [x] is not bound in [env]. *) 
  val lookup : t -> string -> typ

  (** [extend env x ty] is [env] extended with a binding
      of [x] to [ty]. *)
  val extend : t -> string -> typ -> t
end

(** [AssocListEnv] is an [Env] implemented with an association list. *)
module AssocListEnv : Env = struct
  type t = (string * typ) list

  let empty = []

  let lookup ctx x =
    try List.assoc x ctx
    with Not_found -> raise (Type_error "Unbound variable")

  let extend ctx x ty =
    (x, ty) :: ctx
end

open AssocListEnv

(** [typeof env e] is the type of [e] in environment [env].
    That is, it is the [t] such that [env |- e : t]. *)
let rec typeof env = function
  | Bool _ -> TBool
  | Int _ -> TInt
  | Var x -> lookup env x
  | Binop (bop, e1, e2) -> typeof_binop env bop e1 e2
  | Let (x, t, e1, e2) -> typeof_let env x t e1 e2
  | If (e1, e2, e3) -> typeof_if env e1 e2 e3

(** [typeof_binop env bop e1 e2] is the type of [e1 bop e2] in environment
    [env]. *)
and typeof_binop env bop e1 e2 = 
  match bop, typeof env e1, typeof env e2 with
  | Add, TInt, TInt -> TInt
  | Mult, TInt, TInt -> TInt
  | Leq, TInt, TInt -> TBool
  | _ -> raise (Type_error bop_err)

(** [typeof_let env x t e1 e2] is the type of [let x : t = e1 in e2] in
    environment [env]. *)
and typeof_let env x t e1 e2 =
  let t1 = typeof env e1 in
  if t = t1 then
    let env' = extend env x t1 in
    typeof env' e2
  else 
    raise (Type_error annotation_err)

(** [typeof_if env e1 e2 e3] is the type of [if e1 then e2 else e3] in
    environment [env]. *)
and typeof_if env e1 e2 e3 =
  let t1 = typeof env e1 in
  if t1 <> TBool then 
    raise (Type_error if_guard_err)
  else 
    let t2 = typeof env e2 in
    let t3 = typeof env e3 in
    if t2 <> t3 then
      raise (Type_error if_branch_err)
    else 
      t2

(** [typecheck e] is [e] if [e] typechecks, that is, if there exists a type
    [t] such that [{} |- e : t].
    Raises: Failure if [e] does not type check. *)
let typecheck e =
  ignore (typeof empty e); e

(** [subst e v x] is [e] with [v] substituted for [x], that
    is, [e{v/x}]. *)
let rec subst e v x = match e with
  | Var y -> if x = y then v else e
  | Bool _ -> e
  | Int _ -> e
  | Binop (bop, e1, e2) -> Binop (bop, subst e1 v x, subst e2 v x)
  | Let (y, t, e1, e2) ->
    let e1' = subst e1 v x in
    if x = y
    then Let (y, t, e1', e2)
    else Let (y, t, e1', subst e2 v x)
  | If (e1, e2, e3) -> 
    If (subst e1 v x, subst e2 v x, subst e3 v x)

(** [eval e] is the [v] such that [e ==> v]. *)
let rec eval (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith unbound_var_err
  | Binop (bop, e1, e2) -> eval_bop bop e1 e2
  | Let (x, _, e1, e2) -> subst e2 (eval e1) x |> eval
  | If (e1, e2, e3) -> eval_if e1 e2 e3

(** [eval_bop bop e1 e2] is the [v] such that [e1 bop e2 ==> v]. *)
and eval_bop bop e1 e2 = match bop, eval e1, eval e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith bop_err

(** [eval_if e1 e2 e3] is the [v] such that [if e1 then e2 else e3 ==> v]. *)
and eval_if e1 e2 e3 = match eval e1 with
  | Bool true -> eval e2
  | Bool false -> eval e3
  | _ -> failwith if_guard_err

(** [parse s] parses [s] into an AST. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(** [string_of_val v] converts [v] to a string.
    Requires: [v] represents a value. *)
let string_of_val (e : expr) : string =
  match e with
  | Int i -> string_of_int i
  | Bool b -> string_of_bool b
  | _ -> failwith "precondition violated"

(** [interp s] interprets [s] by lexing and parsing it, 
    evaluating it, and converting the result to a string. *)
let interp (s : string) : string =
  s |> parse |> typecheck |> eval |> string_of_val
