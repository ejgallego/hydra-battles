(**  * Bridge between Hydra-battle's and Gaia's [T1]  (Experimental) 
 *)

From hydras Require Import DecPreOrder.
From hydras Require T1.
From mathcomp Require Import all_ssreflect zify.
From gaia Require Import ssete9.
Set Bullet Behavior "Strict Subproofs".


(* begin snippet hT1gT1 *)

(** Hydra-Battles' type for ordinal terms below [epsilon0] *)

#[global]Notation hT1 := T1.T1.

(** Gaia's type for ordinal terms below [epsilon0] *)

#[global]Notation gT1 := CantorOrdinal.T1.

(* end snippet hT1gT1 *)

Set Implicit Arguments.
Unset Strict Implicit.

(** From hydra to gaia and back *)

(* begin snippet MoreNotations *)
Notation g_zero := CantorOrdinal.zero.
Notation h_zero := T1.zero. 

Notation g_one := CantorOrdinal.one.
Notation h_one := T1.one.

Notation h_fin := T1.fin.

Notation h_omega := T1.omega.
Notation g_omega := T1omega. 

Notation h_succ := T1.succ.
Notation g_succ := T1succ.

Notation h_phi0 alpha := (T1.phi0 alpha).
Notation g_phi0 := CantorOrdinal.phi0.

Notation h_plus := T1.plus.
Notation g_add := T1add.

Notation h_mult := T1.mult.
Notation g_mul := T1mul.

Notation h_lt := T1.lt.
Notation g_lt := T1lt.
(* end snippet MoreNotations *)

(* begin snippet iotaPiDef *)

Fixpoint iota (alpha : hT1) : gT1 :=
  match alpha with
    T1.zero => zero
  | T1.ocons alpha n beta => cons (iota alpha) n (iota beta)
  end.

Fixpoint pi (alpha : gT1) : hT1 :=
  match alpha with
    zero => T1.zero
  | cons alpha n beta => T1.ocons (pi alpha) n (pi beta)
  end.

(* end snippet iotaPiDef *)

(* begin snippet iotaPiRw:: no-out *)
Lemma iota_pi (alpha: gT1): iota (pi alpha) = alpha.
(* end snippet iotaPiRw *)
Proof.
  elim: alpha => //= t1 IHalpha1 n t2 IHalpha2.
    by rewrite IHalpha1 IHalpha2.
Qed.

(* begin snippet piIotaRw:: no-out *)
Lemma pi_iota (alpha: hT1): pi (iota alpha) = alpha.
(* end snippet piIotaRw *)
Proof.
  elim: alpha => //= t1 IHalpha1 n t2 IHalpha2.
    by rewrite IHalpha1 IHalpha2.
Qed.

(** refinements of constants, functions, etc. *)

(* begin snippet refineDefs *)

Definition refines0 (x:hT1)(y:gT1) :=
y = iota x.

Definition refines1 (f:hT1 -> hT1)
 (f': gT1 -> gT1) :=
  forall x: hT1, f' (iota x) = iota (f x).

Definition refines2 (f:hT1 -> hT1 -> hT1)
 (f': gT1 -> gT1 -> gT1 ) :=
  forall x y : hT1, f' (iota x) (iota y) = iota (f x y).

Definition refinesPred (hP: hT1 -> Prop) (gP: gT1 -> Prop) :=
  forall x : hT1, hP x <-> gP (iota x).

Definition refinesRel (hR: hT1 -> hT1 -> Prop)
           (gR: gT1 -> gT1 -> Prop) :=
  forall x y : hT1, hR x y <-> gR (iota x) (iota y).

(* end snippet refineDefs *)

Lemma refines1_R f f' :
  refines1 f f' ->
  forall y: gT1, f (pi y) = pi (f' y).
Proof.
  move => Href y; rewrite -{2}(iota_pi y).
    by rewrite Href pi_iota.
Qed.


Lemma refines2_R f f' :
  refines2 f f' ->
  forall y z: gT1, f (pi y) (pi z) = pi (f' y z).
Proof.
move => Href y z; rewrite -{2}(iota_pi y) -{2}(iota_pi z);
          by rewrite Href pi_iota.
Qed.


(** Refinements of usual constants *)
(* begin snippet constantRefs:: no-out *)


Lemma zero_ref : refines0 h_zero g_zero.
Proof. by []. Qed.


Lemma one_ref : refines0 h_one g_one.
Proof. by []. Qed.



Lemma Finite_ref (n:nat) : refines0 (h_fin n) (\F n).
Proof. by case: n. Qed.

Lemma omega_ref : refines0 h_omega g_omega.
Proof. by []. Qed.

(* end snippet constantRefs *)

(** unary functions *)
(* begin snippet unaryRefs:: no-out *)


Lemma succ_ref: refines1 h_succ g_succ.
(*| .. coq:: none |*)
Proof.
  red.  elim => [//|//  x].
  case: x => // x n y H p z H0 /=.
 by rewrite H0.
Qed.
(*||*)

Lemma phi0_ref x: refines0 (h_phi0 x) (g_phi0 (iota x)). (* .no-out *)
(*| .. coq:: none |*)
Proof. by []. Qed.
(* end snippet unaryRefs *)


Lemma ap_ref : refinesPred T1.ap T1ap. 
Proof.
move => alpha; split => Hap; first by case: Hap.
move: Hap; case: alpha => //=.
move => alpha n beta /andP [Hn Hz].
move/eqP: Hn Hz =>->; move/eqP.
by case: beta.
Qed.


Lemma T1eq_refl (a: gT1) : T1eq a a.
Proof. by apply/T1eqP. Qed.

Lemma T1eq_rw a b: T1eq a b -> pi a = pi b.
Proof. by move => /T1eqP ->. Qed. 

Lemma T1eq_iota_rw (a b : hT1) : T1eq (iota a) (iota b) -> a = b.
Proof.
  move => H; rewrite <- (pi_iota a), <- (pi_iota b); by apply T1eq_rw.
Qed.

(* begin snippet compareRef:: no-out *)
Lemma compare_ref (x y: hT1) :
  match T1.compare_T1 x y with
  | Lt => T1lt (iota x) (iota y)
  | Eq => iota x = iota y
  | Gt => T1lt (iota y) (iota x)
  end.
(* end snippet compareRef *)
Proof.
move: y; elim: x => [|x1 IHx1 n x2 IHx2]; case => //= y1 n0 y2.
case H: (T1.compare_T1 x1 y1).
- specialize (IHx1 y1); rewrite H in IHx1.
  case H0: (PeanoNat.Nat.compare n n0).
  + have ->: (n = n0) by apply Compare_dec.nat_compare_eq.
    case H1: (T1.compare_T1 x2 y2).
    * rewrite IHx1; f_equal.
      by specialize (IHx2 y2); now rewrite H1 in IHx2.
    * case (iota x1 < iota y1); [trivial|].
      rewrite IHx1 eqxx /= eqxx ltnn.
      specialize (IHx2 y2); by rewrite H1 in IHx2.
    * rewrite IHx1 T1ltnn eqxx ltnn eqxx.
      specialize (IHx2 y2); by rewrite H1 in IHx2.
  + rewrite IHx1 T1ltnn eqxx.
    apply Compare_dec.nat_compare_Lt_lt in H0.
    by move/ltP: H0 =>->.
  + rewrite IHx1 T1ltnn eqxx.
     apply Compare_dec.nat_compare_Gt_gt in H0.
     by move/ltP: H0 =>->.
- specialize (IHx1 y1); rewrite H in IHx1; now rewrite IHx1.
- specialize (IHx1 y1); rewrite H in IHx1; now rewrite IHx1.
Qed.

(* begin snippet ltRef:: no-out *)
Lemma lt_ref : refinesRel h_lt g_lt.
(* end snippet ltRef *)
Proof.
  move=> a b; split.
  - rewrite /T1.lt /Comparable.compare; move => Hab. 
    generalize (compare_ref a b); now rewrite Hab.
  - move => Hab; red.
    case_eq (T1.compare_T1 a b).
    + move => Heq; generalize (compare_ref a b); rewrite Heq.
      move => H0; move: Hab; rewrite H0;
                move => Hb; by rewrite T1ltnn in Hb.
    + by [].     
    + move => HGt; generalize (compare_ref a b); rewrite HGt.
      move =>  H1; have H2: (iota a < iota a).
      * eapply T1lt_trans; eauto.
      * by rewrite T1ltnn in H2. 
Qed.



Lemma eqref : refinesRel eq eq.  
Proof.
  move => a b; split.
  - by move => ->.
  - move => Hab; apply T1eq_iota_rw; by rewrite Hab T1eq_refl.
Qed.



(* begin snippet plusRef:: no-out *)
Lemma plus_ref : refines2 h_plus g_add.
(* end snippet plusRef *)
Proof.
  move => x; elim: x => [|x1 IHx1 n x2 IHx2]; case => //= y1 n0 y2.
  case Hx1y1: (T1.compare_T1 x1 y1); move: (compare_ref x1 y1);
    rewrite Hx1y1 => H.
  - rewrite /Comparable.compare H T1ltnn /=; f_equal.
    by rewrite Hx1y1 -H /=.
  - by rewrite /Comparable.compare H Hx1y1.
  - replace (iota x1 < iota y1) with false.
    rewrite /Comparable.compare H /= Hx1y1; f_equal.
    change (cons (iota y1) n0 (iota y2)) with (iota (T1.ocons y1 n0 y2)).
      by rewrite IHx2.
        by apply T1lt_anti in H.
Qed.



Section Proof_of_mult_ref.

Lemma T1mul_eqn1 (c : gT1) : c * zero = zero. 
Proof. by []. Qed.

Lemma mult_eqn1 c : T1.mult c T1.zero = T1.zero.
Proof. case: c; cbn => //; by case. 
Qed.


Lemma T1mul_eqn3 n b n' b' : cons zero n b * cons zero n' b' =
                     cons zero (n * n' + n + n') b'.      
Proof. by [].  Qed. 


Lemma mult_eqn3 n b n' b' :
  T1.mult (T1.ocons T1.zero n b) (T1.ocons T1.zero n' b') =
                     T1.ocons T1.zero (n * n' + n + n') b'.      
Proof. cbn; f_equal; nia. Qed.


Lemma T1mul_eqn4 a n b n' b' :
  a != zero -> (cons a n b) * (cons zero n' b') =
               cons a (n * n' + n + n') b.
Proof. 
  move => /T1eqP.  cbn.
  move =>  Ha'; have Heq: T1eq a zero = false.
  { move: Ha'; case: a => //. }
  rewrite Heq; by cbn.        
Qed.

Lemma mult_eqn4 a n b n' b' :
  a <> T1.zero ->
  T1.mult (T1.ocons a n b) (T1.ocons T1.zero n' b') =
  T1.ocons a (n * n' + n + n') b.
Proof. 
  cbn.  case: a => [//|alpha n0 beta _ ].
  f_equal; nia. 
Qed.

Lemma T1mul_eqn5 a n b a' n' b' :
   a' != zero ->
  (cons a n b) * (cons a' n' b') =
  cons (a + a') n' (T1mul (cons a n b) b').
Proof. 
  move => H /=;  cbn;  have Ha' : T1eq a' zero = false. 
   { move: a' H; case => //. }
   case (T1eq a zero); cbn; by rewrite Ha'. 
Qed.

Lemma mult_eqn5 a n b a' n' b' :
  a' <>  T1.zero ->
  T1.mult (T1.ocons a n b)  (T1.ocons a' n' b') =
  T1.ocons (T1.plus a  a') n' (T1.mult (T1.ocons a n b) b').
Proof.
  move => Ha'; cbn; case: a; move: Ha'; case: a' => //.
Qed.

Lemma iota_cons_rw a n b : iota (T1.ocons a n b)= cons (iota a) n (iota b). 
Proof. by []. Qed.

Lemma iota_zero_rw  : iota T1.zero = zero. 
Proof. by []. Qed.

(* begin snippet multRef:: no-out *)

Lemma mult_ref : refines2 h_mult g_mul.
(* end snippet multRef *)
Proof.
  move => x y;  move: x; induction y. 
  -   move => x; simpl iota; rewrite T1mul_eqn1; case x => //.
      case => //.
  -  case.
     + simpl iota => // /=.
     + move => alpha n0 beta.
       destruct (T1.T1_eq_dec  alpha T1.zero).
       *  subst; destruct (T1.T1_eq_dec y1 T1.zero).
          -- subst y1; simpl iota; rewrite T1mul_eqn3; f_equal; nia.
          -- repeat rewrite !iota_cons_rw !iota_zero_rw.
             rewrite T1mul_eqn5.
             ++ rewrite mult_eqn5 => //.
                ** simpl iota; simpl T1add; f_equal.
                   destruct (T1.T1_eq_dec y2 T1.zero).
                   { subst; by cbn. }
                   { change (cons zero n0 (iota beta)) with
                         (iota (T1.ocons T1.zero n0 beta)); now rewrite IHy2.
                   }
             ++  destruct y1; [now destruct n1| now compute].
       * destruct (T1.T1_eq_dec y1 T1.zero).
         --   subst; rewrite !iota_cons_rw !iota_zero_rw;
                rewrite T1mul_eqn4.
              ++ by rewrite mult_eqn4. 
              ++ case :alpha n1 => //. 
         --   rewrite !iota_cons_rw. 
              ++ rewrite T1mul_eqn5.
                 ** rewrite  mult_eqn5 => //. 
                    simpl iota; rewrite plus_ref; f_equal. 
                    change (cons (iota alpha) n0 (iota beta))
                      with (iota (T1.ocons alpha n0 beta)); now rewrite IHy2.
                 **  case: y1 n2 IHy1 => //.
Qed.

End Proof_of_mult_ref.

Lemma mult_refR (a b : gT1) : T1.mult (pi a) (pi b) = pi (a * b).
Proof. apply refines2_R,  mult_ref. Qed. 


Lemma multA : associative T1.mult.
Proof. 
  move => a b c. 
  by rewrite -(pi_iota a) -(pi_iota b) -(pi_iota c) !mult_refR mulA. 
Qed.


(** Order compatibility *)

Lemma Comparable_T1lt_eq a b:
  bool_decide (T1.lt a b) = (iota a < iota b).
Proof.
  rewrite /T1.lt; generalize (compare_ref a b);
  rewrite /Comparable.compare /=.
  destruct (decide (T1.compare_T1 a b = Lt)).
  - have bd := e.
    apply (bool_decide_eq_true _) in bd.
    by rewrite bd e.
  - have bd := n.
    apply (bool_decide_eq_false _) in bd.
    rewrite bd.
    destruct (T1.compare_T1 a b).
    * by move => ->; rewrite T1ltnn.
    * by [].
    * move => Hlt.
      symmetry.
      apply/negP => Hlt'.
      have H1 : (iota b < iota b) by apply T1lt_trans with (iota a).
      by rewrite T1ltnn in H1.
Qed.


Lemma nf_ref (a: hT1)  : T1.nf_b a = T1nf (iota a).
Proof.
  elim: a => //.
  - move => a IHa n b IHb; rewrite T1.nf_b_cons_eq; simpl T1nf. 
    rewrite IHa IHb;  change (phi0 (iota a)) with (iota (T1.phi0 a)).
    by rewrite andbA Comparable_T1lt_eq.
Qed.


