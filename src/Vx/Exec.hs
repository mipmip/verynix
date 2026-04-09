module Vx.Exec
  ( execNixRun
  ) where

import qualified Data.Text as T
import System.Posix.Process (executeFile)
import Vx.Resolve (NixRunCommand (..))

-- | Execute a nix run command, replacing the current process.
-- This never returns on success.
execNixRun :: NixRunCommand -> IO ()
execNixRun cmd = do
  let args = ["run", T.unpack (nixFlakeRef cmd), "--"] ++ map T.unpack (nixArgs cmd)
  executeFile "nix" True args Nothing
