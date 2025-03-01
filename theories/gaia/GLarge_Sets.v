(** Gaia-compatible large sequences 

(imported from [hydras.Epsilon0.Large_Sets] )
*)


From mathcomp Require Import all_ssreflect zify.
From hydras Require Import T1.
From hydras Require Import Canon Paths Large_Sets.
Require Import T1Bridge GCanon GPaths.

From gaia Require Import ssete9.
Import CantorOrdinal. 

Notation hmlarge  := mlarge.
Notation hmlargeS  := mlargeS.
Definition mlarge a s := hmlarge (g2h a) s.
Definition mlargeS a s := hmlargeS (g2h a) s.


Notation hlarge := large. 
Notation hlargeS := largeS. 
Definition large a A := hlarge (g2h a) A.
Definition largeS a A := hlargeS (g2h a) A.

Notation hL_spec := L_spec.
Definition L_spec a f := L_spec (g2h a) f.

Lemma mlarge_unicity a k l l' : 
  mlarge a (index_iota k.+1 l.+1) ->
  mlarge a (index_iota k.+1 l'.+1) ->
  l = l'.
Proof.
  rewrite /mlarge -!interval_def => Hl Hl';
  by rewrite (mlarge_unicity _ _ _ _ Hl Hl').
Qed.

Lemma L_fin_ok i : L_spec (\F i) (L_fin i).
Proof.
  rewrite /L_spec (Finite_ref i) g2h_h2gK; apply L_fin_ok.
Qed.

Theorem Theorem_4_5 (a: T1)(Ha : T1nf a)
        (A B : seq nat)
        (HA : Sorted.Sorted Peano.lt A)
        (HB : Sorted.Sorted Peano.lt B)
        (HAB : List.incl A B) :
  largeS a A -> largeS a B.
Proof.
  rewrite /largeS; apply Theorem_4_5 => //; by rewrite hnf_g2h.
Qed.



