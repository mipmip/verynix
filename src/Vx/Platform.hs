module Vx.Platform
  ( currentSystem
  , nixSystem
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import System.Info (arch, os)

-- | Build a Nix system string from arch and os components.
nixSystem :: String -> String -> Text
nixSystem a o = T.pack a <> "-" <> T.pack o

-- | Detect the current Nix system string at runtime.
currentSystem :: Text
currentSystem = nixSystem arch os
