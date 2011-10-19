module Berp.Base.HashSet
   ( empty
   , insert
   , lookup
   , delete
   , fromList
   , elements
   , size
   ) where

import Prelude hiding (lookup)
import Berp.Base.SemanticTypes (Object, Eval, HashSet)
import Berp.Base.LiftedIO (MonadIO)

empty :: MonadIO m => m HashSet
fromList :: [Object] -> Eval HashSet
insert :: Object -> HashSet -> Eval ()
lookup :: Object -> HashSet -> Eval Bool
delete :: Object -> HashSet -> Eval ()
size :: HashSet -> Eval Integer
elements :: HashSet -> Eval [Object]
