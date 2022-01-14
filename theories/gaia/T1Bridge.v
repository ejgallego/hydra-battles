(**  * Bridge between Hydra-battle's and Gaia's [T1]  (Experimental) 
 *)

From hydras Require Import DecPreOrder.
From hydras Require T1 E0.
From mathcomp Require Import all_ssreflect zify.
From gaia Require Import ssete9.
Set Bullet Behavior "Strict Subproofs".

(* begin snippet hT1gT1 *)

(** Hydra-Battles' type for ordinal terms below [epsilon0] *)

#[global] Notation hT1 := T1.T1.

(** Gaia's type for ordinal terms below [epsilon0] *)

#[global]Notation gT1 := CantorOrdinal.T1.

(* end snippet hT1gT1 *)

Set Implicit Arguments.
Unset Strict Implicit.

(** From hydra to gaia and back *)

(* begin snippet MoreNotations *)
#[global] Notation gzero := CantorOrdinal.zero.
#[global] Notation hzero := T1.zero.

#[global] Notation gone := CantorOrdinal.one.
#[global] Notation hone := T1.one.

#[global] Notation hcons := T1.ocons.
#[global] Notation gcons := CantorOrdinal.cons.

#[global] Notation hfin := T1.fin.

#[global] Notation homega := T1.omega.
#[global] Notation gomega := T1omega. 

#[global] Notation hsucc := T1.succ.
#[global] Notation gsucc := T1succ.

#[global] Notation hphi0 alpha := (T1.phi0 alpha).
#[global] Notation gphi0 := CantorOrdinal.phi0.

#[global] Notation hplus := T1.plus.
#[global] Notation gadd := T1add.

#[global] Notation hmult := T1.mult.
#[global] Notation gmul := T1mul.

#[global] Notation hlt := T1.lt.
#[global] Notation glt := T1lt.

#[global] Notation hLT := T1.LT.
#[global] Notation gLT := (restrict T1nf T1lt).

#[global] Notation hnfb := T1.nf_b.
#[global] Notation gnfb := T1nf.

#[global] Notation hlimitb := T1.limitb.
#[global] Notation glimitb := T1limit.

#[global] Notation his_succ := T1.succb.
#[global] Notation gis_succ := T1is_succ.

(* end snippet MoreNotations *)

(* begin snippet iotaPiDef *)

Fixpoint iota (alpha : hT1) : gT1 :=
  match alpha with
    T1.zero => zero
  | hcons alpha n beta => gcons (iota alpha) n (iota beta)
  end.

Fixpoint pi (alpha : gT1) : hT1 :=
  match alpha with
    zero => T1.zero
  | gcons alpha n beta => hcons (pi alpha) n (pi beta)
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


(** refinement of constants, functions, etc. *)

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


Lemma zero_ref : refines0 hzero gzero.
Proof. by []. Qed.


Lemma one_ref : refines0 hone gone.
Proof. by []. Qed.



Lemma Finite_ref (n:nat) : refines0 (hfin n) (\F n).
Proof. by case: n. Qed.

Lemma omega_ref : refines0 homega gomega.
Proof. by []. Qed.

(* end snippet constantRefs *)

(** unary functions *)
(* begin snippet unaryRefs:: no-out *)


Lemma succ_ref: refines1 hsucc gsucc.
(*| .. coq:: none |*)
Proof.
  red.  elim => [//|//  x].
  case: x => // x n y H p z H0 /=.
  by rewrite H0.
Qed.
(*||*)

Lemma phi0_ref x: refines0 (hphi0 x) (gphi0 (iota x)). (* .no-out *)
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
  | Lt => glt (iota x) (iota y)
  | Eq => iota x = iota y
  | Gt => glt (iota y) (iota x)
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
Lemma lt_ref : refinesRel hlt glt.
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

(* begin snippet decideHLtRw:: no-out *)
Lemma decide_hlt_rw (a b : hT1):
  bool_decide (hlt a b) = (iota a < iota b).
(* end snippet decideHLtRw *)
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


(* begin snippet eqRef:: no-out *)
Lemma eqref : refinesRel eq eq.
(* end snippet eqRef *)
Proof.
  move => a b; split.
  - by move => ->.
  - move => Hab; apply T1eq_iota_rw; by rewrite Hab T1eq_refl.
Qed.




(* begin snippet plusRef:: no-out *)
Lemma plus_ref : refines2 hplus gadd.
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
    change (gcons (iota y1) n0 (iota y2)) with (iota (hcons y1 n0 y2)).
    by rewrite IHx2.
    by apply T1lt_anti in H.
Qed.



Section Proof_of_mult_ref.

  Lemma T1mul_eqn1 (c : gT1) : c * gzero = gzero. 
  Proof. by []. Qed.

  Lemma mult_eqn1 c : hmult c hzero = hzero.
  Proof. case: c; cbn => //; by case. 
  Qed.


  Lemma T1mul_eqn3 n b n' b' : gcons gzero n b * gcons gzero n' b' =
                                 gcons gzero (n * n' + n + n') b'.      
  Proof. by [].  Qed. 


  Lemma mult_eqn3 n b n' b' :
    hmult (hcons hzero n b) (hcons hzero n' b') =
      hcons hzero (n * n' + n + n') b'.      
  Proof. cbn; f_equal; nia. Qed.


  Lemma T1mul_eqn4 a n b n' b' :
    a != zero -> (gcons a n b) * (gcons zero n' b') =
                   gcons a (n * n' + n + n') b.
  Proof. 
    move => /T1eqP.  cbn.
    move =>  Ha'; have Heq: T1eq a gzero = false.
    { move: Ha'; case: a => //. }
    rewrite Heq; by cbn.        
  Qed.

  Lemma mult_eqn4 a n b n' b' :
    a <> T1.zero ->
    T1.mult (hcons a n b) (hcons T1.zero n' b') =
      hcons a (n * n' + n + n') b.
  Proof. 
    cbn.  case: a => [//|alpha n0 beta _ ].
    f_equal; nia. 
  Qed.

  Lemma T1mul_eqn5 a n b a' n' b' :
    a' != gzero ->
    (gcons a n b) * (gcons a' n' b') =
      gcons (a + a') n' (gmul (gcons a n b) b').
  Proof. 
    move => H /=;  cbn;  have Ha' : T1eq a' zero = false. 
    { move: a' H; case => //. }
    case (T1eq a zero); cbn; by rewrite Ha'. 
  Qed.

  Lemma mult_eqn5 a n b a' n' b' :
    a' <>  hzero ->
    T1.mult (hcons a n b)  (hcons a' n' b') =
      hcons (hplus a  a') n' (hmult (hcons a n b) b').
  Proof.
    move => Ha'; cbn; case: a; move: Ha'; case: a' => //.
  Qed.

  Lemma iota_cons_rw a n b : iota (hcons a n b)= gcons (iota a) n (iota b). 
  Proof. by []. Qed.

  Lemma iota_zero_rw  : iota hzero = gzero. 
  Proof. by []. Qed.

  (* begin snippet multRef:: no-out *)

  Lemma mult_ref : refines2 hmult gmul.
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
                     { change (gcons zero n0 (iota beta)) with
                         (iota (hcons T1.zero n0 beta)); now rewrite IHy2.
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
                      change (gcons (iota alpha) n0 (iota beta))
                        with (iota (hcons alpha n0 beta)); now rewrite IHy2.
                   **  case: y1 n2 IHy1 => //.
  Qed.

End Proof_of_mult_ref.

(* begin snippet multA:: no-out *)
Lemma mult_refR (a b : gT1) : hmult (pi a) (pi b) = pi (a * b).
Proof. apply refines2_R,  mult_ref. Qed. 


Lemma hmultA : associative hmult.
Proof. 
  move => a b c. 
  by rewrite -(pi_iota a) -(pi_iota b) -(pi_iota c) !mult_refR mulA. 
Qed.



(* end snippet multA *)

(* begin snippet nfRef:: no-out *)

Lemma nf_ref (a: hT1)  : hnfb a = gnfb (iota a).
(* end snippet nfRef *)
Proof.
  elim: a => //.
  - move => a IHa n b IHb; rewrite T1.nf_b_cons_eq; simpl T1nf. 
    rewrite IHa IHb;  change (phi0 (iota a)) with (iota (T1.phi0 a)).
    by rewrite andbA decide_hlt_rw.
Qed.

Lemma LT_ref : refinesRel  hLT  gLT.
Proof.
  split.   
  - destruct 1 as [H [H0 H1]]; split. 
    + by rewrite  -nf_ref.
    + by apply lt_ref. 
    + by rewrite -nf_ref. 
  -  case => H H0 H1; repeat  split. 
     +  red; by rewrite nf_ref.
     + by apply lt_ref. 
     +  red; by rewrite nf_ref.
Qed. 

(** Limits, successors, etc *)

Lemma limitb_ref (a:T1.T1) : hlimitb a = glimitb (iota a).
Proof.
  elim: a => /= //.
  move => alpha IHalpha n beta IHbeta; cbn; rewrite IHbeta. 
  move: IHalpha; case:alpha.
  by [].
  move => alpha n0 beta0 IH;  cbn.
  move: IHbeta; case: beta => //.
Qed.


Lemma is_succ_ref (a:T1.T1) : his_succ a = gis_succ (iota a).
Proof. 
  elim: a => /= //.
  move => alpha IHalpha n beta IHbeta; cbn; rewrite IHbeta.
  move: IHalpha; case:alpha => /= //. 
Qed.

(** Well formed ordinals as a structure *)

(* begin snippet E0Def:: no-out *)
Structure E0 := mkE0 { cnf :> gT1 ; _ : gnfb cnf == true}.

#[global] Notation gE0 := E0.
#[global] Notation hE0 := E0.E0.
#[global] Notation hcnf := E0.cnf.
#[global] Notation gcnf := cnf.


Definition gE0_lt (alpha beta: gE0) := glt (cnf alpha) (cnf beta).

Definition gE0_eqb (alpha beta: gE0):= cnf alpha == cnf beta.
(* end snippet E0Def *)





(* begin snippet gE0iotaPi:: no-out *)
Definition E0_iota (a: hE0): gE0.
  esplit with (iota (E0.cnf a)).
  rewrite -nf_ref; case: a => /= cnf cnf_ok;  by rewrite cnf_ok.
Defined.


Definition E0_pi (a: gE0): hE0.
  refine (@E0.mkord (pi a) _); red.
  case: a  => /= cnf0 /eqP; by rewrite nf_ref iota_pi.  
Defined.
(* end snippet gE0iotaPi *)

Lemma E0_iota_nf (a:hE0) : gnfb (E0_iota a).
Proof.
  case: a => /= cnf Hnf; by rewrite -nf_ref. 
Qed.



Require Import Logic.Eqdep_dec.

Lemma gE0_eq1 alpha beta : gE0_eqb alpha beta -> alpha = beta.
Proof.
  case: alpha ; case: beta => x Hx y Hy /=; rewrite /gE0_eqb => /= /eqP .
  move =>Heq; subst.   
  have  H0: Hx = Hy; last first.
  -   by rewrite H0.   
  - apply eq_proofs_unicity_on; case; case (gnfb x); auto.
Qed. 

Lemma gE0_eq_iff alpha beta : gE0_eqb alpha beta <-> alpha = beta.
Proof. 
  split.
  - apply gE0_eq1 => Heq.
  - move => ?  ; subst; rewrite /gE0_eqb => //. 
Qed.

(* begin snippet E0EqP:: no-out *)
Lemma gE0_eqP alpha beta: reflect (alpha = beta) (gE0_eqb alpha beta).
(* end snippet E0EqP *)
Proof.
  case_eq(gE0_eqb alpha beta).
  - constructor;  by rewrite -gE0_eq_iff.
  - constructor => H0; subst.
    move : H => // /=; cbn; by rewrite T1eq_refl.
Qed.


From Coq Require Import Relations Basics
     Wellfounded.Inverse_Image Wellfounded.Inclusion.

(** TODO: simplify this proof !!! *)

(* begin snippet gE0LtWf:: no-out *)
Lemma gE0_lt_wf : well_founded gE0_lt.
Proof.
  move => x; apply Acc_incl
            with (fun x y =>  E0.Lt (E0_pi x) (E0_pi y)).
  (* ... *)
  (* end snippet gE0LtWf *)
  - move => a b ; rewrite /gE0_lt => Hab. 
    case: a Hab => cnf0 i0 Hb.
    case: b Hb => cnf1 i1 /= Hlt ; rewrite /E0.Lt => /=. 
    rewrite -(iota_pi cnf0) in Hlt i0;
      rewrite -(iota_pi cnf1) in Hlt i1;
      rewrite -decide_hlt_rw in Hlt;
      repeat split. 
    + rewrite -!nf_ref in i0 i1;  move: i0 => /eqP //.
    + red in Hlt; rewrite bool_decide_eq_true in Hlt => //.
    + rewrite /bool_decide -!nf_ref in  i1;  move: i1 => /eqP //.
  -  apply Acc_inverse_image, E0.Lt_wf. 
Qed. 



Declare Scope BrGaia_scope. (* Gaia to Bridge *)

Delimit Scope BrGaia_scope with brg.

Infix "*" := gmul : BrGaia_scope.

Lemma L1' (a: gT1) : (gomega * (a * gomega) = gomega * a * gomega)%brg.
Proof. by  rewrite mulA. Qed. 

Print T1mul.
