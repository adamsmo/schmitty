{-# OPTIONS --guardedness #-}

--------------------------------------------------------------------------------
-- Schmitty the Solver
--
-- Defines the `Theory` instance for core theory, called `coreTheory`.
--------------------------------------------------------------------------------

module SMT.Theories.Core.Base where

open import Data.Bool.Base as Bool using (Bool; false; true)
open import Data.Empty as Empty using (⊥)
open import Data.List.Base as List using (List; _∷_; [])
open import Data.String.Base as String using (String)
open import Data.Unit as Unit using (⊤)
import Reflection as Rfl
open import Relation.Nullary using (Dec; yes; no)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import SMT.Theory
open import Text.Parser.String


-----------
-- Sorts --
-----------

data CoreSort : Set where
  BOOL : CoreSort

private
  variable
    φ : CoreSort
    Φ : Signature φ

_≟-CoreSort_ : (φ φ′ : CoreSort) → Dec (φ ≡ φ′)
BOOL ≟-CoreSort BOOL = yes refl

showCoreSort : CoreSort → String
showCoreSort BOOL = "Bool"

parseCoreSort : ∀[ Parser CoreSort ]
parseCoreSort = BOOL <$ lexeme "Bool"

_ : parseCoreSort parses "Bool"
_ = ! BOOL

_ : parseCoreSort rejects "Int"
_ = _

quoteCoreSort : CoreSort → Rfl.Term
quoteCoreSort BOOL = Rfl.con (quote BOOL) []


------------
-- Values --
------------

data SetRep : Set where
  EMPTY : SetRep
  UNIT  : SetRep

CoreValue : CoreSort → Set
CoreValue BOOL = SetRep

parseSetRep : ∀[ Parser SetRep ]
parseSetRep = EMPTY <$ lexeme "false"
          <|> UNIT  <$ lexeme "true"

parseCoreValue : (φ : CoreSort) → ∀[ Parser (CoreValue φ) ]
parseCoreValue BOOL = parseSetRep

private
  pattern `EMPTY = Rfl.con (quote EMPTY) []
  pattern `UNIT  = Rfl.con (quote UNIT)  []

quoteSetRep : SetRep → Rfl.Term
quoteSetRep EMPTY = `EMPTY
quoteSetRep UNIT  = `UNIT

quoteCoreValue : (φ : CoreSort) → CoreValue φ → Rfl.Term
quoteCoreValue BOOL = quoteSetRep

interpCoreValue : Rfl.Term → Rfl.Term
interpCoreValue `EMPTY = quoteTerm ⊥
interpCoreValue `UNIT  = Rfl.con (quote ⊤) []
interpCoreValue t      = t


--------------
-- Literals --
--------------

data CoreLiteral : CoreSort → Set where

showCoreLiteral : CoreLiteral φ → String
showCoreLiteral ()


-----------------
-- Identifiers --
-----------------

data CoreIdentifier : (Φ : Signature φ) → Set where
  false   : CoreIdentifier (Op₀ BOOL)
  true    : CoreIdentifier (Op₀ BOOL)
  not     : CoreIdentifier (Op₁ BOOL)
  implies : CoreIdentifier (Op₂ BOOL)
  and     : CoreIdentifier (Op₂ BOOL)
  or      : CoreIdentifier (Op₂ BOOL)
  xor     : CoreIdentifier (Op₂ BOOL)

showCoreIdentifier : CoreIdentifier Φ → String
showCoreIdentifier false   = "false"
showCoreIdentifier true    = "true"
showCoreIdentifier not     = "not"
showCoreIdentifier implies = "=>"
showCoreIdentifier and     = "and"
showCoreIdentifier or      = "or"
showCoreIdentifier xor     = "xor"


---------------
-- Instances --
---------------

theory : Theory
Theory.Sort         theory = CoreSort
Theory.BOOL         theory = BOOL
Theory._≟-Sort_     theory = _≟-CoreSort_
Theory.Value        theory = CoreValue
Theory.Literal      theory = CoreLiteral
Theory.Identifier   theory = CoreIdentifier
Theory.quoteSort    theory = quoteCoreSort
Theory.quoteValue   theory = quoteCoreValue
Theory.interpValue  theory = interpCoreValue

instance
  corePrintable : Printable theory
  Printable.showSort       corePrintable = showCoreSort
  Printable.showLiteral    corePrintable = showCoreLiteral
  Printable.showIdentifier corePrintable = showCoreIdentifier

  coreParsable : Parsable theory
  Parsable.parseSort   coreParsable = parseCoreSort
  Parsable.parseValue  coreParsable = parseCoreValue

  coreSolvable : Solvable theory
  coreSolvable = makeSolvable theory
