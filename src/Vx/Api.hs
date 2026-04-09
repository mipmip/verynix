module Vx.Api
  ( NixhubResponse (..)
  , resolveVersion
  ) where

import Data.Text (Text)

data NixhubResponse = NixhubResponse
  { rev :: Text
  , attrPath :: Text
  }
  deriving (Show, Eq)

-- | Resolve a package name and version to a nixpkgs commit via the Nixhub API.
resolveVersion :: Text -> Text -> IO (Either Text NixhubResponse)
resolveVersion _name _version =
  pure $ Left "not yet implemented"
