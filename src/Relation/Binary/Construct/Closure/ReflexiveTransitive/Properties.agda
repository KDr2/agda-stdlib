------------------------------------------------------------------------
-- The Agda standard library
--
-- Some properties of reflexive transitive closures.
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --safe #-}

module Relation.Binary.Construct.Closure.ReflexiveTransitive.Properties where

open import Function.Base using (id; _∘_; _$_)
open import Relation.Binary.Core using (Rel; _=[_]⇒_; _⇒_)
open import Relation.Binary.Bundles using (Preorder)
open import Relation.Binary.Structures using (IsPreorder)
open import Relation.Binary.Definitions using (Transitive; Reflexive)
open import Relation.Binary.Construct.Closure.ReflexiveTransitive
  using (Star; _◅_; _◅◅_; gmap; fold; ε)
open import Relation.Binary.PropositionalEquality.Core as ≡
  using (_≡_; refl; sym; cong; cong₂)
import Relation.Binary.PropositionalEquality.Properties as ≡
import Relation.Binary.Reasoning.Preorder as ≲-Reasoning
open import Relation.Binary.Reasoning.Syntax

------------------------------------------------------------------------
-- _◅◅_

module _ {i t} {I : Set i} {T : Rel I t} where

  ◅◅-assoc : ∀ {i j k l}
             (xs : Star T i j) (ys : Star T j k) (zs : Star T k l) →
             (xs ◅◅ ys) ◅◅ zs ≡ xs ◅◅ (ys ◅◅ zs)
  ◅◅-assoc ε        ys zs = refl
  ◅◅-assoc (x ◅ xs) ys zs = cong (_◅_ x) (◅◅-assoc xs ys zs)

------------------------------------------------------------------------
-- gmap

gmap-id : ∀ {i t} {I : Set i} {T : Rel I t} {i j} (xs : Star T i j) →
          gmap id id xs ≡ xs
gmap-id ε        = refl
gmap-id (x ◅ xs) = cong (_◅_ x) (gmap-id xs)

gmap-∘ : ∀ {i t} {I : Set i} {T : Rel I t}
           {j u} {J : Set j} {U : Rel J u}
           {k v} {K : Set k} {V : Rel K v}
         (f  : J → K) (g  : U =[ f  ]⇒ V)
         (f′ : I → J) (g′ : T =[ f′ ]⇒ U)
         {i j} (xs : Star T i j) →
         (gmap {U = V} f g ∘ gmap f′ g′) xs ≡ gmap (f ∘ f′) (g ∘ g′) xs
gmap-∘ f g f′ g′ ε        = refl
gmap-∘ f g f′ g′ (x ◅ xs) = cong (_◅_ (g (g′ x))) (gmap-∘ f g f′ g′ xs)

gmap-◅◅ : ∀ {i t j u}
            {I : Set i} {T : Rel I t} {J : Set j} {U : Rel J u}
          (f : I → J) (g : T =[ f ]⇒ U)
          {i j k} (xs : Star T i j) (ys : Star T j k) →
          gmap {U = U} f g (xs ◅◅ ys) ≡ gmap f g xs ◅◅ gmap f g ys
gmap-◅◅ f g ε        ys = refl
gmap-◅◅ f g (x ◅ xs) ys = cong (_◅_ (g x)) (gmap-◅◅ f g xs ys)

gmap-cong : ∀ {i t j u}
              {I : Set i} {T : Rel I t} {J : Set j} {U : Rel J u}
            (f : I → J) (g : T =[ f ]⇒ U) (g′ : T =[ f ]⇒ U) →
            (∀ {i j} (x : T i j) → g x ≡ g′ x) →
            ∀ {i j} (xs : Star T i j) →
            gmap {U = U} f g xs ≡ gmap f g′ xs
gmap-cong f g g′ eq ε        = refl
gmap-cong f g g′ eq (x ◅ xs) = cong₂ _◅_ (eq x) (gmap-cong f g g′ eq xs)

------------------------------------------------------------------------
-- fold

fold-◅◅ : ∀ {i p} {I : Set i}
          (P : Rel I p) (_⊕_ : Transitive P) (∅ : Reflexive P) →
          (∀ {i j} (x : P i j) → (∅ ⊕ x) ≡ x) →
          (∀ {i j k l} (x : P i j) (y : P j k) (z : P k l) →
             ((x ⊕ y) ⊕ z) ≡ (x ⊕ (y ⊕ z))) →
          ∀ {i j k} (xs : Star P i j) (ys : Star P j k) →
          fold P _⊕_ ∅ (xs ◅◅ ys) ≡ (fold P _⊕_ ∅ xs ⊕ fold P _⊕_ ∅ ys)
fold-◅◅ P _⊕_ ∅ left-unit assoc ε        ys = sym (left-unit _)
fold-◅◅ P _⊕_ ∅ left-unit assoc (x ◅ xs) ys = begin
  (x ⊕  fold P _⊕_ ∅ (xs ◅◅ ys))              ≡⟨ cong (_⊕_ x) $
                                                   fold-◅◅ P _⊕_ ∅ left-unit assoc xs ys ⟩
  (x ⊕ (fold P _⊕_ ∅ xs  ⊕ fold P _⊕_ ∅ ys))  ≡⟨ sym (assoc x _ _) ⟩
  ((x ⊕ fold P _⊕_ ∅ xs) ⊕ fold P _⊕_ ∅ ys)   ∎
  where open ≡.≡-Reasoning

------------------------------------------------------------------------
-- Relational properties

module _ {i t} {I : Set i} (T : Rel I t) where

  reflexive : _≡_ ⇒ Star T
  reflexive refl = ε

  trans : Transitive (Star T)
  trans = _◅◅_

  isPreorder : IsPreorder _≡_ (Star T)
  isPreorder = record
    { isEquivalence = ≡.isEquivalence
    ; reflexive     = reflexive
    ; trans         = trans
    }

  preorder : Preorder _ _ _
  preorder = record
    { _≈_        = _≡_
    ; _≲_        = Star T
    ; isPreorder = isPreorder
    }

------------------------------------------------------------------------
-- Preorder reasoning for Star

module StarReasoning {i t} {I : Set i} (T : Rel I t) where
  private module Base = ≲-Reasoning (preorder T)

  open Base public
    hiding (step-≈; step-≈˘; step-≈-⟩; step-≈-⟨; step-∼; step-≲)
    renaming (≲-go to ⟶-go)

  open ⟶-syntax _IsRelatedTo_ _IsRelatedTo_ (⟶-go ∘ (_◅ ε)) public
  open ⟶*-syntax _IsRelatedTo_ _IsRelatedTo_ ⟶-go public
