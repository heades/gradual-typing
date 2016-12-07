{-# LANGUAGE FlexibleInstances, TemplateHaskell, MultiParamTypeClasses, UndecidableInstances #-}
module Syntax (module Unbound.LocallyNameless, 
               module Unbound.LocallyNameless.Alpha,
               n2s,
               Vnm,
               Type(..),
               Term(..),
               isTerminating,
               is_atomic,
               skeleton_of,
               is_skeleton) where

import Unbound.LocallyNameless 
import Unbound.LocallyNameless.Alpha
      
data Type =               -- Types:
   Nat                    -- Natural number type
 | Unit                   -- Unit type
 | U                      -- Untyped universe
 | Arr Type Type          -- Function type
 | Prod Type Type         -- Product type
 deriving (Show, Eq)

-- If A : Type, and isTerminating A = True, then A is a terminating
-- type (or in the syntactic class T).
isTerminating :: Type -> Bool                 
isTerminating U = False
isTerminating (Arr t1 t2) = (isTerminating t1) && (isTerminating t2)
isTerminating (Prod t1 t2) = (isTerminating t1) && (isTerminating t2)
isTerminating _ = True

-- Tests to determine if a type is atomic.
is_atomic :: Type -> Bool
is_atomic (Arr _ _) = False
is_atomic (Prod _ _) = False
is_atomic _ = True

-- Converts a type into its skeleton.
skeleton_of :: Type -> Type
skeleton_of b | is_atomic b = U
skeleton_of (Arr a b)  = Arr (skeleton_of a) (skeleton_of b)
skeleton_of (Prod a b) = Prod (skeleton_of a) (skeleton_of b)

is_skeleton :: Type -> Bool
is_skeleton U = True
is_skeleton (Arr a b) = (is_skeleton a) && (is_skeleton b)
is_skeleton (Prod a b) = (is_skeleton a) && (is_skeleton b)
is_skeleton _ = False

type Vnm = Name Term            -- Variable name

data Term =
   Var Vnm                      -- Free variable
 | Triv                         -- Unit's inhabitant
 | Squash                         -- Injection of the retract
 | Split                        -- Surjection of the retract
 | Box Type                     -- Generalize to the untyped universe
 | Unbox Type                   -- Specialize the untype universe to a specific type
 | Fun Type (Bind Vnm Term)     -- \lambda-abstraction
 | App Term Term                -- Function application
 | Pair Term Term               -- Pairs
 | Fst Term                     -- First projection
 | Snd Term                     -- Second projection
 | Succ Term                    -- Successor of a natural number
 | Zero                         -- The natural number 0
 deriving Show
 
-- Derives all of the meta-machinary like substitution and
-- \alpha-equality for us.
$(derive [''Term,''Type])

instance Alpha Term
instance Alpha Type

instance Subst Term Type
instance Subst Term Term where
  isvar (Var x) = Just (SubstName x)
  isvar _ = Nothing

n2s :: Name a -> String
n2s = name2String