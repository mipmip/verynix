module Vx.Exec
  ( execNixRun
  ) where

import qualified Data.Text as T
import System.Process.Typed (proc, runProcess_)
import Vx.Resolve (NixRunCommand (..))

-- | Execute a nix run command, replacing the current process.
execNixRun :: NixRunCommand -> IO ()
execNixRun cmd = do
  let args = ["run", T.unpack (nixFlakeRef cmd), "--"] ++ map T.unpack (nixArgs cmd)
  runProcess_ (proc "nix" args)
