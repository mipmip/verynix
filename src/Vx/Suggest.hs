module Vx.Suggest
  ( parseVersion
  , findNeighbors
  , formatSuggestion
  ) where

import Data.List (sortBy)
import Data.Ord (comparing)
import Data.Text (Text)
import qualified Data.Text as T
import Text.Read (readMaybe)

-- | Parse a version string into comparable components.
-- Each dot-separated segment is parsed as an Int if possible.
-- Non-numeric segments are represented as -1 (sorting before numeric ones).
parseVersion :: Text -> [Int]
parseVersion = map parseSegment . T.splitOn "."
 where
  parseSegment s = case readMaybe (T.unpack s) of
    Just n -> n
    Nothing -> -1

-- | Find the nearest version below and above a target in a list of versions.
findNeighbors :: Text -> [Text] -> (Maybe Text, Maybe Text)
findNeighbors target versions =
  let targetParsed = parseVersion target
      sorted = sortBy (comparing parseVersion) versions
      lower = [v | v <- sorted, parseVersion v < targetParsed]
      upper = [v | v <- sorted, parseVersion v > targetParsed]
   in (lastMay lower, headMay upper)

headMay :: [a] -> Maybe a
headMay [] = Nothing
headMay (x : _) = Just x

lastMay :: [a] -> Maybe a
lastMay [] = Nothing
lastMay xs = Just (last xs)

-- | Format a suggestion message for a version that was not found.
formatSuggestion :: Text -> Text -> (Maybe Text, Maybe Text) -> Text
formatSuggestion name version (lower, upper) =
  "version " <> version <> " of " <> name <> " not found"
    <> case (lower, upper) of
      (Nothing, Nothing) -> ""
      (Just l, Nothing) ->
        "\n\nnearest available version:\n  < " <> l
      (Nothing, Just u) ->
        "\n\nnearest available version:\n  > " <> u
      (Just l, Just u) ->
        "\n\nnearest available versions:\n  < " <> l <> "\n  > " <> u
