-----------------------------------------------------------------------------
-- |
-- Module      : Main
-- Copyright   : (c) 2011 Bernie Pope
-- License     : BSD-style
-- Maintainer  : florbitous@gmail.com
-- Stability   : experimental
-- Portability : ghc
--
-- The Main module of Berpi. The interactive interpreter
-- are started from here.
--
-----------------------------------------------------------------------------

module Main where

import Control.Monad (when)
import System.Console.ParseArgs
   (Arg (..), gotArg, parseArgsIO, ArgsComplete (..), Args(..))
import System.Exit (ExitCode (..), exitWith)
import Berp.Version (versionString)
import Repl (repl)

main :: IO ()
main = do
   let args = [version, help]
   argMap <- parseArgsIO ArgsComplete args
   when (gotArg argMap Help) $ do
      putStrLn $ argsUsage argMap
      exitWith ExitSuccess
   when (gotArg argMap Version) $ do
      putStrLn $ "berp version " ++ versionString
      exitWith ExitSuccess
   repl

data ArgIndex
   = Help
   | WithGHC
   | Version
   deriving (Eq, Ord, Show)

help :: Arg ArgIndex
help =
   Arg
   { argIndex = Help
   , argAbbr = Just 'h'
   , argName = Just "help"
   , argData = Nothing
   , argDesc = "Display a help message."
   }

version :: Arg ArgIndex
version =
   Arg
   { argIndex = Version
   , argAbbr = Nothing
   , argName = Just "version"
   , argData = Nothing
   , argDesc = "Show the version number of berp."
   }
