------------------------------------------------------------------------
-- The Agda standard library
--
-- The Delay type and some operations
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --sized-types #-}

module Codata.Sized.Delay where

open import Size using (Size; ∞)
open import Codata.Sized.Thunk using (Thunk; force)
open import Codata.Sized.Conat using (Conat; zero; suc; Finite)
open import Data.Empty using (⊥)
open import Data.Nat.Base using (ℕ; suc; zero)
open import Data.Maybe.Base hiding (map ; fromMaybe ; zipWith ; alignWith ; zip ; align)
open import Data.Product.Base hiding (map ; zip)
open import Data.Sum.Base hiding (map)
open import Data.These.Base using (These; this; that; these)
open import Function.Base using (id)
open import Relation.Nullary.Negation.Core using (¬_)

------------------------------------------------------------------------
-- Definition

data Delay {ℓ} (A : Set ℓ) (i : Size) : Set ℓ where
  now   : A → Delay A i
  later : Thunk (Delay A) i → Delay A i

module _ {ℓ} {A : Set ℓ} where

 length : ∀ {i} → Delay A i → Conat i
 length (now _)   = zero
 length (later d) = suc λ where .force → length (d .force)

 never : ∀ {i} → Delay A i
 never = later λ where .force → never

 fromMaybe : Maybe A → Delay A ∞
 fromMaybe = maybe now never

 runFor : ℕ → Delay A ∞ → Maybe A
 runFor zero    d         = nothing
 runFor (suc n) (now a)   = just a
 runFor (suc n) (later d) = runFor n (d .force)

module _ {ℓ ℓ′} {A : Set ℓ} {B : Set ℓ′} where

 map : (A → B) → ∀ {i} → Delay A i → Delay B i
 map f (now a)   = now (f a)
 map f (later d) = later λ where .force → map f (d .force)

 bind : ∀ {i} → Delay A i → (A → Delay B i) → Delay B i
 bind (now a)   f = f a
 bind (later d) f = later λ where .force → bind (d .force) f

 unfold : (A → A ⊎ B) → A → ∀ {i} → Delay B i
 unfold next seed with next seed
 ... | inj₁ seed′ = later λ where .force → unfold next seed′
 ... | inj₂ b     = now b

module _ {a b c} {A : Set a} {B : Set b} {C : Set c} where

 zipWith : (A → B → C) → ∀ {i} → Delay A i → Delay B i → Delay C i
 zipWith f (now a)   d         = map (f a) d
 zipWith f d         (now b)   = map (λ a → f a b) d
 zipWith f (later a) (later b) = later λ where .force → zipWith f (a .force) (b .force)

 alignWith : (These A B → C) → ∀ {i} → Delay A i → Delay B i → Delay C i
 alignWith f (now a)   (now b)   = now (f (these a b))
 alignWith f (now a)   (later _) = now (f (this a))
 alignWith f (later _) (now b)   = now (f (that b))
 alignWith f (later a) (later b) = later λ where
   .force → alignWith f (a .force) (b .force)

module _ {a b} {A : Set a} {B : Set b} where

  zip : ∀ {i} → Delay A i → Delay B i → Delay (A × B) i
  zip   = zipWith _,_

  align : ∀ {i} → Delay A i → Delay B i → Delay (These A B) i
  align = alignWith id

------------------------------------------------------------------------
-- Finite Delays

module _ {ℓ} {A : Set ℓ} where

 infix 3 _⇓
 data _⇓ : Delay A ∞ → Set ℓ where
   now   : ∀ a → now a ⇓
   later : ∀ {d} → d .force ⇓ → later d ⇓

 extract : ∀ {d} → d ⇓ → A
 extract (now a)   = a
 extract (later d) = extract d

 ¬never⇓ : ¬ (never ⇓)
 ¬never⇓ (later p) = ¬never⇓ p

 length-⇓ : ∀ {d} → d ⇓ → Finite (length d)
 length-⇓ (now a)    = zero
 length-⇓ (later d⇓) = suc (length-⇓ d⇓)

module _ {ℓ ℓ′} {A : Set ℓ} {B : Set ℓ′} where

 map-⇓ : ∀ (f : A → B) {d} → d ⇓ → map f d ⇓
 map-⇓ f (now a)   = now (f a)
 map-⇓ f (later d) = later (map-⇓ f d)

 bind-⇓ : ∀ {m} (m⇓ : m ⇓) {f : A → Delay B ∞} → f (extract m⇓) ⇓ → bind m f ⇓
 bind-⇓ (now a)   fa⇓ = fa⇓
 bind-⇓ (later p) fa⇓ = later (bind-⇓ p fa⇓)
