module Vx.Resolve
  ( NixRunCommand (..)
  , buildNixRunCommand
  , renderCommand
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import Vx.Api (NixhubResponse (..))

data NixRunCommand = NixRunCommand
  { nixFlakeRef :: Text
  , nixArgs :: [Text]
  }
  deriving (Show, Eq)

-- | Build a nix run command from a resolved Nixhub response and extra arguments.
buildNixRunCommand :: NixhubResponse -> [Text] -> NixRunCommand
buildNixRunCommand response args =
  NixRunCommand
    { nixFlakeRef =
        "github:NixOS/nixpkgs/"
          <> rev response
          <> "#"
          <> attrPath response
    , nixArgs = args
    }

-- | Render the full command as a string for display.
renderCommand :: NixRunCommand -> Text
renderCommand cmd =
  T.unwords $
    ["nix", "run", nixFlakeRef cmd, "--"]
      ++ nixArgs cmd
