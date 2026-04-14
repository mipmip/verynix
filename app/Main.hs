module Main (main) where

import Data.Version (showVersion)
import qualified Data.Text as T
import Data.Time.Clock (getCurrentTime)
import Options.Applicative
import Paths_vx (version)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Vx.Api (ResolveError (..), fetchVersions, resolveVersion)
import Vx.Cache (PackageCache (..), addVersion, cachePath, emptyCache, lookupVersion, readCache, setAvailableVersions, writeCache)
import Vx.Exec (execNixRun)
import Vx.Parse (PackageSpec (..), parsePackageSpec)
import Vx.Platform (currentSystem)
import Vx.Resolve (NixRunCommand (..), buildNixRunCommand, renderCommand)
import Vx.Suggest (findNeighbors, formatSuggestion)

data Options = Options
  { optVerbose :: Bool
  , optNoCache :: Bool
  , optSpec :: String
  , optArgs :: [String]
  }

optionsParser :: Parser Options
optionsParser =
  Options
    <$> switch (long "verbose" <> short 'v' <> help "Show resolution details")
    <*> switch (long "no-cache" <> help "Bypass the local cache")
    <*> argument str (metavar "<package>[-<version>]")
    <*> many (argument str (metavar "ARGS..."))

opts :: ParserInfo Options
opts =
  info
    (optionsParser <**> helper <**> versionOption)
    ( fullDesc
        <> progDesc "Run any version of any Nix package"
        <> header "vx - Very niX"
    )
 where
  versionOption = infoOption (showVersion version) (long "version" <> short 'V' <> help "Show version")

main :: IO ()
main = do
  options <- execParser opts
  case parsePackageSpec (T.pack (optSpec options)) of
    Nothing -> die $ "could not parse package spec: " <> optSpec options
    Just pkg -> run options pkg (map T.pack (optArgs options))
 where
  run options pkg passthrough = do
    let verbose = optVerbose options
        name = packageName pkg
        ver = packageVersion pkg
        isLatest = ver == Nothing
        versionStr = maybe "latest" id ver
        useCache = not (optNoCache options) && not isLatest
        apiUrl = "https://search.devbox.sh/v2/resolve?name=" <> name <> "&version=" <> versionStr
        versionDisplay = maybe "(latest)" id ver

    verboseLog verbose $ "resolving " <> name <> " " <> versionDisplay <> " for " <> currentSystem <> "..."

    cpath <- cachePath name currentSystem

    -- Check cache first (skip for latest)
    cached <-
      if useCache
        then lookupVersion versionStr <$> readCache cpath
        else pure Nothing

    case cached of
      Just response -> do
        verboseLog verbose $ "cache hit: " <> nixFlakeRef (buildNixRunCommand response [])
        execVerbose verbose response passthrough
      Nothing -> do
        verboseLog verbose $ "GET " <> apiUrl
        result <- resolveVersion name versionStr currentSystem
        case result of
          Right response -> do
            verboseLog verbose $ "resolved: " <> nixFlakeRef (buildNixRunCommand response [])
            if useCache
              then cacheAndExec verbose cpath versionStr response passthrough
              else execVerbose verbose response passthrough
          Left VersionNotFound ->
            handleVersionNotFound useCache cpath name versionStr
          Left (ApiError err) ->
            die $ "resolve failed: " <> T.unpack err

  execVerbose verbose response passthrough = do
    let cmd = buildNixRunCommand response passthrough
    verboseLog verbose $ "exec: " <> renderCommand cmd
    execNixRun cmd

  cacheAndExec verbose cpath ver response passthrough = do
    cache <- readCache cpath
    writeCache cpath (addVersion ver response cache)
    execVerbose verbose response passthrough

  handleVersionNotFound useCache cpath name ver = do
    cache <- if useCache then readCache cpath else pure emptyCache
    case availableVersions cache of
      Just vs | not (null (findNeighbors ver vs)) ->
        die $ T.unpack $ formatSuggestion name ver (findNeighbors ver vs)
      _ -> do
        versionsResult <- fetchVersions name
        case versionsResult of
          Left err -> die $ T.unpack err
          Right vs -> do
            now <- getCurrentTime
            writeCache cpath (setAvailableVersions vs now cache)
            let neighbors = findNeighbors ver vs
            die $ T.unpack $ formatSuggestion name ver neighbors

  verboseLog verbose msg =
    if verbose then hPutStrLn stderr (T.unpack msg) else pure ()

  die msg = hPutStrLn stderr msg >> exitFailure
