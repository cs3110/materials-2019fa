open Ast

(** [Env] is module to help with environments, which 
    are maps that have strings as keys. *)
module Env = Map.Make(String)

let empty_env = Env.empty

(** [env] is the type of an environment, which maps
    a string to a value. *)
type env = value Env.t

(** [value] is the type of a value *)
and value = 
  | VInt of int
  | VBool of bool

(** The error message produced if a variable is unbound. *)
let unbound_var_err = "Unbound variable"

(** The error message produced if binary operators and their
    operands do not have the correct types. *)
let bop_err = "Operator and operand type mismatch"

(** The error message produced if the guard
    of an [if] does not have type [bool]. *)
let if_guard_err = "Guard of if must have type bool"

(** [eval env e] is the [v] such that [<env, e> ==> v]. *)
let rec eval (env: env) (e : expr) : value = match e with
  | Int i -> VInt i
  | Bool b -> VBool b
  | Var x -> eval_var env x
  | Binop (bop, e1, e2) -> eval_bop env bop e1 e2
  | Let (x, e1, e2) -> eval_let env x e1 e2
  | If (e1, e2, e3) -> eval_if env e1 e2 e3

(** [eval_var env x] is the [v] such that [<env, x> ==> v] *)
and eval_var env x =
  try Env.find x env
  with Not_found -> failwith unbound_var_err

(** [eval_bop env bop e1 e2] is the [v] such that [<env, e1 bop e2> ==> v]. *)
and eval_bop env bop e1 e2 = match bop, eval env e1, eval env e2 with
  | Add, VInt a, VInt b -> VInt (a + b)
  | Mult, VInt a, VInt b -> VInt (a * b)
  | Leq, VInt a, VInt b -> VBool (a <= b)
  | _ -> failwith bop_err

(** [eval_let env x e1 e2] is the [v] such that
    [<env, let x = e1 in e2> ==> v]. *)
and eval_let env x e1 e2 =
  let v1 = eval env e1 in
  let env' = Env.add x v1 env in
  eval env' e2

(** [eval_if env e1 e2 e3] is the [v] such that
    [<env, if e1 then e2 else e3> ==> v]. *)
and eval_if env e1 e2 e3 = match eval env e1 with
  | VBool true -> eval env e2
  | VBool false -> eval env e3
  | _ -> failwith if_guard_err

(** [parse s] parses [s] into an AST. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(** [string_of_val v] converts [v] to a string. *)
let string_of_val (v: value) : string =
  match v with
  | VInt i -> string_of_int i
  | VBool b -> string_of_bool b
  | VClosure _ -> "<fun>"

(** [interp s] interprets [s] by lexing and parsing it, 
    evaluating it, and converting the result to a string. *)
let interp (s : string) : string =
  s |> parse |> eval empty_env |> string_of_val


