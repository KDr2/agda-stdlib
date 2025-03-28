------------------------------------------------------------------------
-- The Agda standard library
--
-- Functors
------------------------------------------------------------------------

-- Note that currently the functor laws are not included here.

{-# OPTIONS --cubical-compatible --safe #-}

module Effect.Functor where

open import Data.Unit.Polymorphic.Base using (⊤)
open import Function.Base using (const; flip)
open import Level using (Level; suc; _⊔_)
open import Relation.Binary.PropositionalEquality.Core using (_≡_)

private
  variable
    ℓ ℓ′ ℓ″ : Level
    A B X Y : Set ℓ

record RawFunctor (F : Set ℓ → Set ℓ′) : Set (suc ℓ ⊔ ℓ′) where
  infixl 4 _<$>_ _<$_
  infixl 1 _<&>_
  field
    _<$>_ : (A → B) → F A → F B

  _<$_ : A → F B → F A
  x <$ y = const x <$> y

  _<&>_ : F A → (A → B) → F B
  _<&>_ = flip _<$>_

  ignore : F A → F ⊤
  ignore = _ <$_

-- A functor morphism from F₁ to F₂ is an operation op such that
-- op (F₁ f x) ≡ F₂ f (op x)

record Morphism {F₁ : Set ℓ → Set ℓ′} {F₂ : Set ℓ → Set ℓ″}
                (fun₁ : RawFunctor F₁)
                (fun₂ : RawFunctor F₂) : Set (suc ℓ ⊔ ℓ′ ⊔ ℓ″) where
  open RawFunctor
  field
    op     : F₁ X → F₂ X
    op-<$> : (f : X → Y) (x : F₁ X) →
             op (fun₁ ._<$>_ f x) ≡ fun₂ ._<$>_ f (op x)
