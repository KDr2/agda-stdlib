------------------------------------------------------------------------
-- The Agda standard library
--
-- Coinductive vectors
------------------------------------------------------------------------

{-# OPTIONS --cubical-compatible --guardedness #-}

module Codata.Musical.Covec where

open import Codata.Musical.Notation using (♭; ∞; ♯_)
open import Codata.Musical.Conat as Coℕ using (Coℕ; zero; suc; _+_)
open import Codata.Musical.Cofin using (Cofin; zero; suc)
open import Codata.Musical.Colist as Colist using (Colist; []; _∷_)
open import Data.Nat.Base using (ℕ; zero; suc)
open import Data.Vec.Base using (Vec; []; _∷_)
open import Data.Product.Base using (_,_)
open import Function.Base using (_∋_)
open import Level using (Level)
open import Relation.Binary.Core using (_⇒_; _=[_]⇒_)
open import Relation.Binary.Bundles using (Setoid; Poset)
open import Relation.Binary.Definitions
  using (Reflexive; Symmetric; Transitive; Antisymmetric)
open import Relation.Binary.PropositionalEquality.Core as ≡ using (_≡_)

private
  variable
    a b : Level
    A : Set a
    B : Set b

------------------------------------------------------------------------
-- The type

infixr 5 _∷_
data Covec (A : Set a) : Coℕ → Set a where
  []  : Covec A zero
  _∷_ : ∀ {n} (x : A) (xs : ∞ (Covec A (♭ n))) → Covec A (suc n)

∷-injectiveˡ : ∀ {a b} {n} {as bs} → (Covec A (suc n) ∋ a ∷ as) ≡ b ∷ bs → a ≡ b
∷-injectiveˡ ≡.refl = ≡.refl

∷-injectiveʳ : ∀ {a b} {n} {as bs} → (Covec A (suc n) ∋ a ∷ as) ≡ b ∷ bs → as ≡ bs
∷-injectiveʳ ≡.refl = ≡.refl

------------------------------------------------------------------------
-- Some operations

map : ∀ {n} → (A → B) → Covec A n → Covec B n
map f []       = []
map f (x ∷ xs) = f x ∷ ♯ map f (♭ xs)

fromVec : ∀ {n} → Vec A n → Covec A (Coℕ.fromℕ n)
fromVec []       = []
fromVec (x ∷ xs) = x ∷ ♯ fromVec xs

fromColist : (xs : Colist A) → Covec A (Colist.length xs)
fromColist []       = []
fromColist (x ∷ xs) = x ∷ ♯ fromColist (♭ xs)

take : ∀ m {n} → Covec A (m + n) → Covec A m
take zero    xs       = []
take (suc n) (x ∷ xs) = x ∷ ♯ take (♭ n) (♭ xs)

drop : ∀ m {n} → Covec A (Coℕ.fromℕ m + n) → Covec A n
drop zero    xs       = xs
drop (suc n) (x ∷ xs) = drop n (♭ xs)

replicate : ∀ n → A → Covec A n
replicate zero    x = []
replicate (suc n) x = x ∷ ♯ replicate (♭ n) x

lookup : ∀ {n} → Covec A n → Cofin n → A
lookup (x ∷ xs) zero    = x
lookup (x ∷ xs) (suc n) = lookup (♭ xs) n

infixr 5 _++_

_++_ : ∀ {m n} → Covec A m → Covec A n → Covec A (m + n)
[]       ++ ys = ys
(x ∷ xs) ++ ys = x ∷ ♯ (♭ xs ++ ys)

[_] : A → Covec A (suc (♯ zero))
[ x ] = x ∷ ♯ []

------------------------------------------------------------------------
-- Equality and other relations

-- xs ≈ ys means that xs and ys are equal.

infix 4 _≈_

data _≈_ {A : Set a} : ∀ {n} (xs ys : Covec A n) → Set a where
  []  : [] ≈ []
  _∷_ : ∀ {n} x {xs ys}
        (xs≈ : ∞ (♭ xs ≈ ♭ ys)) → _≈_ {n = suc n} (x ∷ xs) (x ∷ ys)

-- x ∈ xs means that x is a member of xs.

infix 4 _∈_

data _∈_ {A : Set a} : ∀ {n} → A → Covec A n → Set a where
  here  : ∀ {n x  } {xs}                   → _∈_ {n = suc n} x (x ∷ xs)
  there : ∀ {n x y} {xs} (x∈xs : x ∈ ♭ xs) → _∈_ {n = suc n} x (y ∷ xs)

-- xs ⊑ ys means that xs is a prefix of ys.

infix 4 _⊑_

data _⊑_ {A : Set a} : ∀ {m n} → Covec A m → Covec A n → Set a where
  []  : ∀ {n} {ys : Covec A n} → [] ⊑ ys
  _∷_ : ∀ {m n} x {xs ys} (p : ∞ (♭ xs ⊑ ♭ ys)) →
        _⊑_ {m = suc m} {suc n} (x ∷ xs) (x ∷ ys)

------------------------------------------------------------------------
-- Some proofs

setoid : ∀ {a} → Set a → Coℕ → Setoid _ _
setoid A n = record
  { Carrier       = Covec A n
  ; _≈_           = _≈_
  ; isEquivalence = record
    { refl  = refl
    ; sym   = sym
    ; trans = trans
    }
  }
  where
  refl : ∀ {n} → Reflexive (_≈_ {n = n})
  refl {x = []}     = []
  refl {x = x ∷ xs} = x ∷ ♯ refl

  sym : ∀ {n} → Symmetric (_≈_ {A = A} {n})
  sym []        = []
  sym (x ∷ xs≈) = x ∷ ♯ sym (♭ xs≈)

  trans : ∀ {n} → Transitive (_≈_ {A = A} {n})
  trans []        []         = []
  trans (x ∷ xs≈) (.x ∷ ys≈) = x ∷ ♯ trans (♭ xs≈) (♭ ys≈)

poset : ∀ {a} → Set a → Coℕ → Poset _ _ _
poset A n = record
  { Carrier        = Covec A n
  ; _≈_            = _≈_
  ; _≤_            = _⊑_
  ; isPartialOrder = record
    { isPreorder = record
      { isEquivalence = Setoid.isEquivalence (setoid A n)
      ; reflexive     = reflexive
      ; trans         = trans
      }
    ; antisym  = antisym
    }
  }
  where
  reflexive : ∀ {n} → _≈_ {n = n} ⇒ _⊑_
  reflexive []        = []
  reflexive (x ∷ xs≈) = x ∷ ♯ reflexive (♭ xs≈)

  trans : ∀ {n} → Transitive (_⊑_ {n = n})
  trans []        _          = []
  trans (x ∷ xs≈) (.x ∷ ys≈) = x ∷ ♯ trans (♭ xs≈) (♭ ys≈)

  tail : ∀ {n x y xs ys} →
         _∷_ {n = n} x xs ⊑ _∷_ {n = n} y ys → ♭ xs ⊑ ♭ ys
  tail (_ ∷ p) = ♭ p

  antisym : ∀ {n} → Antisymmetric (_≈_ {n = n}) _⊑_
  antisym []       [] = []
  antisym (x ∷ p₁) p₂ = x ∷ ♯ antisym (♭ p₁) (tail p₂)

map-cong : ∀ {n} (f : A → B) → _≈_ {n = n} =[ map f ]⇒ _≈_
map-cong f []        = []
map-cong f (x ∷ xs≈) = f x ∷ ♯ map-cong f (♭ xs≈)

take-⊑ : ∀ m {n} (xs : Covec A (m + n)) → take m xs ⊑ xs
take-⊑ zero    xs       = []
take-⊑ (suc n) (x ∷ xs) = x ∷ ♯ take-⊑ (♭ n) (♭ xs)
