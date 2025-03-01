(**  
   Class of ordinals less than epsilon0 


   [E0] is a class type for ordinal terms proved to be in normal form.
*)

From Coq Require Import Arith Max Bool Lia  Compare_dec  Relations Ensembles
     ArithRing  Wellfounded  Operators_Properties  Logic.Eqdep_dec.

From hydras Require Import Prelude.More_Arith  Prelude.Restriction
           Prelude.DecPreOrder  ON_Generic OrdNotations.

From hydras.Epsilon0 Require Export T1 Hessenberg.

Set Implicit Arguments.


(* begin snippet E0Scope *)

Declare Scope E0_scope.
Delimit Scope E0_scope with e0.
Open Scope E0_scope.

(* end snippet E0Scope *)

Declare Scope E0_scope.


(* begin snippet E0Def *)

Class E0 : Type := mkord {cnf : T1; cnf_ok : nf cnf}.

Arguments cnf : clear implicits.

#[global] Hint Resolve cnf_ok : E0.

(* end snippet E0Def *)

(** ** Lifting functions from [T1] to [E0] *)

(* begin snippet LtLeDef *)

Definition E0lt (alpha beta : E0) := T1.LT (@cnf alpha) (@cnf beta).
Definition E0le := leq E0lt.

Infix "o<" := E0lt : E0_scope.
Infix "o<=" := E0le : E0_scope.

(* end snippet LtLeDef *)


(* begin snippet ZeroOmega:: no-out  *)
#[global] Instance E0zero : E0 := @mkord zero refl_equal.

#[global] Instance E0omega : E0 := @mkord T1omega refl_equal.

(* end snippet ZeroOmega *)

#[deprecated(note="use E0zero")]
 Notation Zero := E0zero (only parsing).

#[deprecated(note="use E0omega")]
 Notation _Omega := E0omega (only parsing).

(* begin snippet SuccOnE0:: no-out *)
#[global, program] Instance E0succ (alpha : E0) : E0 :=
@mkord (T1.succ (@cnf alpha)) _. 
Next Obligation.  apply succ_nf, cnf_ok. Defined.
(* end snippet SuccOnE0 *)

#[deprecated(note="use E0succ")]
 Notation Succ := E0succ (only parsing).

Definition E0limit (alpha : E0) : bool :=  T1limit (@cnf alpha).

#[deprecated(note="use E0limit")]
 Notation Limitb := E0limit (only parsing).

Definition E0is_succ (alpha : E0) : bool :=
  T1is_succ (@cnf alpha).

#[deprecated(note="use E0is_succ")]
 Notation E0succb := E0is_succ (only parsing).

#[global, program] Instance E0one : E0:= @mkord (T1.succ zero) _.
Next Obligation. now compute. Defined.

(* begin snippet plusE0 *)

(*|
.. coq:: no-out
|*)

#[global, program] Instance E0add (alpha beta : E0) : E0 :=
  @mkord (T1add (@cnf alpha) (@cnf beta))_ . 
Next Obligation.  apply plus_nf; apply cnf_ok. Defined.

Infix "+" := E0add : E0_scope.

(*||*)
(* end snippet plusE0 *)

#[deprecated(note="use E0add")]
 Notation Plus := E0add (only parsing).


(* begin snippet CheckPlus *)

Check E0omega + E0omega.

(* end snippet CheckPlus *)


#[global, program] Instance E0phi0 (alpha: E0) : E0 :=
 @mkord (T1.phi0 (cnf alpha)) _. 
Next Obligation. apply nf_phi0; apply cnf_ok. Defined.

Notation "'E0omega^'" := E0phi0 (only parsing) : E0_scope.

#[global, program] Instance Omega_term (alpha: E0) (n: nat) : E0 :=
   @mkord (cons (cnf alpha) n zero) _.
Next Obligation.  apply nf_phi0; apply cnf_ok. Defined.

#[global] Instance Cons (alpha : E0) (n: nat) (beta: E0) : E0
  := (Omega_term alpha n + beta)%e0.                                                          

#[global, program] Instance E0finS (i:nat) : E0:= @mkord (FS i)%t1 _.
Next Obligation. apply T1.nf_FS. Defined.



#[global, program] Instance E0fin (i:nat) : E0:=
  match i with
    0 => E0zero
  | S i => E0finS i
  end.


#[deprecated(note="use E0fin")]
 Notation Fin := E0fin (only parsing).

Coercion E0fin : nat >-> E0.

#[global, program] Instance E0mul (alpha beta : E0) : E0 :=
  @mkord (cnf alpha * cnf beta)%t1 _.
Next Obligation. apply mult_nf; apply cnf_ok. Defined.

#[deprecated(note="use E0mul")]
 Notation Mult := E0mul (only parsing).

Infix "*" := E0mul : E0_scope.

#[global, program] Instance Mult_i  (alpha: E0) (n: nat) : E0 :=
  @mkord (cnf alpha * n)%t1  _.
Next Obligation.  apply mult_nf_fin, cnf_ok. Defined.

(** ** Lemmas *)

(* begin hide *)

Lemma cnf_rw (alpha:T1)(H :nf alpha) : cnf (mkord H) = alpha.
Proof. reflexivity. Defined.

(* end hide *)


(** ** On equality on type [E0] *)

(* begin snippet nfProofUnicity:: no-out  *)

Lemma nf_proof_unicity :
  forall (alpha:T1) (H H': nf alpha), H = H'.
Proof.
  intros; red in H, H'; apply eq_proofs_unicity_on; decide equality.
Qed.
(* end snippet nfProofUnicity *)


Lemma E0_eq_intro : forall alpha beta : E0,
    cnf alpha = cnf beta -> alpha = beta. 
Proof.
  destruct alpha, beta; simpl; intros; subst; f_equal; auto; 
    apply nf_proof_unicity.
Qed.


(* begin snippet E0EqIff:: no-out *)

Corollary E0_eq_iff (alpha beta: E0) :
  alpha = beta <-> cnf alpha = cnf beta. 
(* end snippet E0EqIff *)

Proof.
 split.
 - intro; now f_equal.  
 - intro; now apply E0_eq_intro.
Qed.

Remark Le_iff : forall alpha beta,
    E0le alpha beta <-> T1.LE (@cnf alpha) (@cnf beta).
Proof.
  intros *; unfold E0le, T1.LE;  destruct alpha, beta; split.
  - cbn; rewrite le_lt_eq; destruct 1.
   + red in H; cbn in H; repeat split; auto; apply LE_le; repeat split; auto.
     destruct H as [H [H0 _]].
     now left.
   + repeat split; auto.
     injection H;  intro; subst; right.
  - cbn; destruct 1 as [_ [H _]]; rewrite le_lt_eq in H.
     destruct H. 
     + left; red;  cbn; repeat split; auto.
     + subst; cbn; unfold E0lt.
       generalize (E0_eq_intro  {| cnf := cnf1; cnf_ok := cnf_ok0 |}
                                {| cnf := cnf1; cnf_ok := cnf_ok1 |}).
       cbn; intro H; rewrite H.
       * now right.
       * reflexivity.
Qed.



Lemma Succb_Succ alpha : E0is_succ alpha -> {beta : E0 | alpha = E0succ beta}.
Proof.
  destruct alpha; cbn.
  intro H; destruct (T1is_succ_def cnf_ok0 H) as [beta [Hbeta Hbeta']]; subst.
  assert (nf (succ beta)) by eauto with T1.
  exists (@mkord  beta Hbeta); apply E0_eq_intro; now cbn.
Defined.

#[global] Hint Resolve E0_eq_intro : E0.

Ltac orefl := (apply E0_eq_intro; try reflexivity).

Ltac ochange alpha beta := (replace alpha with beta; [| orefl]).

Lemma E0_eq_dec : forall alpha beta: E0,
    {alpha = beta}+{alpha <> beta}.
Proof.
  destruct alpha, beta.
  destruct (T1_eq_dec cnf0 cnf1) as [e | n].
  - subst; left; auto with E0.
  - right; intro H; destruct n; now injection H.
Defined.

(** ** Adaptation to [E0] of lemmas about [T1]  *)

Lemma alpha_plus_zero alpha : alpha + E0zero = alpha.
Proof.
  apply E0_eq_intro; simpl; now rewrite plus_zero_r.
Qed.

Hint Rewrite alpha_plus_zero : E0_rw.

Lemma cnf_phi0 (alpha : E0) :
  cnf (E0phi0 alpha) = T1.phi0 (cnf alpha).
Proof.
 unfold E0phi0. now rewrite cnf_rw.
Defined.

Lemma cnf_Succ (alpha : E0) :
  cnf (E0succ alpha) = succ (cnf alpha).
Proof.
 unfold E0succ. now rewrite cnf_rw.
Defined.

Lemma cnf_Omega_term (alpha: E0) (n: nat) :
  cnf (Omega_term alpha n) = omega_term (cnf alpha) n.
Proof. reflexivity. Defined.

Lemma T1limit_Omega_term alpha i : alpha <> E0zero ->
                                  E0limit (Omega_term alpha i).
Proof.
  intro H; unfold E0limit; destruct alpha as [cnf0 H0]; cbn;
    destruct cnf0.
  - destruct H; auto with E0.  
  - red; trivial. 
Qed.

Lemma T1limit_phi0 alpha  : alpha <> E0zero ->
                           E0limit (E0phi0 alpha).
Proof.
  unfold E0phi0; apply T1limit_Omega_term.
Qed.

#[global] Hint Resolve T1limit_phi0 : E0.

Definition Zero_Limit_Succ_dec (alpha : E0) :
  {alpha = E0zero} + {E0limit alpha = true} +
  {beta : E0  | alpha = E0succ beta}.
  destruct alpha as [t Ht];  destruct (zero_limit_succ_dec  Ht).  
  -  destruct s. 
     + left; left. 
       unfold E0zero; subst t; f_equal.
       apply nf_proof_unicity.
     + left;right; unfold E0limit; now simpl. 
  -  destruct s as [beta [H0 H1]]; right;  eexists (@mkord beta H0).
     subst t; unfold E0succ; f_equal; apply nf_proof_unicity.
Defined.


Definition E0pred (alpha: E0) : E0 :=
  match Zero_Limit_Succ_dec  alpha with
      inl _ => alpha
    | inr (exist _ beta _) => beta
  end.


Tactic Notation "mko" constr(alpha) := refine (@mkord alpha eq_refl).

#[global] Instance Two : E0 :=  ltac:(mko (\F 2)).

#[global] Instance Omega_2 : E0 :=ltac:(mko (T1omega * T1omega)%t1).


#[global] Instance E0_sto : StrictOrder E0lt.
Proof.
  split.
  - intro x ; destruct x; unfold E0lt; red.
    cbn; intro; eapply LT_irrefl; eauto.
  - intros [x Hx] [y Hy] [z Hz]; unfold E0lt; cbn.
    apply LT_trans.
 Qed.

#[ global ] Instance compare_E0 : Compare E0 :=
 fun (alpha beta:E0) => compare (cnf alpha) (cnf beta).

Lemma compare_correct (alpha beta : E0) :
  CompSpec eq E0lt alpha beta (compare alpha beta).
Proof.
  destruct alpha, beta; unfold compare, E0lt; cbn;
    destruct (T1.compare_correct cnf0 cnf1).
  -   constructor 1;  apply E0_eq_intro;  subst; reflexivity. 
  -   constructor; now split.
  -  constructor; split; auto.
Qed.

(* begin snippet E0LtWf:: no-out *)
Lemma E0lt_wf : well_founded E0lt.
Proof.
  split; intros [t Ht] H;
    apply (Acc_inverse_image _ _ LT (@cnf) 
                             {| cnf := t; cnf_ok := Ht |});
    now apply T1.nf_Acc. 
Defined.
(* end snippet E0LtWf *)

#[global] Hint Resolve E0lt_wf : E0.

Lemma Lt_Succ_Le (alpha beta: E0):  beta o< alpha -> E0succ beta o<= alpha.
Proof.
  destruct alpha, beta;simpl in *.  unfold leq, E0lt; simpl.
  intro; rewrite Le_iff; split; auto.
  - apply T1.succ_nf; auto.
  -  split; auto.
     + apply T1.lt_succ_le;auto.
       destruct H; tauto.
Qed.



Lemma E0pred_of_Succ (alpha:E0) : E0pred (E0succ alpha) = alpha.
Proof.
  unfold E0pred; destruct (Zero_Limit_Succ_dec (E0succ alpha)).
  destruct s.
  - unfold E0succ, E0zero in e; injection  e .
    intro H; now   destruct (T1.succ_not_zero (cnf alpha)).
  -  unfold T1limit, E0succ in e; simpl in e;
       destruct (@T1.T1limit_succ (cnf alpha)); auto.
        destruct alpha; simpl; auto. 
  -  destruct s.
    { unfold E0succ in e;  injection e.
      destruct alpha, x;simpl; intros; apply T1.succ_injective in H; auto.
      -  subst; replace cnf_ok1 with cnf_ok0; trivial.
         eapply nf_proof_unicity.
    }
Qed.

Hint Rewrite E0pred_of_Succ: E0_rw.

Lemma Succ_inj alpha beta : E0succ alpha = E0succ beta -> alpha = beta.
Proof.
  destruct alpha, beta; intros;  apply E0_eq_intro. 
  cbn;  unfold E0succ in H; cbn in H; injection H. 
  intro; apply succ_injective; auto.
Qed.

Lemma  E0pred_Lt (alpha : E0) : alpha <> E0zero  ->  E0limit alpha = false ->
                       E0pred alpha o< alpha.
Proof.
  unfold E0limit, E0pred, E0lt; destruct alpha; intros. simpl.
  destruct (T1.zero_limit_succ_dec cnf_ok0 ).
  destruct s.
  - subst. unfold E0zero in H. destruct H. f_equal;apply nf_proof_unicity.
  - simpl in H0; rewrite i in H0; discriminate.
  - destruct s. destruct a. simpl. subst cnf0.
    apply LT_succ;auto.
Qed.

#[global] Hint Resolve E0pred_Lt : E0.


Lemma Succ_Succb (alpha : E0) : E0is_succ (E0succ alpha).
destruct alpha; unfold E0is_succ, E0succ; cbn; apply T1.succ_is_succ.
Qed.

#[global] Hint Resolve Succ_Succb : E0.

Ltac ord_eq alpha beta := assert (alpha = beta);
      [apply E0_eq_intro ; try reflexivity|].


Lemma FinS_eq i : E0finS i = E0fin (S i).
Proof. reflexivity. Qed.

Lemma mult_fin_rw alpha (i:nat) : alpha * i = Mult_i alpha i.
Proof.
 orefl; cbn; f_equal; now destruct i.
 Qed.


Lemma FinS_Succ_eq : forall i, E0finS i = E0succ (E0fin i).
Proof.
  intro i; compute. orefl; now destruct i.
Qed.

Hint Rewrite FinS_Succ_eq : E0_rw.

Lemma Limit_not_Zero alpha : E0limit alpha -> alpha <> E0zero.
Proof.
  destruct alpha; unfold E0limit, E0zero; cbn; intros H H0.
  injection H0;  intro ; subst cnf0; eapply T1.T1limit_not_zero; eauto.
Qed.


Lemma Succ_not_Zero alpha:  E0is_succ alpha -> alpha <> E0zero.
Proof.
  destruct alpha;unfold E0is_succ, E0zero; cbn.
  intros H H0; injection H0; intro;subst; discriminate H.
Qed.

Lemma Lt_Succ : forall alpha, E0lt alpha (E0succ alpha).
Proof.
  destruct  alpha; unfold lt, E0succ; cbn; apply LT_succ;auto.
Qed.


Lemma Succ_not_T1limit alpha : E0is_succ alpha -> ~ E0limit alpha .
Proof. 
  red; destruct alpha; unfold E0is_succ, E0limit; cbn.
  intros H H0. rewrite (succ_not_limit _ H) in H0. discriminate.  
Qed.

#[global]
  Hint Resolve Limit_not_Zero Succ_not_Zero Lt_Succ Succ_not_T1limit : E0.

Lemma lt_Succ_inv : forall alpha beta, beta o< alpha <->
                                       E0succ beta o<= alpha.
Proof.
  destruct alpha, beta; unfold lt, leq , E0succ; cbn; split.
  -  rewrite Le_iff.
     intro; now  apply LT_succ_LE.
  - rewrite Le_iff. intro. now apply LT_succ_LE_R.  
Qed.

Lemma lt_Succ_le_2 (alpha beta: E0):
    alpha o< E0succ beta -> alpha o<= beta.
Proof.
 destruct alpha, beta; cbn; intros.
 red in H; red; rewrite  Le_iff.
 cbn;  apply LT_succ_LE_2; auto.
Qed.

Lemma Succ_lt_T1limit alpha beta:
    E0limit alpha ->  beta o< alpha -> E0succ beta o< alpha.
Proof.
  destruct alpha, beta;unfold E0lt; cbn.
  intros; apply succ_lt_limit; auto. 
Qed.

Lemma le_lt_eq_dec : forall alpha beta, alpha o<= beta ->
                                        {alpha o< beta} + {alpha = beta}.
Proof.
  destruct alpha, beta. intros. rewrite Le_iff in H.
  destruct (LE_LT_eq_dec  H).
  - now left.
  - cbn in e; subst. right; subst; f_equal; apply nf_proof_unicity.
Qed.

(* begin snippet InstanceEpsilon0 *)

(*|
.. coq:: no-out
 *)

#[global] Instance E0_comp: Comparable E0lt compare.
Proof. split; [apply E0_sto | apply compare_correct]. Qed.

#[global] Instance Epsilon0 : ON E0lt compare.
Proof. split; [apply E0_comp | apply E0lt_wf]. Qed.

(*||*)
(* end snippet InstanceEpsilon0 *)

Definition Zero_limit_succ_dec : ZeroLimitSucc_dec .
  - intro alpha; destruct (Zero_Limit_Succ_dec alpha) as [[H | H] | [p Hp]].
    + subst alpha; left; left; intro beta. destruct beta as [cnf H].
      destruct cnf.
      replace  {| cnf := zero; cnf_ok := H |} with E0zero.
      right.
      apply E0_eq_intro. reflexivity.
      left.
      unfold E0lt.
      cbn.
      auto with T1.
    +
      destruct alpha as [a Ha]. unfold E0limit in H. cbn in H.
      left;right.
      split.  
      exists E0zero.
      destruct a;try discriminate.
      constructor. 
      destruct a2; try discriminate.
      auto with T1.
      auto with T1.
      split.
      constructor.
      auto.

      intros. 
      exists (E0succ y).
      split.
      apply Lt_Succ.
      destruct y as [y Hy]; split.
      unfold E0lt, E0succ; cbn.
      now apply LT_succ.
      unfold E0lt, E0succ in *.
      cbn in *.
      apply succ_lt_limit; auto.

    + 
      right.
      exists p;
        subst.
      red. 
      split.
      apply Lt_Succ.

      destruct p, z. unfold E0lt, E0succ; cbn in *; intros.
      destruct (@LT_irrefl cnf1).
      apply T1.LT_LE_trans with (succ cnf0); auto with T1.
      now apply LT_succ_LE.
Qed.





(** ** Rewriting lemmas *)

Lemma Succ_rw : forall alpha, cnf (E0succ alpha) = T1.succ (cnf alpha).
Proof.
  now destruct alpha.
Qed.

Lemma Plus_rw : forall alpha beta, cnf (alpha + beta) =
                                   (cnf alpha + cnf beta)%t1.
Proof.
  now destruct alpha, beta.
Qed.


Lemma Lt_trans alpha beta gamma :
  alpha o< beta -> beta o< gamma -> alpha o< gamma.
Proof.
  destruct alpha, beta, gamma; simpl. unfold lt.
  simpl.
 intros; eauto with T1.
 eapply T1.LT_trans; eauto.
Qed.

Lemma Le_trans alpha beta gamma :
  alpha o<= beta -> beta o<= gamma -> alpha o<= gamma.
Proof.
  destruct alpha, beta, gamma; simpl. repeat rewrite Le_iff; cbn. 
 intros; eauto with T1.
 eapply T1.LE_trans; eauto.
Qed.



Lemma Omega_term_plus alpha beta i :
  alpha <> E0zero -> (beta o< E0phi0 alpha)%e0 ->
  cnf (Omega_term alpha i + beta)%e0 = cons (cnf alpha) i (cnf beta).
Proof.
  destruct alpha as [alpha Halpha]; destruct beta as [beta Hbeta].
  intros.
  unfold lt in H0. simpl in H0.
  unfold  Omega_term. unfold cnf.
  unfold E0add.
  unfold cnf at 1 2.
  fold (omega_term alpha i ).
  rewrite omega_term_plus_rw.
  reflexivity.
  rewrite nf_LT_iff; tauto.
Qed.


Lemma cnf_Cons (alpha beta: E0) n : alpha <> E0zero -> beta o< E0phi0 alpha ->
                                     cnf (Cons alpha n beta) =
                                     cons (cnf alpha) n (cnf beta).
Proof.
  intros. unfold Cons. rewrite Omega_term_plus; auto.
Defined.

Lemma T1limit_plus alpha beta i:
  (beta o< E0phi0 alpha)%e0 -> E0limit beta ->
  E0limit  (Omega_term alpha i + beta)%e0.
Proof.
  intros H H0;  assert (alpha <> E0zero).
  { intro; subst. 
    apply (Limit_not_Zero H0).
    destruct beta.
    red in H. simpl in H.
    apply LT_one in H. subst.
    now apply E0_eq_intro.
  }
  unfold E0limit; rewrite Omega_term_plus; auto.
  cbn;  case_eq (cnf alpha).
  -  intro H2; destruct H1.
     apply E0_eq_intro.
     apply H2.
  -  intros alpha0 n beta0 H2.
     unfold E0limit in H0;    destruct (cnf beta); auto.
Qed.


Lemma Succ_of_cons alpha gamma i : alpha <> E0zero -> gamma o< E0phi0 alpha ->
                                cnf (E0succ (Omega_term alpha i + gamma)%e0) =
                                cnf (Omega_term alpha i + E0succ gamma)%e0.
Proof.
  intros.
  rewrite Omega_term_plus; auto.
  rewrite Succ_rw.
  rewrite Omega_term_plus; auto.
  rewrite succ_cons', Succ_rw; auto.
  intro H1; apply H, E0_eq_intro.   assumption. 
  destruct H0.
  destruct H1.
  rewrite cnf_phi0 in H1.
  apply nf_intro; auto.
  now apply nf_helper_phi0R. 
  red.  
  apply succ_lt_limit.
  rewrite cnf_phi0.
  apply nf_phi0. apply cnf_ok.
  rewrite cnf_phi0.
  simpl.
  case_eq (cnf alpha).
  intro.
  destruct H.
  apply E0_eq_intro. assumption.
  intros; trivial. 
  now red.   
  assumption.
Qed.


#[global, program] Instance Oplus (alpha beta : E0) : E0 :=
@mkord (oplus (cnf alpha) (cnf beta)) _.
Next Obligation. apply oplus_nf; apply cnf_ok. Defined.

Infix "O+" := Oplus (at level 50, left associativity): E0_scope.

#[global] Instance Oplus_assoc : Assoc eq Oplus.
Proof. 
 red;  destruct x,y, z. unfold Oplus.  cbn.
  apply E0_eq_intro; cbn; now rewrite oplus_assoc.
Qed.
 
Lemma oPlus_rw (alpha beta : E0) :
  cnf (alpha O+ beta)%e0 = (cnf alpha o+ cnf beta)%t1.
Proof.
  now destruct alpha, beta.
Qed.


Example L_3_plus_omega :  3 + E0omega = E0omega.
Proof.
  now  rewrite <- Comparable.compare_eq_iff.
Qed.


(* to simplify ! *)

Lemma succ_correct alpha beta : cnf beta = succ (cnf alpha) <->
                                Successor beta alpha.
Proof.
  destruct alpha, beta; cbn; split.
  -  intro; subst.  
     split.
     +  unfold ON_lt; red; cbn; red; red; repeat split; auto.
        apply lt_succ.
     +  destruct z;  unfold E0lt; cbn; intros.
        assert (cnf1 t1< cnf1)%t1.
        { repeat split; auto.
          apply lt_le_trans with (succ cnf0).
          destruct H0; auto with T1.
          now destruct H1.
          apply lt_succ_le; auto.
          apply H.
        }
        destruct H1.
        destruct H2.
        eapply T1.lt_irrefl; eauto. 
  - destruct 1.
    unfold E0lt in H, H0. cbn in H, H0.
    destruct H.
    destruct H1.
    + apply lt_succ_le in H1; auto.
      * destruct H1; auto.
        specialize (H0 (E0succ (mkord cnf_ok0))).
        cbn in H0; unfold LT in H0.
        exfalso.
        apply H0.
        -- split; auto with T1.
           split; auto with T1.
           ++ apply lt_succ;eauto with T1.
           ++ apply succ_nf; auto.
        -- split; auto with T1.
           apply succ_nf; auto.
Qed.


Lemma Le_refl alpha : alpha o<= alpha.
Proof.
  right. 
Qed.

Lemma Lt_Le_incl alpha beta : alpha o< beta -> alpha o<= beta.
Proof.
  unfold E0lt, E0le.
  intro; rewrite le_lt_eq.
 destruct alpha, beta. left. auto. 
Qed.

Lemma E0_Lt_irrefl (alpha : E0) : ~ alpha o< alpha.
Proof.
  destruct alpha;unfold E0lt;cbn;apply LT_irrefl.
Qed.

Lemma E0_Lt_Succ_inv (alpha beta: E0):
  alpha o< E0succ beta -> alpha o< beta \/ alpha = beta.
Proof.
  destruct alpha, beta; unfold E0lt; cbn; intros.
  destruct (LT_succ_LE_2 cnf_ok1 H) as [H0 [H1 H2]].
  destruct H1 as [H3 |].
  - left; split; auto.
  - subst; right; now apply E0_eq_intro.
Qed.

Lemma E0_not_Lt_zero alpha : ~ alpha o< E0zero.
Proof.
  destruct alpha; unfold E0lt; cbn.
  intros [H [H0 H1]]; eapply not_lt_zero; eauto. 
Qed.

Lemma lt_omega_inv: forall alpha:E0,  alpha o< E0omega ->
                                      exists (i:nat),  alpha = E0fin i.
Proof. 
  destruct alpha;  unfold E0omega; cbn in *; intro.
  destruct H.
  destruct H0.
  cbn in H0.
  assert (H2 : cnf0 t1< T1omega).
  {  split; cbn in H1; tauto. }
  destruct (lt_omega_inv H2).
  - exists 0; subst;  unfold E0fin; apply E0_eq_intro;  reflexivity. 
  -  destruct H3; subst;  exists (S x); apply E0_eq_intro; reflexivity.
Qed.


Lemma E0_lt_eq_lt alpha beta : alpha o< beta \/ alpha = beta \/ beta o< alpha.
Proof.
  destruct (compare_correct alpha beta).
  - subst;right;now left.
  - now left.
  - right; now right.
Qed.

Lemma E0_lt_ge alpha beta : alpha o< beta \/ beta o<= alpha.
Proof.
  destruct (E0_lt_eq_lt alpha beta) as [H | [ | H]].
  - now left.
  - subst; right. apply Le_refl.
  - right; now apply Lt_Le_incl.
Qed.

Lemma Limit_gt_Zero (alpha: E0) : E0limit alpha -> E0zero o< alpha.
Proof.
  intro H; destruct (E0_lt_eq_lt alpha E0zero) as [H0 | [H0 | H0]]; trivial.
  - destruct (E0_not_Lt_zero H0).
  - subst; discriminate H.
Qed.


Lemma phi0_mono alpha beta : alpha o< beta -> E0phi0 alpha o< E0phi0 beta.
Proof.
  destruct alpha, beta; unfold E0lt; cbn;  auto with T1.
Qed.


#[global] Instance plus_assoc : Assoc eq E0add . 
Proof.
  intros alpha beta gamma; destruct alpha, beta, gamma; apply E0_eq_intro; cbn;
  apply  T1.T1addA.
Qed.


Theorem mult_plus_distr_l (alpha beta gamma: E0) :
  alpha * (beta + gamma) = alpha * beta + alpha * gamma.
Proof.
  destruct alpha, beta, gamma; apply E0_eq_intro; cbn;
  now apply  T1.mult_plus_distr_l.
Qed.

(* begin snippet Ex42 *)
Example Ex42: E0omega + 42 + E0omega^2 = E0omega^2. (* .no-out *)
Proof. (* .no-out *)
  rewrite <-  Comparable.compare_eq_iff.
  reflexivity.
Qed.
(* end snippet Ex42 *)
