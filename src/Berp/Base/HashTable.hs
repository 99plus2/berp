{-# OPTIONS_GHC -XTemplateHaskell #-}
module Berp.Base.HashTable 
   ( empty
   , insert
   , lookup
   , delete
   , hashObject
   , fromList
   , stringTableFromList
   , stringLookup 
   ) where

import Prelude hiding (lookup)
import Data.IntMap (IntMap)
import qualified Data.IntMap as IntMap 
import Data.IORef
import Control.Applicative ((<$>))
import Control.Monad (zipWithM, foldM)
import Control.Monad.Trans (liftIO)
import Berp.Base.SemanticTypes (Object (..), Eval, HashTable)
import Berp.Base.Object (hasAttribute)
import Berp.Base.Prims (callMethod)
import Berp.Base.Identity (Identity)
import Berp.Base.Truth (truth)
import Berp.Base.Hash (hash, Hashed, hashedStr)
import {-# SOURCE #-} Berp.Base.StdTypes.String (string)

hashObject :: Object -> Eval Int
hashObject obj@(String {}) = return $ hash $ object_string obj
hashObject obj@(Integer {}) = return $ hash $ object_integer obj
hashObject obj@(Bool {}) = if object_bool obj then return 1 else return 0
hashObject obj@(None {}) = return $ hash $ object_identity obj -- copying what Python3.0 seems to do
hashObject obj@(Function {}) = return $ hash $ object_identity obj
hashObject object = do
   hashResult <- callMethod object $(hashedStr "__hash__") []
   case hashResult of
      Integer {} -> return $ fromInteger $ object_integer hashResult
      other -> fail $ "__hash__ method on object does not return an integer: " ++ show object

empty :: IO HashTable 
empty = newIORef IntMap.empty

fromList :: [(Object, Object)] -> Eval HashTable
fromList pairs = do
   keysVals <- mapM toKeyVal pairs
   liftIO $ newIORef $ IntMap.fromListWith (++) keysVals
   where
   toKeyVal :: (Object, Object) -> Eval (Int, [(Object, Object)])
   toKeyVal pair@(key, val) = do
      hashValue <- hashObject key
      return (hashValue, [pair])

stringTableFromList :: [(Hashed String, Object)] -> IO HashTable
stringTableFromList pairs = do
   keysVals <- mapM toKeyVal pairs
   liftIO $ newIORef $ IntMap.fromListWith (++) keysVals
   where
   toKeyVal :: (Hashed String, Object) -> IO (Int, [(Object, Object)])
   toKeyVal ((hashValue,strKey), val) = do
      let strObj = string strKey 
      return (hashValue, [(strObj, val)])

stringLookup :: Hashed String -> HashTable -> IO (Maybe Object)
stringLookup (hashValue, str) hashTable = do
   table <- liftIO $ readIORef hashTable
   case IntMap.lookup hashValue table of
      Nothing -> return Nothing
      Just matches -> return $ linearSearchString str matches
   where
   linearSearchString :: String -> [(Object, Object)] -> Maybe Object
   linearSearchString _ [] = Nothing
   linearSearchString str ((key, value) : rest)
      | objectEqualityString str key = Just value
      | otherwise = linearSearchString str rest

objectEqualityString :: String -> Object -> Bool
objectEqualityString str1 (String { object_string = str2 }) = str1 == str2
objectEqualityString _ _ = False

-- XXX Potential space leak by not deleteing old versions of key in the table.
-- maybe we can delete based on the identity of the object? That would not avoid
-- the leak in all cases, but it might work in common cases.
insert :: Object -> Object -> HashTable -> Eval ()
insert key value hashTable = do
   table <- liftIO $ readIORef hashTable
   hashValue <- hashObject key 
   let newTable = IntMap.insertWith (++) hashValue [(key,value)] table
   liftIO $ writeIORef hashTable newTable 

lookup :: Object -> HashTable -> Eval (Maybe Object)
lookup key hashTable = do
   table <- liftIO $ readIORef hashTable
   hashValue <- hashObject key 
   case IntMap.lookup hashValue table of
      Nothing -> return Nothing
      Just matches -> linearSearch key matches 
   where
   linearSearch :: Object -> [(Object, Object)] -> Eval (Maybe Object)
   linearSearch _ [] = return Nothing
   linearSearch object ((key,value):rest) = do
      areEqual <- objectEquality object key
      if areEqual 
         then return (Just value)
         else linearSearch object rest 

linearFilter :: Object -> [(Object, Object)] -> Eval [(Object, Object)]
linearFilter object matches = foldM collectNotEquals [] matches 
   where
   collectNotEquals :: [(Object, Object)] -> (Object, Object) -> Eval [(Object, Object)]
   collectNotEquals acc pair@(key, value) = do
      areEqual <- objectEquality object key
      return $ if areEqual then acc else pair:acc 

delete :: Object -> HashTable -> Eval ()
delete key hashTable = do
   table <- liftIO $ readIORef hashTable
   hashValue <- hashObject key
   case IntMap.lookup hashValue table of
      Nothing -> return ()
      Just matches -> do
         newMatches <- linearFilter key matches
         let newTable = IntMap.adjust (const newMatches) hashValue table
         liftIO $ writeIORef hashTable newTable

-- | Check if two objects are equal. For some objects we might have
--   to call the __eq__ (or __cmp__) method on the objects. This means
--   the result must be in the Eval monad.
objectEquality :: Object -> Object -> Eval Bool
objectEquality obj1@(Integer {}) obj2@(Integer {})
   = return (object_integer obj1 == object_integer obj2)
objectEquality obj1@(Bool {}) obj2@(Bool {})
   = return (object_bool obj1 == object_bool obj2)
objectEquality obj1@(Tuple {}) obj2@(Tuple {})
   | object_identity obj1 == object_identity obj2 = return True
   | object_length obj1 == object_length obj2 = 
        and <$> zipWithM objectEquality (object_tuple obj1) (object_tuple obj2)
   | otherwise = return False
objectEquality obj1@(String {}) obj2@(String {})
   = return (object_string obj1 == object_string obj2)
objectEquality None None = return True
objectEquality obj1 obj2 = do
   canEq <- liftIO $ hasAttribute obj1 eqName 
   if canEq 
      then truth <$> callMethod obj1 eqName [obj2] 
      else do
         canCmp <- liftIO $ hasAttribute obj1 cmpName 
         if canCmp
            then do 
               cmpResult <- callMethod obj1 cmpName [obj2]
               case cmpResult of
                  Integer {} -> return $ object_integer cmpResult == 0
                  other -> fail $ "__cmp__ method on object does not return an integer: " ++ show obj1 
            else return False -- XXX should this raise an exception?

eqName, cmpName :: Hashed String
eqName = $(hashedStr "__eq__")
cmpName = $(hashedStr "__cmp__")

{-
isHashable :: Object -> IO Bool
isHashable (String {}) = return True
isHashable (Integer {}) = return True
isHashable (Bool {}) = return True
isHashable (None {}) = return True
isHashable (Function {}) = return True
isHashable (Dictionary {}) = return False
isHashable (List {}) = return False
-- An object is hashable if it has a __hash__ method and
-- (it has an __eq__ method or a __comp__ method).
isHashable object = do
   canHash <- hasAttribute object "__hash__" 
   if canHash
      then do
         canEq <- hasAttribute object "__eq__"
         if canEq 
            then return True
            else hasAttribute object "__cmp__"
      else return False
-}
