{-# OPTIONS --allow-exec #-}
{-# OPTIONS --guardedness #-}

module Test_Context_Z3_Ints where

open import Agda.Builtin.FromNat
open import Data.Integer using (ℤ; _+_; _-_)
open import Data.Empty using (⊥)
open import Data.Unit using (tt)
open import Relation.Binary.PropositionalEquality using (_≡_)
open import SMT.Theories.Ints as Ints
open import SMT.Backend.Z3 Ints.theory

import Data.Integer.Literals as Int using (number; negative)

instance _ = tt
         _ = Int.number
         _ = Int.negative

t₁ : (x y : ℤ) → x + y ≡ y + x
t₁ x y = solveZ3

t₂ : (x y z w : ℤ) → x ≡ y → z ≡ w → x + z ≡ y + w
t₂ x y z w x≡y z≡w = solveZ3

postulate
  t₃ : (x y : ℤ) → x ≡ y

-- We can add arbitrary lemmas to the context to help the solver.
t₄ : (x y : ℤ) → y ≡ x
t₄ x y with t₃ x y
...       | _ = solveZ3

-- The above example doesn't work with let, it seems like bindings
-- introduced by let is not added to the context.
-- t₅ : (x y : ℤ) → y ≡ x
-- t₅ x y = let z = t₃ x y
--          in solveZ3

-- Variables may be unused
t₆ : (x y z : ℤ) → x + y ≡ y + x
t₆ = solveZ3

-- Assumptions that are not encodable as SMT formulas are ignored.
t₇ : (A : Set) → A ≡ A → (x : ℤ) → x - x ≡ 0
t₇ = solveZ3
