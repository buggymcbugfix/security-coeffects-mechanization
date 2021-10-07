{-# OPTIONS --allow-unsolved-metas #-}
{-# OPTIONS --inversion-max-depth=100 #-}

module RelationalModelGhostAlt where

open import GrCore hiding (_⊢_∶_)
open import GrCoreGhost

open import Data.Unit hiding (_≤_; _≟_)
open import Data.Empty
open import Relation.Binary.PropositionalEquality
open import Data.Product
open import Data.Bool hiding (_≤_; _≟_)
open import Data.List hiding (_++_)
open import Data.Nat hiding (_≤_)
open import Function
open import Data.Maybe
open import Relation.Nullary
open import Data.Sum
open import Data.Maybe.Properties

open import Semiring

-- open Semiring.Semiring {{...}} public
-- open NonInterferingSemiring  {{...}} public
-- open InformationFlowSemiring {{...}} public

open import RelationalModel

-- Contexts

-- unary
-- [_]Γg : {{R : Semiring}} -> {s : ℕ} -> ContextG s -> List Term -> Set
-- [ (Γ , ghostGrade) ]Γg γ = [ Γ ]Γ γ

-- binary
data ⟦_⟧Γg {{R : Semiring}} : {s : ℕ} -> ContextG s -> (adv : grade) -> List Term -> List Term -> Set where
    visible : {sz : ℕ} {Γ : Context sz} {ghost adv : grade} {γ1 γ2 : List Term}
            -> ghost ≤ adv -> ⟦ Γ ⟧Γ adv γ1 γ2 -> ⟦ Γ , ghost ⟧Γg adv γ1 γ2

    invisible : {sz : ℕ} {Γ : Context sz} {ghost adv : grade} {γ1 γ2 : List Term}
            -> ¬ (ghost ≤ adv) -> [ Γ ]Γ γ1 × [ Γ ]Γ γ2 -> ⟦ Γ , ghost ⟧Γg adv γ1 γ2


injPair1 : {A : Set} {B : Set} {a a' : A} {b b' : B} -> (a , b) ≡ (a' , b') -> a ≡ a'
injPair1 refl = refl

injPair2 : {A : Set} {B : Set} {a a' : A} {b b' : B} -> (a , b) ≡ (a' , b') -> b ≡ b'
injPair2 refl = refl

unpackObs : {{R : Semiring}} {A : Type} {v1 v2 : Term} {r adv : grade}
          -> (r ≤ adv)
          -> ⟦ Box r A ⟧v adv (Promote v1) (Promote v2) -> ⟦ A ⟧e adv v1 v2
unpackObs {A} {v1} {v2} {r} {adv} pre (boxInterpBiobs _ .v1 .v2 innerExprInterp) = innerExprInterp
unpackObs {A} {v1} {v2} {r} {adv} pre (boxInterpBiunobs eq .v1 .v2 innerExprInterp) = ⊥-elim (eq pre)

unpackUnobs : {{R : Semiring}} {A : Type} {v1 v2 : Term} {r adv : grade}
          -> ¬ (r ≤ adv)
          -> ⟦ Box r A ⟧v adv (Promote v1) (Promote v2) -> ([ A ]e v1 × [ A ]e v2)
unpackUnobs {A} {v1} {v2} {r} {adv} pre (boxInterpBiobs eq .v1 .v2 innerExprInterp) = ⊥-elim (pre eq)
unpackUnobs {A} {v1} {v2} {r} {adv} pre (boxInterpBiunobs eq .v1 .v2 innerExprInterp) = innerExprInterp

{-
-- can probably delete
unpackEvidence : {{R : Semiring}}
                 {s : ℕ}
                 { Γ Γ1 Γ2 : ContextG s }
                 {r : grade}
                 (rel : Γ ≡ (Γ1 ++g (r ·g Γ2)))
               -> Σ grade (\ghost ->
                    Σ (Context s × grade) (\(Γ1' , g1) ->
                      Σ (Context s × grade) (\(Γ2' , g2) ->
                        (Γ ≡ (Γ1' ++ (r · Γ2') , ghost))
                      × (Γ1 ≡ (Γ1' , g1))
                      × (Γ2 ≡ (Γ2' , g2))
                      × (just ghost ≡ partialJoin g1 (r *R g2))
                    )
                   )
                  )
unpackEvidence {s = s} {Γ} {fst , snd} {fst₁ , snd₁} {r} rel = {!!}
-}

justInj : {A : Set} {a1 a2 : A} -> just a1 ≡ just a2 -> a1 ≡ a2
justInj {A} {a1} {.a1} refl = refl


binaryImpliesUnaryGg : {{R : Semiring}} {sz : ℕ} { Γ : Context sz } {adv : grade} {γ1 γ2 : List Term}
                    -> ⟦ Γ ⟧Γ adv γ1 γ2 -> ([ Γ ]Γ γ1) × ([ Γ ]Γ γ2)
binaryImpliesUnaryGg {.0} {Empty} {adv} {_} {_} pre = tt , tt
binaryImpliesUnaryGg {suc sz} {Ext Γ (Grad A r)} {adv} {v1 ∷ γ1} {v2 ∷ γ2} (arg , rest)
  with binaryImpliesUnary {Box r A} {Promote v1} {Promote v2} {adv} arg | binaryImpliesUnaryG {sz} {Γ} {adv} {γ1} {γ2} rest
... | ( arg1 , arg2 ) | ( rest1 , rest2 ) = ( (arg1 , rest1) , (arg2 , rest2) )

postulate
  multiSubstTyG : {{R : Semiring}} {{R' : InformationFlowSemiring R }} -> {n : ℕ} {Γ : ContextG n} {t : Term} {A : Type} {γ : List Term} {ghost : grade} -> Γ ⊢ t ∶ A -> (Empty , ghost) ⊢ multisubst' 0 γ t ∶ A

  reduxTheoremAppTyG : {{R : Semiring}} {{R' : InformationFlowSemiring R }}
                 -> {t1 t2 v : Term} {s : ℕ} {Γ : Context s} {A B : Type} {r : grade} {ghost : grade}
                 -> multiRedux (App t1 t2) ≡ v
                 -> (Γ , ghost) ⊢ t1 ∶ FunTy A r B
                 -> Σ (ℕ × Term) (\(z , v1') -> multiRedux t1 ≡ Abs z v1' × (((Ext Γ (Grad A r)) , ghost) ⊢ (Abs z v1') ∶  B))

  multireduxPromoteLemma :
    {{ R : Semiring }}
    {adv r : grade}
    {τ : Type}
    {t1 t2 : Term}
    -> ⟦ Box r τ ⟧e adv t1 t2
    -> Σ (Term × Term) (\(v1 , v2) -> multiRedux t1 ≡ Promote v1 × multiRedux t2 ≡ Promote v2)


promoteLemma : {t t' t'' : Term} -> Promote t ≡ t' -> Σ Term (\t'' -> Promote t'' ≡ t')
promoteLemma {t} {t'} {t''} pre = t , pre

extractUn : {{R : Semiring}} {r : grade} {A : Type} {v : Term} -> [ Box r A ]e (Promote v) -> [ A ]e v
extractUn {r} {A} {v} ab v1 v1redux with ab (Promote v) refl
... | boxInterpV _ inner = inner v1 v1redux

utheoremG : {{R : Semiring}} {{R' : InformationFlowSemiring R}} {s : ℕ} {γ : List Term}
        -> {Γ : Context s} {ghost : grade} {e : Term} {τ : Type}
        -> (Γ , ghost) ⊢ e ∶ τ
        -> [ Γ ]Γ γ
        -> [ τ ]e (multisubst γ e)
utheoremG = {!!}


-- under some constraints perhaps
-- unaryImpliesBinarySpecialised : {e : Term} {τ : Type}
--  ⟦ τ ⟧e t

-- Probably going to delete this
sameContext : {{R : Semiring}}
              {sz : ℕ} {Γ : Context sz}
              {s adv : grade}
              {γ1 γ2 : List Term}
            -> ⟦ s · Γ ⟧Γ adv γ1 γ2
            -> (s ≤ adv)
            -> γ1 ≡ γ2
sameContext ⦃ R ⦄ {.0} {Empty} {s} {adv} {[]} {[]} ctxt pre = refl
sameContext ⦃ R ⦄ {.(suc _)} {Ext Γ x} {s} {adv} {[]} {[]} ctxt pre = refl
sameContext ⦃ R ⦄ {.(suc _)} {Ext Γ (Grad A r)} {s} {adv} {[]} {x₁ ∷ γ2} () pre
sameContext ⦃ R ⦄ {.(suc _)} {Ext Γ (Grad A r)} {s} {adv} {x₁ ∷ γ1} {[]} () pre
sameContext ⦃ R ⦄ {.(suc _)} {Ext Γ (Grad A r)} {s} {adv} {x₁ ∷ γ1} {x₂ ∷ γ2} (ctxtHd , ctxtTl) pre
 with s · (Ext Γ (Grad A r)) | ctxtHd (Promote x₁) (Promote x₂) refl refl
... | Ext sΓ (Grad A' sr) | boxInterpBiobs pre2 .x₁ .x₂ inner = {!!}
... | Ext sΓ (Grad A' sr) | boxInterpBiunobs pre2 .x₁ .x₂ inner = {!!}

{-
equalUnderSubst : {{R : Semiring}}
              {sz : ℕ} {Γ : Context sz} {e : Term} {τ : Type}
              {s adv : grade}
              {γ1 γ2 : List Term}
            -> ⟦ s · Γ ⟧Γ adv γ1 γ2
            -> Γ ⊢ e ∶ τ
            -> (s ≤ adv)
            -> multisubst γ1 e ≡ multisubst γ2 e
equalUnderSubst = ?
-}

delta : {{R : Semiring}}
        {adv r s : grade}
        {t1 t2 : Term}
        {τ : Type}
      -> ⟦ Box (s *R r) τ ⟧v adv (Promote t1) (Promote t2)
      -> ⟦ Box s (Box r τ) ⟧v adv (Promote (Promote t1)) (Promote (Promote t2))

delta ⦃ R ⦄ {adv} {r} {s} {t1} {t2} {τ} (boxInterpBiobs pre .t1 .t2 inpInner)
  with s ≤d adv | r ≤d adv
... | yes p1 | yes p2 = boxInterpBiobs p1 (Promote t1) (Promote t2) inner
  where
    inner : ⟦ Box r τ ⟧e adv (Promote t1) (Promote t2)
    inner v1 v2 v1redux v2redux
     rewrite (sym v1redux) | (sym v2redux) =
       boxInterpBiobs p2 t1 t2 inpInner

... | yes p1 | no ¬p2 = boxInterpBiobs p1 (Promote t1) (Promote t2) {!!}
  where
    innerInp : [ τ ]v t1 × [ τ ]v t2
    innerInp = {!!}

    inner : ⟦ Box r τ ⟧e adv (Promote t1) (Promote t2)
    inner v1 v2 v1redux v2redux
      rewrite (sym v1redux) | (sym v2redux) =
        boxInterpBiunobs ¬p2 t1 t2 {!!}


... | no ¬p1 | yes p2 =
  boxInterpBiunobs ¬p1 (Promote t1) (Promote t2) ({!!} , {!!})

... | no ¬p1 | no ¬p2 = {!!}

delta ⦃ R ⦄ {adv} {r} {s} {t1} {t2} {τ} (boxInterpBiunobs pre .t1 .t2 inpInner) = {!!}

{-
delta {{R}} {adv} {r} {s} {t1} {t2} {τ} inp with s ≤d adv | r ≤d adv | (s *R r) ≤d adv
delta ⦃ R ⦄ {adv} {r} {s} {t1} {t2} {τ} (boxInterpBiobs pre .t1 .t2 inpInner) | yes p1 | yes p2 | yes p3 =
   boxInterpBiobs p1 (Promote t1) (Promote t2) inner
  where
   inner : ⟦ Box r τ ⟧e adv (Promote t1) (Promote t2)
   inner v1 v2 v1redux v2redux
     rewrite (sym v1redux) | (sym v2redux) =
       boxInterpBiobs p2 t1 t2 inpInner

delta ⦃ R ⦄ {adv} {r} {s} {t1} {t2} {τ} (boxInterpBiunobs pre .t1 .t2 x₁) | yes p1 | yes p2 | yes p3 =
  ⊥-elim (pre p3)

... | yes p1 | yes p2 | no ¬p3 =
  {!!}

... | yes p1 | no ¬p2 | yes p3 = {!!}
... | yes p1 | no ¬p2 | no ¬p3 = {!!}
... | no ¬p1 | yes p2 | yes p3 = {!!}
... | no ¬p1 | yes p2 | no ¬p3 = {!!}
... | no ¬p1 | no ¬p2 | yes p3 = {!!}
... | no ¬p1 | no ¬p2 | no ¬p3 = {!!}
-}

-- elimInversion

mutual


    convertValL+ : {{R : Semiring}} {{R' : InformationFlowSemiring R}}
               -> {r1 r2 adv : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r1 +R r2) A ⟧v adv (Promote v1) (Promote v2) -> ⟦ Box r1 A ⟧v adv (Promote v1) (Promote v2)
    convertValL+ {r1 = r1} {r2} {adv} {v1} {v2} {A} (boxInterpBiobs pre .v1 .v2 inner)   with r1 ≤d adv
    ... | yes p = boxInterpBiobs p v1 v2 inner
    ... | no ¬p = boxInterpBiunobs ¬p v1 v2 (binaryImpliesUnary {A} {v1} {v2} {adv} inner)
    convertValL+ {{R}} {{R'}} {r1 = r1} {r2} {adv} {v1} {v2} {A} (boxInterpBiunobs pre .v1 .v2 inner) = boxInterpBiunobs (\eq -> pre (plusMono R' eq)) v1 v2 inner

    convertValR+ : {{R : Semiring}} {{R' : InformationFlowSemiring R}}
               -> {r1 r2 adv : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r1 +R r2) A ⟧v adv (Promote v1) (Promote v2) -> ⟦ Box r2 A ⟧v adv (Promote v1) (Promote v2)
    convertValR+ {r1 = r1} {r2} {adv} {v1} {v2} {A} (boxInterpBiobs pre .v1 .v2 inner)   with r2 ≤d adv
    ... | yes p = boxInterpBiobs p v1 v2 inner
    ... | no ¬p = boxInterpBiunobs ¬p v1 v2 (binaryImpliesUnary {A} {v1} {v2} {adv} inner)
    convertValR+ {{R}} {{R'}} {r1 = r1} {r2} {adv} {v1} {v2} {A} (boxInterpBiunobs pre .v1 .v2 inner) =
      boxInterpBiunobs (\pre' -> pre (plusMonoSym pre')) v1 v2 inner

    contextSplitLeft : {{R : Semiring}} {{R' : InformationFlowSemiring R}} {sz : ℕ} {Γ1 Γ2 : ContextG sz} {γ1 γ2 : List Term} {adv : grade}
                     -> ⟦ Γ1 ++g Γ2 ⟧Γg adv γ1 γ2 -> ⟦ Γ1 ⟧Γg adv γ1 γ2
    contextSplitLeft {{R}} {{R'}} {sz = sz} {Γ1 , g1} {Γ2 , g2} {γ1} {γ2} {adv} (visible pre inner) with g1 ≤d adv
    ... | yes p = visible p (binaryPlusElimLeftΓ convertValL+ inner)
    ... | no ¬p = invisible ¬p (binaryImpliesUnaryG (binaryPlusElimLeftΓ convertValL+ inner)) -- okay because we can do binaryImpliesUnary
    contextSplitLeft {{R}} {{R'}} {sz = sz} {Γ1 , g1} {Γ2 , g2} {γ1} {γ2} {adv} (invisible pre inner) with g1 ≤d adv
    ... | yes p = ⊥-elim (pre (plusMono R' p))
    ... | no ¬p = invisible ¬p (unaryPlusElimLeftΓ (proj₁ inner) , unaryPlusElimLeftΓ (proj₂ inner))

    contextSplitRight : {{R : Semiring}} {{R' : InformationFlowSemiring R}} {sz : ℕ} {Γ1 Γ2 : ContextG sz} {γ1 γ2 : List Term} {adv : grade}
                     -> ⟦ Γ1 ++g Γ2 ⟧Γg adv γ1 γ2 -> ⟦ Γ2 ⟧Γg adv γ1 γ2
    contextSplitRight {{R}} {{R'}} {sz = sz} {Γ1 , g1} {Γ2 , g2} {γ1} {γ2} {adv} (visible pre inner) with g2 ≤d adv
    ... | yes p = visible p (binaryPlusElimRightΓ convertValR+ inner)
    ... | no ¬p = invisible ¬p (binaryImpliesUnaryG (binaryPlusElimRightΓ convertValR+ inner))
    contextSplitRight {{R}} {{R'}} {sz = sz} {Γ1 , g1} {Γ2 , g2} {γ1} {γ2} {adv} (invisible pre inner) with g2 ≤d adv
    ... | yes p = ⊥-elim (pre (plusMonoSym p))
    ... | no ¬p = invisible ¬p ((unaryPlusElimRightΓ (proj₁ inner)) , (unaryPlusElimRightΓ (proj₂ inner)))

    convertValR* : {{R : Semiring}} {{R' : InformationFlowSemiring R}}
               -> {r1 r2 adv : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r1 *R r2) A ⟧v adv (Promote v1) (Promote v2) -> ⟦ Box r2 A ⟧v adv (Promote v1) (Promote v2)
    convertValR* {r1 = r1} {r2} {adv} {v1} {v2} {A} (boxInterpBiobs pre .v1 .v2 inner)   with r2 ≤d adv
    ... | yes p = boxInterpBiobs p v1 v2 inner
    ... | no ¬p = boxInterpBiunobs ¬p v1 v2 (binaryImpliesUnary {A} {v1} {v2} {adv} inner)
    convertValR* {{R}} {{R'}} {r1 = r1} {r2} {adv} {v1} {v2} {A} (boxInterpBiunobs pre .v1 .v2 inner) =
      boxInterpBiunobs (\pre' -> pre (subst (\h -> h ≤ adv) com* (timesLeft pre'))) v1 v2 inner

    contextElimTimes : {{R : Semiring}} {{R' : InformationFlowSemiring R}} {sz : ℕ} {Γ1 : ContextG sz} {γ1 γ2 : List Term} {r adv : grade}
                     -> ⟦ r ·g Γ1 ⟧Γg adv γ1 γ2 -> ⟦ Γ1 ⟧Γg adv γ1 γ2
    contextElimTimes {{R}} {{R'}} {sz = sz} {Γ1 , g1} {γ1} {γ2} {r} {adv} (visible pre inner) with g1 ≤d adv
    ... | yes p = visible p (binaryTimesElimRightΓ convertValR* inner)
    ... | no ¬p = invisible ¬p (binaryImpliesUnaryG (binaryTimesElimRightΓ convertValR* inner))
    contextElimTimes {{R}} {{R'}} {sz = sz} {Γ1 , g1} {γ1} {γ2} {r} {adv} (invisible pre inner) with g1 ≤d adv
    ... | yes p rewrite com* {R} {r} {g1} = ⊥-elim (pre (timesLeft p))
    ... | no ¬p = invisible ¬p ((unaryTimesElimRightΓ (proj₁ inner)) , (unaryTimesElimRightΓ (proj₂ inner)))


    intermediateSub : {{R : Semiring}} {{R' : InformationFlowSemiring R}}  {sz : ℕ}
                  {Γ : Context sz}
                  {ghost r adv : grade}
                  {γ1 γ2 : List Term}
                  {e : Term}
                  {A : Type}
               -> (Γ , ghost) ⊢ e ∶ A
               -> r ≤ adv
               -> ⟦ r ·g (Γ , ghost) ⟧Γg adv γ1 γ2
               -> [ A ]e (multisubst γ1 e)
               -> [ A ]e (multisubst γ2 e)
               -> ⟦ A ⟧e adv (multisubst γ1 e) (multisubst γ2 e)

    -- Case where
    --  (x : A, ghost) ⊢ x : A
    intermediateSub {Γ = Γ} {ghost} {r} {adv} {a1 ∷ γ1'} {a2 ∷ γ2'} {.(Var 0)} {A} (var {Γ1 = Empty} {Γ2} pos) pre inp e1 e2 v1 v2 v1redux v2redux
     rewrite (injPair1 pos) with inp | r · Γ | inspect (\r -> r · Γ) r
    ... | visible pre2 (arg , _) | Ext ad (Grad A' r₁) | Relation.Binary.PropositionalEquality.[ eq ] = conc
      where
        conc : ⟦ A ⟧v adv v1 v2
        conc with arg (Promote a1) (Promote a2) refl refl
        ... | boxInterpBiobs _ .a1 .a2 argInner = argInner v1 v2 (isSimultaneous' {v1} {a1} {γ1'} v1redux) ((isSimultaneous' {v2} {a2} {γ2'} v2redux))
        ... | boxInterpBiunobs preN .a1 .a2 argInner = ⊥-elim ((subst (\h -> h ≤ adv -> ⊥) {!   !} preN) pre)  -- used to use equality rightUnit*

    -- Here we have that `r ≤ adv` but `¬ ((r * ghost) ≤ adv)`
    -- ah but we also know that `ghost = 1` so ... we get a contradiction
    ... | invisible pre2 inner | Ext ad x | Relation.Binary.PropositionalEquality.[ eq ] =
      ⊥-elim ((subst (\h -> h ≤ adv -> ⊥) (trans (cong (\h -> r *R h) (injPair2 pos)) {!   !}) pre2) pre) -- NEXT: rightUnit* used to be

    intermediateSub {Γ = Γ} {ghost} {r} {adv} {γ1} {γ2} {.(Var _)} {A} (var {Γ1 = _} {Γ2} pos) pre inp e1 e2 =
      {!!} -- generalises the above, skipping for simplicity (just apply exchange basically)


    intermediateSub {Γ = Γ} {ghost} {r} {adv} {γ1} {γ2} {e} {A} (approx typ approx1 approx2 sub) pre inp e1 e2 =
      {!!}

    intermediateSub {sz = sz} {Γ = Γ} {ghost} {r} {adv} {γ1} {γ2} {.(App t1 t2)} {.B} (app {Γ1 = (Γ1 , g1)} {Γ2 = (Γ2 , g2)} {s} {A} {B} {t1} {t2} typ1 typ2 {ctxtP}) pre inp e1 e2
       v1 v2 v1redux v2redux =
      let
        ih1 = intermediateSub typ1 pre subContext1 (proj₁ ih1evidence) (proj₂ ih1evidence)

        v1redux' = trans (sym (cong multiRedux (substPresApp {0} {γ1} {t1} {t2}))) v1redux
        ((x , t) , (funRed , substRed)) = reduxTheoremAll {multisubst γ1 t1} {multisubst γ1 t2} {v1} v1redux'

        v2redux' = trans (sym (cong multiRedux (substPresApp {0} {γ2} {t1} {t2}))) v2redux
        ((x' , t') , (funRed' , substRed')) = reduxTheoremAll {multisubst γ2 t1} {multisubst γ2 t2} {v2} v2redux'

        -- ih2 = intermediateSub typ2 pre subContext2 (proj₁ ih2evidence) (proj₂ ih2evidence)
        -- An alternate approach which may be needed
        -- (ih2u1 , ih2u2) = binaryImpliesUnary ih2
        ih2alt = intermediateSub (pr {sz} {(Γ2 , g2)} {r = s} typ2) pre subContext2alt (arg1 (proj₁ ih2evidence)) (arg2 (proj₂ ih2evidence))
        ih2alt' = subst₂ (\h1 h2 -> ⟦ Box s A ⟧e adv h1 h2) (substPresProm {0} {γ1} {t2}) (substPresProm {0} {γ2} {t2}) ih2alt
        ih1' = ih1 (Abs x t) (Abs x' t') funRed funRed'

      in
        goal x x' (multisubst γ1 t2) (multisubst γ2 t2) t t' ih1' ih2alt' substRed substRed'
      where
        arg1 : [ A ]e (multisubst γ1 t2) -> [ Box s A ]e (multisubst γ1 (Promote t2))
        arg1 arg v vredux rewrite sym vredux =
         let q = (sym (substPresProm {0} {γ1} {t2}))
         in subst (\h -> [ Box s A ]v h) (trans (sym reduxProm) (cong multiRedux q)) (boxInterpV (multisubst γ1 t2) arg) -- rewrite trans (sym vredux) (cong multiRedux substPresProm) = boxInterpV (multisubst γ1 t2) arg

        arg2 : [ A ]e (multisubst γ2 t2) -> [ Box s A ]e (multisubst γ2 (Promote t2))
        arg2 arg v vredux rewrite sym vredux =
          let q = (sym (substPresProm {0} {γ2} {t2}))
          in subst (\h -> [ Box s A ]v h) (trans (sym reduxProm) (cong multiRedux q)) (boxInterpV (multisubst γ2 t2) arg)

        {-
        Left over from an alternate attempt
        arg :  ⟦ A ⟧e adv (multisubst γ1 t2) (multisubst γ2 t2)
          -> ⟦ Box s A ⟧e adv (Promote (multisubst γ1 t2)) (Promote (multisubst γ2 t2))
        arg inp vArg1 vArg2 vArg1redux vArg2redux
         rewrite trans (sym vArg1redux) reduxProm
                | trans (sym vArg2redux) reduxProm with s ≤d adv
        ... |  yes p = boxInterpBiobs p (multisubst' zero γ1 t2) (multisubst' zero γ2 t2) inp
        ... | no ¬p = boxInterpBiunobs ¬p (multisubst' zero γ1 t2) (multisubst' zero γ2 t2) (binaryImpliesUnary inp)
        -}

        goal : (x y : ℕ) (ta ta' bodyt bodyt' : Term)
             -> ⟦ FunTy A s B ⟧v adv (Abs x bodyt) (Abs y bodyt')
             -> ⟦ Box s A ⟧e adv (Promote ta) (Promote ta')
             -> multiRedux (syntacticSubst ta x bodyt) ≡ v1
             -> multiRedux (syntacticSubst ta' y bodyt') ≡ v2
             -> ⟦ B ⟧v adv v1 v2
        goal x y ta ta' bodyt bodyt' ih1 ih2 v1redux' v2redux' with ih1
        ... | funInterpBi {adv} {A} {B} {r} {x'} {y'} e1 e2 bodyBi bodyUn1 bodyUni2 =
          let
            bodySubst = bodyBi ta ta' ih2
            result = bodySubst v1 v2 v1redux' v2redux'
          in result

        inp' : ⟦ (r ·g (Γ1 , g1)) ++g (r ·g (s ·g (Γ2 , g2))) ⟧Γg adv γ1 γ2
        inp' = subst (\h -> ⟦ h ⟧Γg adv γ1 γ2) (trans (cong (_·g_ r) ctxtP) Γg-distrib*+) inp

        subContext1 : ⟦ r ·g ( Γ1 ,  g1) ⟧Γg adv γ1 γ2
        subContext1 = contextSplitLeft inp'

        subContext1bi : ⟦ ( Γ1 ,  g1) ⟧Γg adv γ1 γ2
        subContext1bi = contextElimTimes subContext1

        subContext2alt : ⟦ r ·g (s ·g ( Γ2 , g2 )) ⟧Γg adv γ1 γ2
        subContext2alt = contextSplitRight inp'

        -- Don't need this approach now (alternate but seemed to be not ideal)
        -- subContext2 : ⟦ r ·g ( Γ2 , g2) ⟧Γg adv γ1 γ2
        -- subContext2 = {!   !} -- contextSplitRight {! inp  !}

        subContext2bi : ⟦ ( Γ2 , g2) ⟧Γg adv γ1 γ2
        subContext2bi = contextElimTimes (contextElimTimes (contextSplitRight inp'))

        ih1evidence : [ FunTy A s B ]e (multisubst γ1 t1) × [ FunTy A s B ]e (multisubst γ2 t1)
        ih1evidence with biFundamentalTheoremGhost typ1 adv subContext1bi
        ... | boxInterpBiobs preF .(multisubst' 0 γ1 t1) .(multisubst' 0 γ2 t1) innerF = binaryImpliesUnary {FunTy A s B} {multisubst γ1 t1} {multisubst γ2 t1} {adv} innerF
        ... | boxInterpBiunobs preF .(multisubst' 0 γ1 t1) .(multisubst' 0 γ2 t1) innerF = innerF

        ih2evidence : [ A ]e (multisubst γ1 t2) × [ A ]e (multisubst γ2 t2)
        ih2evidence with biFundamentalTheoremGhost typ2 adv subContext2bi
        ... | boxInterpBiobs preA .(multisubst' 0 γ1 t2) .(multisubst' 0 γ2 t2) innerA = binaryImpliesUnary {A} {multisubst γ1 t2} {multisubst γ2 t2} {adv} innerA
        ... | boxInterpBiunobs preA .(multisubst' 0 γ1 t2) .(multisubst' 0 γ2 t2) innerA = innerA



    intermediateSub {{R}} {{R'}} {Γ = Γ} {ghost} {r} {adv} {γ1} {γ2} {Abs .(Γlength Γ1 + 1) t} {FunTy A s B}
         (abs {_} {_} {Γbody  , gbody} {Γ1} {Γ2} {_} {.s} {g} {.A} {.B} {.t} pos typ {pos2}) pre inp e1 e2 =
     let
     {-
      Goal:

      Need to build a [[ FunTy A s B ]]e witness
      from [ FunTy A s B ]e ... witnesses
      which means I need to build something like ([[ Box s A ]] -> [[ B ]]) function


      Reminders:
       pos : (Γbody , gbody) ≡ (Ext (Γ1 ,, Γ2) (Grad A s) , g)
       pos2 : (Γ , ghost) ≡ ((Γ1 ,, Γ2) , g)
     -}
        ihcontext' = subst (\h -> {!   !}) {!   !} ihcontext
        ih = intermediateSub typ pre {!!} {!!} {!!}
     in goal
     where
      ihcontext : {t t' : Term} {γ1 γ2 : List Term}
               -> ⟦ Box r A ⟧e adv (Promote t) (Promote t')
               -> ⟦ r ·g ((Γ1 ,, Γ2) , ghost) ⟧Γg adv γ1 γ2 -> ⟦ (r · ((Ext Γ1 (Grad A r)) ,, Γ2) , r *R ghost) ⟧Γg adv (t ∷ γ1) (t' ∷ γ2)
      ihcontext {t} {t'} {γ1} {γ2} inp ctxt rewrite multConcatDistr {r = r} {Γ1} {Γ2} with ctxt
      ... | visible pre' inner   rewrite idem* R' {r} = visible (timesLeft pre) (inp , inner)
      ... | invisible pre' inner = ⊥-elim (pre' (timesLeft pre))
      

      ihcontextAlt : {t t' : Term} {γ1 γ2 : List Term}
               -> ⟦ Box s A ⟧e adv (Promote t) (Promote t')
               -> ⟦ ((Γ1 ,, Γ2) , ghost) ⟧Γg adv γ1 γ2 -> ⟦ (((Ext Γ1 (Grad A s)) ,, Γ2) , ghost) ⟧Γg adv (t ∷ γ1) (t' ∷ γ2)
      ihcontextAlt {t} {t'} {γ1} {γ2} inp ctxt with ctxt
      ... | visible pre' inner   = visible pre' (inp , inner)
      ... | invisible pre' inner = {!   !} -- ⊥-elim (pre' (timesLeft pre))

        -- visible pre' {! ?  !}  -- rewrite multConcatDistr {r = r} {Γ1} {Γ2}
      -- ihcontext {t} {t'} {γ1} {γ2} inp (invisible pre' contextInterp) = invisible pre' ({!   !} , {!   !})

      goalBiInnner : ⟦ (Γ1 ,, Γ2) , ghost ⟧Γg adv γ1 γ2
                  -> (v3 v4 : Term)
                  -> ⟦ Box s A ⟧e adv (Promote v3) (Promote v4)
                  -> ⟦ B ⟧e adv (syntacticSubst v3 (Γlength Γ1 + 1) (multisubst' zero γ1 t)) (syntacticSubst v4 (Γlength Γ1 + 1) (multisubst' zero γ2 t))
      goalBiInnner outer v3 v4 arg v1' v2' v1redux' v2redux' =
        let
           ihcontext' = (ihcontextAlt {v3} {v4} {γ1} {γ2} arg outer)
           ih = intermediateSub typ pre {!!} {!!} {!!}
        in ih v1' v2' {!   !} {!   !} 

      goal : ⟦ FunTy A s B ⟧e adv (multisubst γ1 (Abs (Γlength Γ1 + 1) t)) (multisubst γ2 (Abs (Γlength Γ1 + 1) t))
      goal v1 v2 v1redux v2redux rewrite
          trans (sym v1redux) (cong multiRedux (substPresAbs {0} {γ1} {Γlength Γ1 + 1} {t}))
        | trans (sym v2redux) (cong multiRedux (substPresAbs {0} {γ2} {Γlength Γ1 + 1} {t})) =
           funInterpBi (multisubst' zero γ1 t) (multisubst' zero γ2 t) (goalBiInnner {!   !}) {!   !} {!   !}


    intermediateSub {Γ = Γ} {ghost} {r} {adv} {γ1} {γ2} {.(Promote _)} {.(Box _ _)} (pr typ) pre inp e1 e2 = {!!}
    intermediateSub {Γ = .(Semiring.0R _ · _)} {.(Semiring.1R _)} {r} {adv} {γ1} {γ2} {.unit} {.Unit} unitConstr pre inp e1 e2 = {!!}
    intermediateSub {Γ = .(Semiring.0R _ · _)} {.(Semiring.1R _)} {r} {adv} {γ1} {γ2} {.vtrue} {.BoolTy} trueConstr pre inp e1 e2 = {!!}
    intermediateSub {Γ = .(Semiring.0R _ · _)} {.(Semiring.1R _)} {r} {adv} {γ1} {γ2} {.vfalse} {.BoolTy} falseConstr pre inp e1 e2 = {!!}
    intermediateSub {Γ = Γ} {ghost} {r} {adv} {γ1} {γ2} {.(If _ _ _)} {A} (if typ typ₁ typ₂) pre inp e1 e2 = {!!}

    intermediate : {{R : Semiring}} {{R' : InformationFlowSemiring R}} {sz : ℕ}
                {Γ : Context sz}
                {ghost r adv : grade}
                {γ1 γ2 : List Term}
                {τ : Type}
                {e : Term}
                -> (Γ , ghost) ⊢ e ∶ τ
                -> ⟦ r ·g ( Γ , ghost) ⟧Γg adv γ1 γ2
                -> (r ≤ adv)
                -> ⟦ Box ghost τ ⟧v adv (Promote (multisubst γ1 e)) (Promote (multisubst γ2 e))
                -> ¬ (ghost ≤ adv)
                -> ⟦ Box (ghost *R r) τ ⟧v adv (Promote (multisubst γ1 e)) (Promote (multisubst γ2 e))
    intermediate {{R}} {{R'}} {sz} {Γ} {ghost} {r} {adv} {γ1} {γ2} {τ} {e} _ inp pre1 inner pre2
     with (ghost *R r) ≤d adv
    {-
      But what if s = Public, g = Private, adv = Public
      then we have s ≤ adv (Public ≤ Public) yes
                 ¬ (ghost ≤ adv) meaning ¬ (Private ≤ Public) yes
                 (ghost *R s) = Public * Private = Public
            therefore (ghost *R s) ≤ Public is Public ≤ Public which is true.
     therefore adversary cannot see inside Box ghost τ but should be able to see inside Box (ghost *R s).
    -}
    intermediate {{R}} {{R'}} {sz} {Γ} {ghost} {r} {adv} {γ1} {γ2} {τ} {e} _ inp pre1 inner pre2 | yes p with inner

    intermediate ⦃ R ⦄ {{R'}} {sz} {Γ} {ghost} {r} {adv} {γ1} {γ2} {τ} {e} _ inp pre1 inner pre2
      | yes p | boxInterpBiobs x .(multisubst' 0 γ1 e) .(multisubst' 0 γ2 e) inner' =
        boxInterpBiobs p (multisubst' zero γ1 e) (multisubst' zero γ2 e) inner'

    intermediate ⦃ R ⦄ {{R'}} {sz} {Γ} {ghost} {r} {adv} {γ1} {γ2} {τ} {e} typ inp pre1 inner pre2
      | yes p | boxInterpBiunobs x .(multisubst' 0 γ1 e) .(multisubst' 0 γ2 e) inner' =
        boxInterpBiobs p (multisubst' zero γ1 e) (multisubst' zero γ2 e)
           (intermediateSub {sz} {Γ} {ghost} {r} {adv} typ pre1 inp (proj₁ inner') (proj₂ inner'))

    intermediate {{R}} {{R'}} {sz} {Γ} {ghost} {r} {adv} {γ1} {γ2} {τ} {e} typ inp pre1 inner pre2 | no ¬p with inner
    ... | boxInterpBiobs pre3 .(multisubst' 0 γ1 e) .(multisubst' 0 γ2 e) _ = ⊥-elim (pre2 pre3)
    ... | boxInterpBiunobs pre3 .(multisubst' 0 γ1 e) .(multisubst' 0 γ2 e) inner' =
      boxInterpBiunobs ¬p (multisubst' zero γ1 e) (multisubst' zero γ2 e) inner'


    biFundamentalTheoremGhost : {{R : Semiring}} {{R'' : InformationFlowSemiring R}} {sz : ℕ}
              {Γ : Context sz} {ghost : grade} {e : Term} {τ : Type}

            -> (Γ , ghost) ⊢ e ∶ τ
            -> {γ1 : List Term} {γ2 : List Term}
            -> (adv : grade)
            -> ⟦ (Γ , ghost) ⟧Γg adv γ1 γ2
            -> ⟦ Box ghost τ ⟧v adv (Promote (multisubst γ1 e)) (Promote (multisubst γ2 e))

            -- another idea is `Box 1 τ` here

    biFundamentalTheoremGhost {_} {Γ} {ghost} {.(Var (Γlength Γ1))} {τ} (var {_} {_} {.τ} {(.Γ , .ghost)} {Γ1} {Γ2} pos) {γ1} {γ2} adv contextInterp
     rewrite injPair1 pos | sym (injPair2 pos) with Γ1 | γ1 | γ2 | contextInterp
    -- var at head of context (key idea, without out loss of generality as position in context is irrelevant
    -- to rest of the proof)
    ... | Empty | a1 ∷ γ1' | a2 ∷ γ2' | visible eq (argInterp , restInterp) = conc

      where
        conc : ⟦ Box ghost τ ⟧v adv (Promote (multisubst (a1 ∷ γ1') (Var 0))) (Promote (multisubst (a2 ∷ γ2') (Var 0)))
        conc with argInterp (Promote a1) (Promote a2) refl refl
        -- goal : ghost ≤ adv
        -- eq   : 1 ≤ adv
        ... | boxInterpBiobs   eq .a1 .a2 inner
           rewrite injPair2 pos | isSimultaneous'' {a1} {γ1'} | isSimultaneous'' {a2} {γ2'} =
              boxInterpBiobs eq a1 a2 inner

        ... | boxInterpBiunobs neq .a1 .a2 inner
           rewrite injPair2 pos | isSimultaneous'' {a1} {γ1'} | isSimultaneous'' {a2} {γ2'} =
              ⊥-elim (neq eq)

    ... | Empty | a1 ∷ γ1' | a2 ∷ γ2' | invisible neq ((argInterp1 , restInterp1) , (argInterp2 , restInterp2)) = conc
      where
        conc : ⟦ Box ghost τ ⟧v adv (Promote (multisubst (a1 ∷ γ1') (Var 0))) (Promote (multisubst (a2 ∷ γ2') (Var 0)))
        conc rewrite injPair2 pos | isSimultaneous'' {a1} {γ1'} | isSimultaneous'' {a2} {γ2'} =
          boxInterpBiunobs neq a1 a2 (extractUn argInterp1 , extractUn argInterp2)

    -- var generalisation here
    ... | _ | _ | _ | _ = {!!}

    biFundamentalTheoremGhost {sz} {Γ'} {ghost} {Promote t} {Box r A} (pr {sz} {Γ , ghost'} {Γ' , .ghost} {.r} typ {prf}) {γ1} {γ2} adv contextInterpG rewrite prf
      with contextInterpG
    {-
      G, ghost g' |- t : A
    ------------------------------
      G, ghost g |- [t] : Box r A

     where g = r * g'

     model is then
       Box g ⟦ G ⟧ -> Box g (Box r ⟦ A ⟧)
    -}
    biFundamentalTheoremGhost {{R}} {{R'}} {sz} {Γ'} {ghost} {Promote t} {Box r A} (pr {sz} {Γ , ghost'} {Γ' , .ghost} {.r} typ {prf}) {γ1} {γ2} adv contextInterpG | visible eq0 contextInterp with r ≤d adv
    ... | yes eq rewrite sym (injPair2 prf) | idem* R' {r} =
     --  let
       {-
        -- Last weeks' attempt (06/09/2021)
        ih = biFundamentalTheoremGhost {sz} {Γ} {ghost'} {t} {A} typ {γ1} {γ2} adv {!!}
        ih0 = subst (\h -> ⟦ Box ghost' A ⟧v adv h (Promote (multisubst γ2 t)))
                 (sym (substPresProm {zero} {γ1} {t})) ih
        ih1 = subst (\h -> ⟦ Box ghost' A ⟧v adv (multisubst γ1 (Promote t)) h)
                 (sym (substPresProm {zero} {γ2} {t})) ih0
                 -- but we don't have ¬ (ghost' ≤ adv) here?
        az = intermediate {sz} {Γ} {ghost'} {r} {adv} {γ1} {γ2} {A} {Promote t} contextInterp eq {!ih!} {!!}
        az2 = congidm {multisubst' zero γ1 (Promote t)} {multisubst' zero γ2 (Promote t)} {!!}
      -}

        -- Today's attempt (06/09/2021)
    --    boxInner = \v1 v2 v1redux v2redux -> boxInterpBiobs {!!} {!!} {!!} {!!}
    --    boxInner' = subst (\h -> ⟦ Box r A ⟧e adv h (Promote (multisubst γ2 t)))
    --             (sym (substPresProm {zero} {γ1} {t})) {!!}
    --    boxInner'' = subst (\h -> ⟦ Box r A ⟧e adv (multisubst γ1 (Promote t)) h)
    --             (sym (substPresProm {zero} {γ2} {t})) boxInner'
      -- in
        -- looks like eq0 and eq0 give us enough to build the two levels of box
        -- if only we had that we can observe (in the binary relation)
        main -- boxInterpBiobs eq0 {!!} {!!} boxInner


    -- Previous implementation:
    -- main
    {-
      We now know that
      eq0 : g ≤ adv
      eq : r ≤ adv
      Therefore the adversary can observer under the box(es) down to the value of t
    -}
      where
        -- related to attempt on the 06/09/2021
       {- boxInner : ⟦ Box r A ⟧e adv (multisubst' 0 γ1 (Promote t)) (multisubst' 0 γ2 (Promote t))
        boxInner v1 v2 v1redux v2redux
          rewrite trans (sym v1redux) (cong multiRedux (substPresProm {0} {γ1} {t}))
                | trans (sym v2redux) (cong multiRedux (substPresProm {0} {γ2} {t})) =
          boxInterpBiobs eq (multisubst' zero γ1 t) (multisubst' zero γ2 t)
            (intermediateSub {!!} {!!} {!!})
       -}

        congidm : {t1 t2 : Term}
                -> ⟦ Box (ghost' *R r) A ⟧v adv (Promote t1) (Promote t2)
                -> ⟦ Box (r *R ghost') (Box r A) ⟧v adv (Promote (Promote t1)) (Promote (Promote t2))
        congidm x = {!x!}

        convertVal : {s : grade} {v1 : Term} {v2 : Term} {A : Type} -> ⟦ Box (r *R s) A ⟧v adv (Promote v1) (Promote v2) -> ⟦ Box s A ⟧v adv (Promote v1) (Promote v2)
        convertVal {s} {v1} {v2} {A} (boxInterpBiobs prop .v1 .v2 interp) with s ≤d adv
        ... | yes eq = boxInterpBiobs eq v1 v2 interp
        ... | no eq  = boxInterpBiunobs eq v1 v2 (binaryImpliesUnary {A} {v1} {v2} interp)

        convertVal {s} {v1} {v2} {A} (boxInterpBiunobs x .v1 .v2 interp) = boxInterpBiunobs (propInvTimesMonoAsym x eq) v1 v2 interp

        convertExp : {s : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r *R s) A ⟧e adv (Promote v1) (Promote v2) -> ⟦ Box s A ⟧e adv (Promote v1) (Promote v2)
        convertExp {s} {v1} {v2} {A} arg1 v1' v2' v1redux' v2redux' rewrite trans (sym v1redux') (reduxProm {v1}) | trans (sym v2redux') (reduxProm {v2}) =
           convertVal  {s} {v1} {v2} {A} (arg1 (Promote v1) (Promote v2) refl refl)

        underBox : {sz : ℕ} {γ1 γ2 : List Term} {Γ : Context sz} -> ⟦ r · Γ ⟧Γ adv γ1 γ2 -> ⟦ Γ ⟧Γ adv γ1 γ2
        underBox {_} {[]} {[]} {Empty}   g = tt
        underBox {suc n} {v1 ∷ γ1} {v2 ∷ γ2} {Ext Γ (Grad A s)} (ass , g) = convertExp {s} {v1} {v2} {A} ass , underBox {n} {γ1} {γ2} {Γ} g
        underBox {_} {[]} {[]} {Ext Γ (Grad A r₁)} ()
        underBox {_} {[]} {x ∷ γ5} {Ext Γ (Grad A r₁)} ()
        underBox {_} {x ∷ γ4} {[]} {Ext Γ (Grad A r₁)} ()

        thm : {v : Term} {γ : List Term} -> multiRedux (multisubst γ (Promote t)) ≡ v -> Promote (multisubst γ t) ≡ v
        thm {v} {γ} redux =
           let qr = cong multiRedux (substPresProm {0} {γ} {t})
               qr' = trans qr (valuesDontReduce {Promote (multisubst γ t)} (promoteValue (multisubst γ t)))
           in sym (trans (sym redux) qr')

        binaryToUnaryVal : {s : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r *R s) A ⟧v adv (Promote v1) (Promote v2) -> ([ Box s A ]v (Promote v1)) × ([ Box s A ]v (Promote v2))
        binaryToUnaryVal {s} {v1} {v2} {A} (boxInterpBiobs eq' .v1 .v2 ainterp) =
          let (a , b) = binaryImpliesUnary {A} {v1} {v2} {adv} ainterp in (boxInterpV v1 a , boxInterpV v2 b)

        binaryToUnaryVal {s} {v1} {v2} {A} (boxInterpBiunobs eq .v1 .v2 (left , right)) = (boxInterpV v1 left) , (boxInterpV v2 right)


        binaryToUnaryExp : {s : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r *R s) A ⟧e adv (Promote v1) (Promote v2) -> ([ Box s A ]e (Promote v1)) × ([ Box s A ]e (Promote v2))
        binaryToUnaryExp {s} {v1} {v2} {A} arg1 = (left , right)
          where
            left : [ Box s A ]e (Promote v1)
            left v0 redux rewrite trans (sym redux) (reduxProm {v1}) with binaryToUnaryVal {s} {v1} {v2} {A} (arg1 (Promote v1) ((Promote v2)) refl refl)
            ... | (left' , right') = left'

            right : [ Box s A ]e (Promote v2)
            right v0 redux rewrite trans (sym redux) (reduxProm {v2}) with binaryToUnaryVal {s} {v1} {v2} {A} (arg1 (Promote v1) ((Promote v2)) refl refl)
            ... | (left' , right') = right'

        underBox2 : {sz : ℕ} {γ1 γ2 : List Term} {Γ : Context sz} -> ⟦ r · Γ ⟧Γ adv γ1 γ2 -> [ Γ ]Γ γ1 × [ Γ ]Γ γ2
        underBox2 {_} {_} {_} {Empty} g = (tt , tt)
        underBox2 {_} {[]} {[]} {Ext Γ (Grad A r)} ()
        underBox2 {_} {[]} {x ∷ γ2} {Ext Γ (Grad A r)} ()
        underBox2 {_} {x ∷ γ1} {[]} {Ext Γ (Grad A r)} ()
        underBox2 {suc sz} {v1 ∷ γ1} {v2 ∷ γ2} {Ext Γ (Grad A r')} (arg , g) =
         let
          (left , right) = underBox2 {sz} {γ1} {γ2} {Γ} g
          (l , r) = binaryToUnaryExp arg
         in
           (l , left) , (r , right)



        main : ⟦ Box ghost (Box r A) ⟧v adv (Promote (multisubst' 0 γ1 (Promote t))) (Promote (multisubst' 0 γ2 (Promote t)))
        main rewrite injPair1 prf with ghost' ≤d adv
        ... | yes geq' = boxInterpBiobs eq0 (multisubst γ1 (Promote t))  (multisubst γ2 (Promote t)) conclusion
          where
           conclusion : ⟦ Box r A ⟧e adv (multisubst' 0 γ1 (Promote t)) (multisubst' 0 γ2 (Promote t))
           conclusion v1 v2 v1redux v2redux rewrite sym (injPair2 prf) | sym (reduxAndSubstCombinedProm {v1} {t} {γ1} v1redux)         | sym (reduxAndSubstCombinedProm {v2} {t} {γ2} v2redux) =
             let ih = biFundamentalTheoremGhost {sz} {Γ} {ghost'} {t} {A} typ {γ1} {γ2} adv (visible geq' (underBox {sz} {γ1} {γ2} contextInterp))
             in boxInterpBiobs eq (multisubst' zero γ1 t) (multisubst' zero γ2 t) (unpackObs geq' ih)


        ... | no geq' rewrite sym (injPair2 prf) =
          let
            ih = biFundamentalTheoremGhost {sz} {Γ} {ghost'} {t} {A} typ {γ1} {γ2} adv (invisible geq' (underBox2 contextInterp))
            ev = subst (\h -> h ≤ adv) (injPair2 prf) eq0
            intermedio = intermediate typ (visible ev contextInterp) eq ih geq'
            intermedio' = subst (\h -> ⟦ Box ((R Semiring.*R ghost') r) A ⟧v adv h (Promote (multisubst γ2 t)))
                           (sym (substPresProm {zero} {γ1} {t})) intermedio
            intermedio'' = subst (\h -> ⟦ Box ((R Semiring.*R ghost') r) A ⟧v adv (multisubst γ1 (Promote t)) h)
                           (sym (substPresProm {zero} {γ2} {t})) intermedio'

            next = congidm intermedio
            next' = subst (\h -> ⟦ Box ((R Semiring.*R r) ghost') (Box r A) ⟧v adv
                                   (Promote h)
                                   (Promote (Promote (multisubst γ2 t)))) (sym (substPresProm {zero} {γ1} {t})) next
            next'' = subst (\h -> ⟦ Box ((R Semiring.*R r) ghost') (Box r A) ⟧v adv
                                   (Promote (multisubst γ1 (Promote t)))
                                   (Promote h)) (sym (substPresProm {zero} {γ2} {t})) next'

          in subst
               (λ h →
                  ⟦ Box h (Box r A) ⟧v adv (Promote (multisubst' 0 γ1 (Promote t)))
                  (Promote (multisubst' 0 γ2 (Promote t))))
               (sym (injPair2 prf)) next''



    {-
            conclusion : ⟦ Box r A ⟧e adv (multisubst' 0 γ1 (Promote t)) (multisubst' 0 γ2 (Promote t))
            conclusion v1 v2 v1redux v2redux rewrite injPair1 prf | sym (injPair2 prf) |  sym (reduxAndSubstCombinedProm {v1} {t} {γ1} v1redux) |  sym (reduxAndSubstCombinedProm {v2} {t} {γ2} v2redux) {- =
              let ih = biFundamentalTheoremGhost {sz} {Γ} {ghost'} {t} {A} typ {γ1} {γ2} adv (visible {!!} (underBox {sz} {γ1} {γ2} contextInterp))
              in boxInterpBiobs eq (multisubst' zero γ1 t) (multisubst' zero γ2 t) {!!} -}

              with ghost' ≤d adv
            ... | yes geq' =
               let ih = biFundamentalTheoremGhost {sz} {Γ} {ghost'} {t} {A} typ {γ1} {γ2} adv (visible geq' (underBox {sz} {γ1} {γ2} contextInterp))
               in boxInterpBiobs eq (multisubst' zero γ1 t) (multisubst' zero γ2 t) (unpackObs geq' ih)

            ... | no geq' rewrite sym (injPair2 prf) = {!!}
    -}



    {-

    -- (trans (monotone* {!!} {!!}) (idem* {adv}))
               -- eq : r ≤ adv
               --   i.e., the adversary can see inside the box (if ghosts are ignored)
               -- geq : r * ghost' ≤ adv
               --   i.e., the adversary can see inside the outer ghost box
               --  BUT
               -- geq' : ¬ (ghost' ≤ adv)
               --   i.e., the adversary cannot see inside the ghosted box

                let ih = biFundamentalTheoremGhost {sz} {Γ} {ghost'} {t} {A} typ {γ1} {γ2} adv (invisible geq' (underBox2 {sz} {γ1} {γ2} contextInterp))
                    --ih0 = unpackObs {!!} ih
                    ih' = (unpackUnobs geq' ih)
                    in boxInterpBiobs eq (multisubst' zero γ1 t) (multisubst' zero γ2 t) {!!}
                    --in boxInterpBiunobs {!!} (multisubst' zero γ1 t) (multisubst' zero γ2 t) ih' -- boxInterpBiobs {!!} (multisubst' zero γ1 t) (multisubst' zero γ2 t) ? (unpackUnobs geq' ih)

    -}

    ... | no ¬req = main
      where
        binaryToUnaryVal : {s : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r *R s) A ⟧v adv (Promote v1) (Promote v2) -> ([ Box s A ]v (Promote v1)) × ([ Box s A ]v (Promote v2))
        binaryToUnaryVal {s} {v1} {v2} {A} (boxInterpBiobs eq' .v1 .v2 ainterp) =
          let (a , b) = binaryImpliesUnary {A} {v1} {v2} {adv} ainterp in (boxInterpV v1 a , boxInterpV v2 b)

        binaryToUnaryVal {s} {v1} {v2} {A} (boxInterpBiunobs eq .v1 .v2 (left , right)) = (boxInterpV v1 left) , (boxInterpV v2 right)

        binaryToUnaryExp : {s : grade} {v1 v2 : Term} {A : Type} -> ⟦ Box (r *R s) A ⟧e adv (Promote v1) (Promote v2) -> ([ Box s A ]e (Promote v1)) × ([ Box s A ]e (Promote v2))
        binaryToUnaryExp {s} {v1} {v2} {A} arg1 = (left , right)
          where
            left : [ Box s A ]e (Promote v1)
            left v0 redux rewrite trans (sym redux) (reduxProm {v1}) with binaryToUnaryVal {s} {v1} {v2} {A} (arg1 (Promote v1) ((Promote v2)) refl refl)
            ... | (left' , right') = left'

            right : [ Box s A ]e (Promote v2)
            right v0 redux rewrite trans (sym redux) (reduxProm {v2}) with binaryToUnaryVal {s} {v1} {v2} {A} (arg1 (Promote v1) ((Promote v2)) refl refl)
            ... | (left' , right') = right'

        underBox : {sz : ℕ} {γ1 γ2 : List Term} {Γ : Context sz} -> ⟦ r · Γ ⟧Γ adv γ1 γ2 -> [ Γ ]Γ γ1 × [ Γ ]Γ γ2
        underBox {_} {_} {_} {Empty} g = (tt , tt)
        underBox {_} {[]} {[]} {Ext Γ (Grad A r)} ()
        underBox {_} {[]} {x ∷ γ2} {Ext Γ (Grad A r)} ()
        underBox {_} {x ∷ γ1} {[]} {Ext Γ (Grad A r)} ()
        underBox {suc sz} {v1 ∷ γ1} {v2 ∷ γ2} {Ext Γ (Grad A r')} (arg , g) =
         let
          (left , right) = underBox {sz} {γ1} {γ2} {Γ} g
          (l , r) = binaryToUnaryExp arg
         in
           (l , left) , (r , right)

        main : ⟦ Box ghost (Box r A) ⟧v adv (Promote (multisubst' 0 γ1 (Promote t))) (Promote (multisubst' 0 γ2 (Promote t)))
        main with ghost ≤d adv
        ... | yes geq = boxInterpBiobs geq (multisubst γ1 (Promote t))  (multisubst γ2 (Promote t)) conclusion
          where

            conclusion : ⟦ Box r A ⟧e adv (multisubst' 0 γ1 (Promote t)) (multisubst' 0 γ2 (Promote t))
            conclusion v1 v2 v1redux v2redux rewrite injPair1 prf =

              let
                (uinterp1 , uinterp2) = underBox {sz} {γ1} {γ2} {Γ} contextInterp
                ih1 = utheoremG {sz} {γ1} {Γ} {ghost'} {t} {A} typ uinterp1
                ih2 = utheoremG {sz} {γ2} {Γ} {ghost'} {t} {A} typ uinterp2
                out = boxInterpBiunobs ¬req (multisubst γ1 t) (multisubst γ2 t) (ih1 , ih2)
              in subst₂ (\h1 h2 -> ⟦ Box r A ⟧v adv h1 h2)
                (reduxAndSubstCombinedProm {v1} {t} {γ1} v1redux)
                (reduxAndSubstCombinedProm {v2} {t} {γ2} v2redux) out

        ... | no ¬geq = boxInterpBiunobs ¬geq (multisubst γ1 (Promote t)) (multisubst γ2 (Promote t)) (conclusion1 , conclusion2)
          where
            conclusion1 : [ Box r A ]e (multisubst' 0 γ1 (Promote t))
            conclusion1 v1 v1redux rewrite injPair1 prf | sym (reduxAndSubstCombinedProm {v1} {t} {γ1} v1redux) =
              let
                (uinterp1 , uinterp2) = underBox {sz} {γ1} {γ2} {Γ} contextInterp
                ih1 = utheoremG {sz} {γ1} {Γ} {ghost'} {t} {A} typ uinterp1
              in boxInterpV (multisubst γ1 t) ih1

            conclusion2 : [ Box r A ]e (multisubst' 0 γ2 (Promote t))
            conclusion2 v2 v2redux rewrite injPair1 prf | sym (reduxAndSubstCombinedProm {v2} {t} {γ2} v2redux) =
              let
                (uinterp1 , uinterp2) = underBox {sz} {γ1} {γ2} {Γ} contextInterp
                ih2 = utheoremG {sz} {γ2} {Γ} {ghost'} {t} {A} typ uinterp2
              in boxInterpV (multisubst γ2 t) ih2


    biFundamentalTheoremGhost {sz} {Γ'} {ghost} {Promote t} {Box r A} (pr {sz} {Γ , ghost'} {Γ' , .ghost} {.r} typ {prf}) {γ1} {γ2} adv contextInterpG | invisible neq (contextInterp1 , contextInterp2) with ghost ≤d adv
    ... | yes geq rewrite injPair2 prf = ⊥-elim (neq geq)


    ... | no ¬geq = boxInterpBiunobs ¬geq (multisubst' zero γ1 (Promote t)) (multisubst' zero γ2 (Promote t)) ((conclusion1 , conclusion2))
       where
            convert : {s : grade} {v : Term} {A : Type} -> [ Box (r *R s) A ]e (Promote v) -> [ Box s A ]e (Promote v)
            convert {s} {v} {A} pre v0 v0redux with pre v0 v0redux
            ... | boxInterpV e inner = boxInterpV e inner

            underBox : {sz : ℕ} {γ : List Term} {Γ : Context sz} -> [ r · Γ ]Γ γ -> [ Γ ]Γ γ
            underBox {0} {_} {Empty} g = tt
            underBox {suc sz} {v ∷ γ} {Ext Γ (Grad A s)} (ass , g) = convert ass , underBox {sz} {γ} {Γ} g

            conclusion1 : [ Box r A ]e (multisubst' 0 γ1 (Promote t))
            conclusion1 v1 v1redux rewrite injPair1 prf =
              let ih = utheoremG typ (underBox contextInterp1)
              in subst (\h -> [ Box r A ]v h) (reduxAndSubstCombinedProm {v1} {t} {γ1} v1redux) (boxInterpV (multisubst γ1 t) ih)

            conclusion2 : [ Box r A ]e (multisubst' 0 γ2 (Promote t))
            conclusion2 v2 v2redux rewrite injPair1 prf =
              let ih = utheoremG typ (underBox contextInterp2)
              in subst (\h -> [ Box r A ]v h) (reduxAndSubstCombinedProm {v2} {t} {γ2} v2redux) (boxInterpV (multisubst γ2 t) ih)

    -- reduxAndSubstCombinedProm

    biFundamentalTheoremGhost {sz} {Γ} {ghost} {t} {A} typ {γ1} {γ2} adv contextInterp = {!!}


{-
nonInterferenceGhostAlt :
   {{R : Semiring}} {{R' : NonInterferingSemiring R}} {{R'' : InformationFlowSemiring R}}
   {e : Term} {r s : grade} {pre : r ≤ s} {nonEq : r ≢ s}
        -> (Ext Empty (Grad BoolTy s) , r) ⊢ e ∶ Box r BoolTy

        -> (v1 v2 : Term)
        -> (Empty , default) ⊢ v1 ∶ BoolTy
        -> (Empty , default) ⊢ v2 ∶ BoolTy
        -> Value v1
        -> Value v2

        -> multiRedux (syntacticSubst v1 0 e) == multiRedux (syntacticSubst v2 0 e)

nonInterferenceGhostAlt {{R}} {{R'}} {{R''}} {e} {r} {s} {pre} {nonEq} typing v1 v2 v1typing v2typing isvalv1 isvalv2 =
 {!!}
-}
