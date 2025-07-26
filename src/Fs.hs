module Fs
    ( listBackupFiles
    ) where

import System.Directory (doesDirectoryExist, listDirectory)
import System.FilePath ((</>))

listBackupFiles :: FilePath -> Bool -> IO [FilePath]
listBackupFiles d withDotfiles = do
    dirExists <- doesDirectoryExist d
    if not dirExists then return [] else traverseBackupTree d

traverseBackupTree :: FilePath -> IO [FilePath]
traverseBackupTree path = do
    contents <- listDirectory path
    paths <- mapM (recurse . (path </>)) contents
    return (concat paths)
  where
    recurse p = do
        isDir <- doesDirectoryExist p
        if isDir
            then traverseBackupTree p
            else return [p]
