------------------------------------------------------------------------
-- The Agda standard library
--
-- Instantiating homogeneously indexed bundles at a particular index
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

module Relation.Binary.Indexed.Homogeneous.Construct.At where

open import Level using (Level)
open import Relation.Binary.Bundles using (Setoid; DecSetoid; Preorder)
open import Relation.Binary.Indexed.Homogeneous
  using (IRel; IsIndexedEquivalence; IsIndexedDecEquivalence; IsIndexedPreorder
        ; IndexedSetoid; IndexedDecSetoid; IndexedPreorder)
open import Relation.Binary.Structures
  using (IsEquivalence; IsDecEquivalence; IsPreorder)

private
  variable
    a i ℓ ℓ₁ ℓ₂ : Level
    I : Set i
    Aᵢ : I → Set a

------------------------------------------------------------------------
-- Structures

isEquivalence : ∀ {_≈_ : IRel Aᵢ ℓ} → IsIndexedEquivalence Aᵢ _≈_ →
                (index : I) → IsEquivalence (_≈_ {index})
isEquivalence isEq index = record
  { refl  = reflᵢ
  ; sym   = symᵢ
  ; trans = transᵢ
  } where open IsIndexedEquivalence isEq

isDecEquivalence : ∀ {_≈_ : IRel Aᵢ ℓ} → IsIndexedDecEquivalence Aᵢ _≈_ →
                   (index : I) → IsDecEquivalence (_≈_ {index})
isDecEquivalence isEq index = record
  { isEquivalence = isEquivalence E.isEquivalenceᵢ index
  ; _≟_           = E._≟ᵢ_
  } where module E = IsIndexedDecEquivalence isEq

isPreorder : ∀ {_≈_ : IRel Aᵢ ℓ₁} {_∼_ : IRel Aᵢ ℓ₂} →
             IsIndexedPreorder Aᵢ _≈_ _∼_ →
             (index : I) → IsPreorder (_≈_ {index}) _∼_
isPreorder isPreorder index = record
  { isEquivalence = isEquivalence O.isEquivalenceᵢ index
  ; reflexive     = O.reflexiveᵢ
  ; trans         = O.transᵢ
  } where module O = IsIndexedPreorder isPreorder

------------------------------------------------------------------------
-- Bundles

setoid : IndexedSetoid I a ℓ → I → Setoid a ℓ
setoid S index = record
  { isEquivalence = isEquivalence S.isEquivalenceᵢ index
  } where module S = IndexedSetoid S

decSetoid : IndexedDecSetoid I a ℓ → I → DecSetoid a ℓ
decSetoid S index = record
  { isDecEquivalence = isDecEquivalence DS.isDecEquivalenceᵢ index
  } where module DS = IndexedDecSetoid S

preorder : IndexedPreorder I a ℓ₁ ℓ₂ → I → Preorder a ℓ₁ ℓ₂
preorder O index = record
  { isPreorder = isPreorder O.isPreorderᵢ index
  } where module O = IndexedPreorder O

------------------------------------------------------------------------
-- Some useful shorthand infix notation

infixr -1 _atₛ_

_atₛ_ : ∀ {ℓ} → IndexedSetoid I a ℓ → I → Setoid a ℓ
_atₛ_ = setoid
