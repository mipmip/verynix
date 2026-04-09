module Vx.Api
  ( NixhubResponse (..)
  , parseNixhubResponse
  , resolveVersion
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
import Network.HTTP.Types.Status (statusCode)
import Network.HTTP.Client.TLS (tlsManagerSettings)

data NixhubResponse = NixhubResponse
  { rev :: Text
  , attrPath :: Text
  }
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
resolveVersion :: Text -> Text -> Text -> IO (Either Text NixhubResponse)
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
  if status /= 200
    then pure $ Left $ "API returned status " <> T.pack (show status)
    else pure $ parseNixhubResponse (responseBody response) system
