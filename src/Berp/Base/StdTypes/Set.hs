-----------------------------------------------------------------------------
-- |
-- Module      : Berp.Base.StdTypes.Set
-- Copyright   : (c) 2010 Bernie Pope
-- License     : BSD-style
-- Maintainer  : florbitous@gmail.com
-- Stability   : experimental
-- Portability : ghc
--
-- The standard set type.
--
-----------------------------------------------------------------------------

module Berp.Base.StdTypes.Set (emptySet, set, setClass) where

import Data.List (intersperse)
import Berp.Base.Prims (primitive, showObject)
import Berp.Base.Monad (constantIO)
import Berp.Base.SemanticTypes (Procedure, Object (..), Eval)
import Berp.Base.Identity (newIdentity)
import Berp.Base.HashSet as Hash (fromList, empty, elements, insert)
import Berp.Base.Attributes (mkAttributes)
import Berp.Base.StdTypes.Type (newType)
import Berp.Base.StdTypes.ObjectBase (objectBase)
import Berp.Base.StdTypes.String (string)
import Berp.Base.StdTypes.None (none)
import Berp.Base.StdNames

emptySet :: IO Object
emptySet = do
   identity <- newIdentity
   hashSet <- Hash.empty
   return $
      Set
      { object_identity = identity
      , object_hashSet = hashSet
      }

set :: [Object] -> Eval Object
set elements = do
   identity <- newIdentity
   hashSet <- fromList elements
   return $
      Set
      { object_identity = identity
      , object_hashSet = hashSet
      }

{-# NOINLINE setClass #-}
setClass :: Object
setClass = constantIO $ do
   dict <- attributes
   newType [string "set", objectBase, dict]

attributes :: IO Object
attributes = mkAttributes
   [ (specialEqName, primitive 2 eq)
   , (specialStrName, primitive 1 str)
   , (addName, primitive 2 add)
   ]

eq :: Procedure
eq = error "== on set not defined"

add :: Procedure
add (set:obj:_) = do
   insert obj $ object_hashSet set
   return none
add _other = error "set.add called with wrong number of arguments"

str :: Procedure
str (obj:_) = do
   es <- elements $ object_hashSet obj
   strs <- mapM setEntryString es
   return $ string ("{" ++ concat (intersperse ", " strs) ++ "}")
   where
   setEntryString :: Object -> Eval String
   setEntryString obj = showObject obj
str _other = error "str conversion on set applied to wrong number of arguments"
