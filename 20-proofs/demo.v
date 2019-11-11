Require Import Arith.
Import Nat.
Require Extraction.

Fixpoint fact n :=
  match n with
  | 0 => 1
  | S k => n * fact k
  end.

Fixpoint facti acc n :=
  match n with
  | 0 => acc
  | S k => facti (acc * S k) k
  end.

Definition fact_tr n :=
  facti 1 n.

Lemma fact_lemma :
  forall n p, p * fact n = facti p n.
Proof.
  induction n as [ | k]; intros p; simpl.
  - ring.
  - replace (p * (fact k + k * fact k)) with (p * S k * fact k).
    -- apply IHk.
    -- ring.
Qed.

Theorem fact_correct :
  forall n, fact n = fact_tr n.
Proof.
  intros n. unfold fact_tr.
  replace (fact n) with (1 * fact n).
  - apply fact_lemma.
  - ring.
Qed.

Extraction "fact.ml" fact fact_tr.
