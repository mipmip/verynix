module Vx.Parse
  ( PackageSpec (..)
  , parsePackageSpec
  ) where

import Data.Text (Text)
import qualified Data.Text as T

data PackageSpec = PackageSpec
  { packageName :: Text
  , packageVersion :: Text
  }
  deriving (Show, Eq)

-- | Parse a "package-version" string into a PackageSpec.
-- The version is everything after the last hyphen that starts with a digit.
parsePackageSpec :: Text -> Maybe PackageSpec
parsePackageSpec input =
  case T.breakOnEnd "-" input of
    ("", _) -> Nothing
    (_, "") -> Nothing
    (nameWithDash, version)
      | T.null version -> Nothing
      | isVersionChar (T.head version) ->
          Just
            PackageSpec
              { packageName = T.dropEnd 1 nameWithDash
              , packageVersion = version
              }
      | otherwise -> Nothing
  where
    isVersionChar c = c >= '0' && c <= '9'
