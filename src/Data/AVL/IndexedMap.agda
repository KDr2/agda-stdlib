------------------------------------------------------------------------
-- The Agda standard library
--
-- This module is DEPRECATED.
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

open import Data.Product.Base using (∃)
open import Relation.Binary.Core using (Rel)
open import Relation.Binary.Structures using (IsStrictTotalOrder)
open import Relation.Binary.PropositionalEquality.Core using (_≡_; cong; subst)
import Data.Tree.AVL.Value using (Value)

module Data.AVL.IndexedMap
  {i k v ℓ}
  {Index : Set i} {Key : Index → Set k}  (Value : Index → Set v)
  {_<_ : Rel (∃ Key) ℓ}
  (isStrictTotalOrder : IsStrictTotalOrder _≡_ _<_)
  where

{-# WARNING_ON_IMPORT
"Data.AVL.IndexedMap was deprecated in v1.4.
Use Data.Tree.AVL.IndexedMap instead."
#-}

open import Data.Tree.AVL.IndexedMap Value isStrictTotalOrder public
