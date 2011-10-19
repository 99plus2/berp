-----------------------------------------------------------------------------
-- |
-- Module      : Berp.Base.StdTypes.ObjectBase
-- Copyright   : (c) 2010 Bernie Pope
-- License     : BSD-style
-- Maintainer  : florbitous@gmail.com
-- Stability   : experimental
-- Portability : ghc
--
-- Most (all?) of the standard types have "object" as their (only) base
-- class. In Python the base classes are stored as a tuple of objects.
-- Since this is shared by many of the standard types it makes sense
-- to define it once, instead of making many copies.
--
-----------------------------------------------------------------------------

module Berp.Base.StdTypes.ObjectBase (objectBase) where

import Berp.Base.SemanticTypes (Object, Eval)
import Berp.Base.Prims (lookupBuiltin)
-- import {-# SOURCE #-} Berp.Base.StdTypes.Object (object)
import {-# SOURCE #-} Berp.Base.StdTypes.Tuple (tuple)
import Berp.Base.LiftedIO as LIO (putStrLn)

objectBase :: Eval Object
objectBase = do
   LIO.putStrLn "objectBase 0"
   object <- lookupBuiltin "object"
   LIO.putStrLn "objectBase 1"
   tuple [object]
