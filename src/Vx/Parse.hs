module Vx.Parse
  ( PackageSpec (..)
  , parsePackageSpec
  , splitArgs
  ) where

import Data.Text (Text)
import qualified Data.Text as T

data PackageSpec = PackageSpec
  { packageName :: Text
  , packageVersion :: Maybe Text
  }
  deriving (Show, Eq)

-- | Parse a package spec string into a PackageSpec.
-- "hugo-0.154.3"  → PackageSpec "hugo" (Just "0.154.3")
-- "hugo-latest"   → PackageSpec "hugo" Nothing
-- "hugo"          → PackageSpec "hugo" Nothing
parsePackageSpec :: Text -> Maybe PackageSpec
parsePackageSpec input
  | T.null input = Nothing
  | otherwise =
      case T.breakOnEnd "-" input of
        ("", _) ->
          -- No hyphen: name only, latest
          Just PackageSpec{packageName = input, packageVersion = Nothing}
        (_, "") -> Nothing
        (nameWithDash, version)
          | version == "latest" ->
              Just PackageSpec{packageName = T.dropEnd 1 nameWithDash, packageVersion = Nothing}
          | isVersionChar (T.head version) ->
              Just PackageSpec{packageName = T.dropEnd 1 nameWithDash, packageVersion = Just version}
          | otherwise ->
              -- No valid version after last hyphen: treat entire input as name
              Just PackageSpec{packageName = input, packageVersion = Nothing}
 where
  isVersionChar c = c >= '0' && c <= '9'

-- | Split argv into vx flags (before first non-flag arg) and the rest.
-- A non-flag arg is one that doesn't start with '-'.
splitArgs :: [String] -> ([String], [String])
splitArgs [] = ([], [])
splitArgs (a : as)
  | '-' : _ <- a = let (flags, rest) = splitArgs as in (a : flags, rest)
  | otherwise = ([], a : as)
