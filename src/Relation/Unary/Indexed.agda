------------------------------------------------------------------------
-- The Agda standard library
--
-- Indexed unary relations
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

module Relation.Unary.Indexed  where

open import Data.Product.Base using (∃; _×_)
open import Level using (Level)
open import Relation.Nullary.Negation.Core using (¬_)

IPred : ∀ {i a} {I : Set i} → (I → Set a) → (ℓ : Level) → Set _
IPred A ℓ = ∀ {i} → A i → Set ℓ

module _ {i a} {I : Set i} {A : I → Set a} where

  infix 4 _∈_ _∉_

  _∈_ : ∀ {ℓ} → (∀ i → A i) → IPred A ℓ → Set _
  x ∈ P = ∀ i → P (x i)

  _∉_ : ∀ {ℓ} → (∀ i → A i) → IPred A ℓ → Set _
  t ∉ P = ¬ (t ∈ P)
