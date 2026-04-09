module Main (main) where

import qualified Data.Text as T
import Data.Time.Clock (getCurrentTime)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Vx.Api (ResolveError (..), fetchVersions, resolveVersion)
import Vx.Cache (PackageCache (..), addVersion, cachePath, emptyCache, lookupVersion, readCache, setAvailableVersions, writeCache)
import Vx.Exec (execNixRun)
import Vx.Parse (PackageSpec (..), parsePackageSpec)
import Vx.Platform (currentSystem)
import Vx.Resolve (buildNixRunCommand)
import Vx.Suggest (findNeighbors, formatSuggestion)

main :: IO ()
main = do
  args <- getArgs
  let (useCache, rest) = case args of
        ("--no-cache" : xs) -> (False, xs)
        xs -> (True, xs)
  case rest of
    [] -> die "usage: vx [--no-cache] <package>-<version> [args...]"
    (spec : passthrough) ->
      case parsePackageSpec (T.pack spec) of
        Nothing -> die $ "could not parse package spec: " <> spec
        Just pkg -> run useCache pkg (map T.pack passthrough)
 where
  run useCache pkg passthrough = do
    let name = packageName pkg
        ver = packageVersion pkg
    cpath <- cachePath name currentSystem

    -- Check cache first
    cached <- if useCache
      then lookupVersion ver <$> readCache cpath
      else pure Nothing

    case cached of
      Just response -> execNixRun (buildNixRunCommand response passthrough)
      Nothing -> do
        result <- resolveVersion name ver currentSystem
        case result of
          Right response -> do
            cacheAndExec cpath ver response passthrough
          Left VersionNotFound -> do
            handleVersionNotFound useCache cpath name ver
          Left (ApiError err) -> die $ "resolve failed: " <> T.unpack err

  cacheAndExec cpath ver response passthrough = do
    cache <- readCache cpath
    writeCache cpath (addVersion ver response cache)
    execNixRun (buildNixRunCommand response passthrough)

  handleVersionNotFound useCache cpath name ver = do
    -- Try cached available versions first
    cache <- if useCache then readCache cpath else pure emptyCache
    case availableVersions cache of
      Just vs | not (null (findNeighbors ver vs)) ->
        die $ T.unpack $ formatSuggestion name ver (findNeighbors ver vs)
      _ -> do
        -- Fetch fresh version list
        versionsResult <- fetchVersions name
        case versionsResult of
          Left err -> die $ T.unpack err
          Right vs -> do
            now <- getCurrentTime
            writeCache cpath (setAvailableVersions vs now cache)
            let neighbors = findNeighbors ver vs
            die $ T.unpack $ formatSuggestion name ver neighbors

  die msg = hPutStrLn stderr msg >> exitFailure
