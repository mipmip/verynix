module Main (main) where

import qualified Data.Text as T
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Vx.Api (resolveVersion)
import Vx.Exec (execNixRun)
import Vx.Parse (PackageSpec (..), parsePackageSpec)
import Vx.Platform (currentSystem)
import Vx.Resolve (buildNixRunCommand)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> die "usage: vx <package>-<version> [args...]"
    (spec : rest) ->
      case parsePackageSpec (T.pack spec) of
        Nothing -> die $ "could not parse package spec: " <> spec
        Just pkg -> run pkg (map T.pack rest)
 where
  run pkg passthrough = do
    result <- resolveVersion (packageName pkg) (packageVersion pkg) currentSystem
    case result of
      Left err -> die $ "resolve failed: " <> T.unpack err
      Right response -> execNixRun (buildNixRunCommand response passthrough)

  die msg = hPutStrLn stderr msg >> exitFailure
