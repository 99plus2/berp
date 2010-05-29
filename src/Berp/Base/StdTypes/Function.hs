-----------------------------------------------------------------------------
-- |
-- Module      : Berp.Base.StdTypes.Function
-- Copyright   : (c) 2010 Bernie Pope
-- License     : BSD-style
-- Maintainer  : florbitous@gmail.com
-- Stability   : experimental
-- Portability : ghc
--
-- The standard function type.
--
-----------------------------------------------------------------------------

module Berp.Base.StdTypes.Function (function, functionClass) where

import Berp.Base.Monad (constantIO)
import Berp.Base.SemanticTypes (Object (..), Procedure)
import Berp.Base.Identity (newIdentity)
import Berp.Base.Attributes (mkAttributes)
import Berp.Base.StdTypes.Dictionary (emptyDictionary)
import {-# SOURCE #-} Berp.Base.StdTypes.Type (newType)
import Berp.Base.StdTypes.ObjectBase (objectBase)
import Berp.Base.StdTypes.String (string)

{-# NOINLINE function #-}
function :: Int -> Procedure -> Object 
function arity p = constantIO $ do 
   identity <- newIdentity
   dict <- emptyDictionary
   return $
      Function 
      { object_identity = identity 
      , object_dict = dict 
      , object_procedure = p
      , object_arity = arity
      }

{-# NOINLINE functionClass #-}
functionClass :: Object
functionClass = constantIO $ do 
   dict <- attributes
   newType [string "function", objectBase, dict]

-- XXX update my attributes
attributes :: IO Object 
attributes = mkAttributes []
