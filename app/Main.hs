{-# LANGUAGE DeriveDataTypeable #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use newtype instead of data" #-}

module Main (main) where

import Fs
import System.Console.CmdArgs

data CliConfig = CliConfig {dataDir :: FilePath, withDotFiles :: Bool, followSymLinks :: Bool, withLatestSystem :: Bool} deriving (Show, Data, Typeable)

main :: IO ()
main = do
  config <- cmdArgs cc
  filesToBackup <- listBackupFiles $ dataDir config
  print filesToBackup
  where
    cc =
      CliConfig
        { dataDir =
            def
              &= help "The root dir of files to backup"
              &= typDir
              &= opt "/home/",
          withDotFiles =
            def
              &= help "If dotfiles should be backuped too",
          followSymLinks = def &= help "If the tool should resolve symlinks and backup the destination",
          withLatestSystem = def &= help "Backup the latest system build"
        }
        &= summary "n2s3 v0.0.1"
