module Vx.Api
  ( NixhubResponse (..)
  , ResolveError (..)
  , parseNixhubResponse
  , parseVersionList
  , resolveVersion
  , fetchVersions
  ) where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import Data.ByteString.Lazy (ByteString)
import Data.Text (Text)
import qualified Data.Text as T
import Network.HTTP.Client
  ( httpLbs
  , newManager
  , parseRequest
  , responseBody
  , responseStatus
  )
import Network.HTTP.Client.TLS (tlsManagerSettings)
import Network.HTTP.Types.Status (statusCode)

data NixhubResponse = NixhubResponse
  { rev :: Text
  , attrPath :: Text
  }
  deriving (Show, Eq)

data ResolveError
  = VersionNotFound
  | ApiError Text
  deriving (Show, Eq)

-- | Parse a Nixhub /v2/resolve JSON response, extracting rev and attr_path
-- for the given system (e.g., "x86_64-linux").
parseNixhubResponse :: ByteString -> Text -> Either Text NixhubResponse
parseNixhubResponse body system =
  case Aeson.eitherDecode body of
    Left err -> Left $ "JSON parse error: " <> T.pack err
    Right val -> extractSystem val system

extractSystem :: Aeson.Value -> Text -> Either Text NixhubResponse
extractSystem (Aeson.Object top) system = do
  systems <- lookupKey "systems" top
  systemObj <- case systems of
    Aeson.Object m -> case KeyMap.lookup (Key.fromText system) m of
      Nothing -> Left $ "system '" <> system <> "' not found in response"
      Just v -> Right v
    _ -> Left "'systems' is not an object"
  extractFlakeInstallable systemObj
extractSystem _ _ = Left "response is not a JSON object"

extractFlakeInstallable :: Aeson.Value -> Either Text NixhubResponse
extractFlakeInstallable (Aeson.Object sysObj) = do
  fi <- lookupKey "flake_installable" sysObj
  case fi of
    Aeson.Object fiObj -> do
      refVal <- lookupKey "ref" fiObj
      case refVal of
        Aeson.Object refObj -> do
          r <- lookupText "rev" refObj
          ap <- lookupText "attr_path" fiObj
          Right NixhubResponse{rev = r, attrPath = ap}
        _ -> Left "'ref' is not an object"
    _ -> Left "'flake_installable' is not an object"
extractFlakeInstallable _ = Left "system entry is not an object"

-- | Parse a Nixhub /v2/pkg JSON response, extracting the list of version strings.
parseVersionList :: ByteString -> Either Text [Text]
parseVersionList body =
  case Aeson.eitherDecode body of
    Left err -> Left $ "JSON parse error: " <> T.pack err
    Right (Aeson.Object top) ->
      case KeyMap.lookup "releases" top of
        Nothing -> Left "response missing 'releases' field"
        Just (Aeson.Array releases) ->
          Right [v | Aeson.Object rel <- toList releases, Just (Aeson.String v) <- [KeyMap.lookup "version" rel]]
        Just _ -> Left "'releases' is not an array"
    Right _ -> Left "response is not a JSON object"
 where
  toList = foldr (:) []

lookupKey :: Text -> KeyMap.KeyMap Aeson.Value -> Either Text Aeson.Value
lookupKey k m = case KeyMap.lookup (Key.fromText k) m of
  Nothing -> Left $ "missing field '" <> k <> "'"
  Just v -> Right v

lookupText :: Text -> KeyMap.KeyMap Aeson.Value -> Either Text Text
lookupText k m = case KeyMap.lookup (Key.fromText k) m of
  Nothing -> Left $ "missing field '" <> k <> "'"
  Just (Aeson.String t) -> Right t
  Just _ -> Left $ "field '" <> k <> "' is not a string"

-- | Resolve a package name and version to a nixpkgs commit via the Nixhub API.
resolveVersion :: Text -> Text -> Text -> IO (Either ResolveError NixhubResponse)
resolveVersion name version system = do
  manager <- newManager tlsManagerSettings
  let url =
        "https://search.devbox.sh/v2/resolve?name="
          <> T.unpack name
          <> "&version="
          <> T.unpack version
  request <- parseRequest url
  response <- httpLbs request manager
  let status = statusCode (responseStatus response)
  pure $ case status of
    200 -> case parseNixhubResponse (responseBody response) system of
      Left err -> Left $ ApiError err
      Right r -> Right r
    404 -> Left VersionNotFound
    _ -> Left $ ApiError $ "API returned status " <> T.pack (show status)

-- | Fetch the list of available versions for a package.
fetchVersions :: Text -> IO (Either Text [Text])
fetchVersions name = do
  manager <- newManager tlsManagerSettings
  let url = "https://search.devbox.sh/v2/pkg?name=" <> T.unpack name
  request <- parseRequest url
  response <- httpLbs request manager
  let status = statusCode (responseStatus response)
  pure $ case status of
    200 -> parseVersionList (responseBody response)
    404 -> Left $ "package '" <> name <> "' not found"
    _ -> Left $ "API returned status " <> T.pack (show status)
