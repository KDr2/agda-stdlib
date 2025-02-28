------------------------------------------------------------------------
-- The Agda standard library
--
-- Properties of divisibility over monoids
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

open import Algebra.Bundles using (Monoid)

module Algebra.Properties.Monoid.Divisibility
  {a ℓ} (M : Monoid a ℓ) where

open import Data.Product.Base using (_,_)
open import Relation.Binary.Core using (_⇒_)
open import Relation.Binary.Bundles using (Preorder)
open import Relation.Binary.Structures using (IsPreorder; IsEquivalence)
open import Relation.Binary.Definitions using (Reflexive)

open Monoid M

------------------------------------------------------------------------
-- Re-export semigroup divisibility

open import Algebra.Properties.Semigroup.Divisibility semigroup public

------------------------------------------------------------------------
-- Additional properties

infix 4 ε∣_

ε∣_ : ∀ x → ε ∣ x
ε∣ x = x , identityʳ x

∣-refl : Reflexive _∣_
∣-refl {x} = ε , identityˡ x

∣-reflexive : _≈_ ⇒ _∣_
∣-reflexive x≈y = ε , trans (identityˡ _) x≈y

∣-isPreorder : IsPreorder _≈_ _∣_
∣-isPreorder = record
  { isEquivalence = isEquivalence
  ; reflexive     = ∣-reflexive
  ; trans         = ∣-trans
  }

∣-preorder : Preorder a ℓ _
∣-preorder = record
  { isPreorder = ∣-isPreorder
  }

------------------------------------------------------------------------
-- Properties of mutual divisibiity

∥-refl : Reflexive _∥_
∥-refl = ∣-refl , ∣-refl

∥-reflexive : _≈_ ⇒ _∥_
∥-reflexive x≈y = ∣-reflexive x≈y , ∣-reflexive (sym x≈y)

∥-isEquivalence : IsEquivalence _∥_
∥-isEquivalence = record
  { refl  = ∥-refl
  ; sym   = ∥-sym
  ; trans = ∥-trans
  }


------------------------------------------------------------------------
-- DEPRECATED NAMES
------------------------------------------------------------------------
-- Please use the new names as continuing support for the old names is
-- not guaranteed.

-- Version 2.3

∣∣-refl = ∥-refl
{-# WARNING_ON_USAGE ∣∣-refl
"Warning: ∣∣-refl was deprecated in v2.3.
Please use ∥-refl instead. "
#-}

∣∣-reflexive = ∥-reflexive
{-# WARNING_ON_USAGE ∣∣-reflexive
"Warning: ∣∣-reflexive was deprecated in v2.3.
Please use ∥-reflexive instead. "
#-}

∣∣-isEquivalence = ∥-isEquivalence
{-# WARNING_ON_USAGE ∣∣-isEquivalence
"Warning: ∣∣-isEquivalence was deprecated in v2.3.
Please use ∥-isEquivalence instead. "
#-}
