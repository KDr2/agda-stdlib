------------------------------------------------------------------------
-- The Agda standard library
--
-- Indexed universes
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

module Data.Universe.Indexed where

open import Data.Product.Base using (∃; proj₂)
open import Data.Universe using (Universe)
open import Function.Base using (_∘_)
open import Level using (Level; _⊔_; suc)

------------------------------------------------------------------------
-- Definitions

record IndexedUniverse i u e : Set (suc (i ⊔ u ⊔ e)) where
  field
    I  : Set i                 -- Index set.
    U  : I → Set u             -- Codes.
    El : ∀ {i} → U i → Set e   -- Decoding function.

  -- An indexed universe can be turned into an unindexed one.

  unindexed-universe : Universe (i ⊔ u) e
  unindexed-universe = record
    { U  = ∃ λ i → U i
    ; El = El ∘ proj₂
    }
