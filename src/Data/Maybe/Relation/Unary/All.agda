------------------------------------------------------------------------
-- The Agda standard library
--
-- Maybes where all the elements satisfy a given property
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

module Data.Maybe.Relation.Unary.All where

open import Data.Maybe.Base using (Maybe; just; nothing)
open import Data.Maybe.Relation.Unary.Any using (Any; just)
open import Data.Product.Base as Product using (_,_)
open import Effect.Applicative using (RawApplicative)
open import Effect.Monad using (RawMonad)
open import Function.Base using (id; _∘′_)
open import Function.Bundles using (_⇔_; mk⇔)
open import Level using (Level; _⊔_)
open import Relation.Binary.PropositionalEquality.Core using (_≡_; refl; cong)
open import Relation.Nullary hiding (Irrelevant)
import Relation.Nullary.Decidable as Dec using (Dec; yes; no; map)
open import Relation.Unary
  using (Pred; _⊆_; _∩_; _∪_; Decidable; Universal; Irrelevant; Satisfiable)

------------------------------------------------------------------------
-- Definition

data All {a p} {A : Set a} (P : Pred A p) : Pred (Maybe A) (a ⊔ p) where
  just    : ∀ {x} → P x → All P (just x)
  nothing : All P nothing

------------------------------------------------------------------------
-- Basic operations

module _ {a p} {A : Set a} {P : Pred A p} where

  drop-just : ∀ {x} → All P (just x) → P x
  drop-just (just px) = px

  just-equivalence : ∀ {x} → P x ⇔ All P (just x)
  just-equivalence = mk⇔ just drop-just

  map : ∀ {q} {Q : Pred A q} → P ⊆ Q → All P ⊆ All Q
  map f (just px) = just (f px)
  map f nothing   = nothing

  fromAny : Any P ⊆ All P
  fromAny (just px) = just px

------------------------------------------------------------------------
-- (un/)zip(/With)

module _ {a p q r} {A : Set a} {P : Pred A p} {Q : Pred A q} {R : Pred A r} where

  zipWith : P ∩ Q ⊆ R → All P ∩ All Q ⊆ All R
  zipWith f (just px , just qx) = just (f (px , qx))
  zipWith f (nothing , nothing) = nothing

  unzipWith : P ⊆ Q ∩ R → All P ⊆ All Q ∩ All R
  unzipWith f (just px) = Product.map just just (f px)
  unzipWith f nothing   = nothing , nothing

module _ {a p q} {A : Set a} {P : Pred A p} {Q : Pred A q} where

  zip : All P ∩ All Q ⊆ All (P ∩ Q)
  zip = zipWith id

  unzip : All (P ∩ Q) ⊆ All P ∩ All Q
  unzip = unzipWith id

------------------------------------------------------------------------
-- Traversable-like functions

module _ {a f} p {A : Set a} {P : Pred A (a ⊔ p)} {F}
         (App : RawApplicative {a ⊔ p} {f} F) where

  open RawApplicative App

  sequenceA : All (F ∘′ P) ⊆ F ∘′ All P
  sequenceA nothing   = pure nothing
  sequenceA (just px) = just <$> px

  mapA : ∀ {q} {Q : Pred A q} → (Q ⊆ F ∘′ P) → All Q ⊆ (F ∘′ All P)
  mapA f = sequenceA ∘′ map f

  forA : ∀ {q} {Q : Pred A q} {xs} → All Q xs → (Q ⊆ F ∘′ P) → F (All P xs)
  forA qxs f = mapA f qxs

module _ {a f} p {A : Set a} {P : Pred A (a ⊔ p)} {M}
         (Mon : RawMonad {a ⊔ p} {f} M) where

  private App = RawMonad.rawApplicative Mon

  sequenceM : All (M ∘′ P) ⊆ M ∘′ All P
  sequenceM = sequenceA p App

  mapM : ∀ {q} {Q : Pred A q} → (Q ⊆ M ∘′ P) → All Q ⊆ (M ∘′ All P)
  mapM = mapA p App

  forM : ∀ {q} {Q : Pred A q} {xs} → All Q xs → (Q ⊆ M ∘′ P) → M (All P xs)
  forM = forA p App

------------------------------------------------------------------------
-- Seeing All as a predicate transformer

module _ {a p} {A : Set a} {P : Pred A p} where

  dec : Decidable P → Decidable (All P)
  dec P-dec nothing  = yes nothing
  dec P-dec (just x) = Dec.map just-equivalence (P-dec x)

  universal : Universal P → Universal (All P)
  universal P-universal (just x) = just (P-universal x)
  universal P-universal nothing  = nothing

  irrelevant : Irrelevant P → Irrelevant (All P)
  irrelevant P-irrelevant (just p) (just q) = cong just (P-irrelevant p q)
  irrelevant P-irrelevant nothing  nothing  = refl

  satisfiable : Satisfiable (All P)
  satisfiable = nothing , nothing
