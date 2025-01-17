{-# OPTIONS --rewriting #-}

module NonInterference where

open import GrCore
open import Data.Unit
open import Data.Empty
open import Relation.Binary.PropositionalEquality
open import Data.Product
open import Data.Bool hiding (_≤_; _≟_)
open import Data.Vec hiding (_++_)
open import Data.Nat hiding (_≤_)
open import Function
open import Data.Maybe
open import Relation.Nullary
open import Data.Sum
open import Data.Fin hiding (_≤_)

open import Semiring

open NonInterferingSemiring {{...}} public

open import OperationalModel
open import RelationalModel
open import UnaryFundamentalTheorem
open import BinaryFundamentalTheorem

-- Value lemma for promotion
promoteValueLemma : {{R : Semiring}} {v : Term 0} {r : grade} {A : Type}

  -> Empty ⊢ v ∶ Box r A
  -> Value v
  -> Σ (Term 0) (\v' -> v ≡ Promote v')

promoteValueLemma typing (promoteValue t) = t , refl

boolBinaryValueInterpEquality : {{R : Semiring}} {r : grade} (v1 v2 : Term s) -> ⟦ BoolTy ⟧v r v1 v2 -> v1 ≡ v2
boolBinaryValueInterpEquality .vtrue .vtrue boolInterpTrueBi = refl
boolBinaryValueInterpEquality .vfalse .vfalse boolInterpFalseBi = refl

boolBinaryExprInterpEquality : {{R : Semiring}} {r : grade} (v1 v2 : Term s)
                              -> ⟦ BoolTy ⟧e r v1 v2
                              -> multiRedux v1 ≡ multiRedux v2
boolBinaryExprInterpEquality t1 t2 prf =
  boolBinaryValueInterpEquality (multiRedux t1) (multiRedux t2) ((prf (multiRedux t1) (multiRedux t2) refl refl))


-- Non-interference
nonInterference :
   {{R : Semiring}} {{R' : NonInterferingSemiring {{R}}}}
   {A : Type} {e : Term 1} {adv s : grade} {pre : adv ≤ s} {nonEq : adv ≢ s}
        -> Ext Empty (Grad A s) ⊢ e ∶ Box adv BoolTy

        -> (v1 v2 : Term 0)
        -> Empty ⊢ v1 ∶ A
        -> Empty ⊢ v2 ∶ A
        -> Value v1
        -> Value v2

        -> multiRedux (syntacticSubst v1 zero e) == multiRedux (syntacticSubst v2 zero e)

nonInterference {{_}} {{_}} {A} {e} {r} {s} {pre} {nonEq} typing v1 v2 v1typing v2typing isvalv1 isvalv2 with
    -- Apply fundamental binary theorem to v1
    biFundamentalTheorem {zero} {Empty} {Promote v1} {Box s A}
                  (pr v1typing {refl}) {[]} {[]} r tt (Promote v1) (Promote v1)
                  (valuesDontReduce {_} {Promote v1} (promoteValue v1))
                  (valuesDontReduce {_} {Promote v1} (promoteValue v1))
    -- Apply fundamental binary theorem to v2
  | biFundamentalTheorem {zero} {Empty} {Promote v2} {Box s A}
                  (pr v2typing {refl})  {[]} {[]} r tt (Promote v2) (Promote v2)
                  (valuesDontReduce {_} {Promote v2} (promoteValue v2))
                  (valuesDontReduce {_} {Promote v2} (promoteValue v2))
... | boxInterpBiobs pre1 .v1 .v1 inner1 | _                                    = ⊥-elim (nonEq (antisymmetry pre pre1))
... | boxInterpBiunobs pre1 .v1 .v1 inner1 | boxInterpBiobs pre2 .v2 .v2 inner2 = ⊥-elim (nonEq (antisymmetry pre pre2))
... | boxInterpBiunobs pre1 .v1 .v1 (valv1 , valv1') | boxInterpBiunobs pre2 .v2 .v2 (valv2 , valv2') rewrite raiseTermℕzero {_} {v1} | raiseTermℕzero {_} {v2} =
 let
   -- Show that substituting v1 and evaluating yields a value
   -- and since it is a graded modal type then this value is necessarily
   -- of the form Promote v1''
   substTy1 = substitution {zero} {zero} {Ext Empty (Grad A s)} {Empty} {Empty} {Empty} {s} typing refl v1typing
   (v1'' , prf1) = promoteValueLemma {_} {r} {BoolTy} (preservation {zero} {Empty} {Box r BoolTy} {syntacticSubst v1 zero e} substTy1) (strongNormalisation substTy1)

   -- ... same as above but for v2 ... leading to result of Promote v2''
   substTy2  = substitution {zero} {zero} {Ext Empty (Grad A s)} {Empty} {Empty} {Empty} {s} typing refl v2typing
   (v2'' , prf2) = promoteValueLemma {_} {r} {BoolTy} (preservation {zero} substTy2) (strongNormalisation substTy2)

   prf1' = subst (\h ->  multiRedux (syntacticSubst h zero e) ≡ Promote v1'') (sym (raiseTermℕzero {_} {v1})) prf1
   prf2' = subst (\h ->  multiRedux (syntacticSubst h zero e) ≡ Promote v2'') (sym (raiseTermℕzero {_} {v2})) prf2

   -- Apply fundamental binary theorem on the result with the values coming from syntacitcally substituting
   -- then evaluating
   res = biFundamentalTheorem {1} {Ext Empty (Grad A s)} {e} {Box r BoolTy} typing {v1 ∷ []} {v2 ∷ []} r
          (inner valv1' valv2' , tt) (Promote v1'') (Promote v2'') prf1' prf2'

   -- Boolean typed (low) values are equal inside the binary interepration
   boolTyEq = boolBinaryExprInterpEquality v1'' v2'' (unpack res)

   -- Plug together the equalities
     -- Promote
   eq = PromoteEq {_} {v1''} {v2''} (Redux {_} {v1''} {v2''} boolTyEq)
   eq2 = transFullBetaEq (embedEq prf1) eq

 in transFullBetaEq eq2 (embedEq (sym prf2))
   where

     inner : [ A ]e v1 -> [ A ]e v2 -> ⟦ Box s A ⟧e r (Promote v1) (Promote v2)
     inner av1 av2 v3 v4 v3redux v4redux
       rewrite trans (sym v3redux) (valuesDontReduce {_} {Promote v1} (promoteValue v1))
             | trans (sym v4redux) (valuesDontReduce {_} {Promote v2} (promoteValue v2)) =
       boxInterpBiunobs pre1 v1 v2 (av1 , av2)

     -- Helper to unpack interpretation type
     unpack : {v1 v2 : Term 0} -> ⟦ Box r BoolTy ⟧v r (Promote v1) (Promote v2) -> ⟦ BoolTy ⟧e r v1 v2
     unpack {v1} {v2} (boxInterpBiobs _ .v1 .v2 innerExprInterp) = innerExprInterp
     unpack {v1} {v2} (boxInterpBiunobs eq .v1 .v2 innerExprInterp) = ⊥-elim (eq (reflexive≤ {r}))
