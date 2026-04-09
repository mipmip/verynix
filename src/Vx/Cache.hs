module Vx.Cache
  ( PackageCache (..)
  , emptyCache
  , lookupVersion
  , addVersion
  , setAvailableVersions
  , readCache
  , writeCache
  , cachePath
  ) where

import qualified Data.Aeson as Aeson
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime)
import System.Directory
  ( XdgDirectory (XdgCache)
  , createDirectoryIfMissing
  , doesFileExist
  , getXdgDirectory
  , renameFile
  )
import System.IO (hClose, openTempFile)
import qualified Data.ByteString.Lazy as LBS
import Vx.Api (NixhubResponse (..))

data PackageCache = PackageCache
  { versions :: Map Text CachedResponse
  , availableVersions :: Maybe [Text]
  , availableVersionsFetchedAt :: Maybe UTCTime
  }
  deriving (Show, Eq)

data CachedResponse = CachedResponse
  { cachedRev :: Text
  , cachedAttrPath :: Text
  }
  deriving (Show, Eq)

emptyCache :: PackageCache
emptyCache = PackageCache Map.empty Nothing Nothing

lookupVersion :: Text -> PackageCache -> Maybe NixhubResponse
lookupVersion ver pc = do
  cr <- Map.lookup ver (versions pc)
  pure NixhubResponse{rev = cachedRev cr, attrPath = cachedAttrPath cr}

addVersion :: Text -> NixhubResponse -> PackageCache -> PackageCache
addVersion ver resp pc =
  pc{versions = Map.insert ver (CachedResponse (rev resp) (attrPath resp)) (versions pc)}

setAvailableVersions :: [Text] -> UTCTime -> PackageCache -> PackageCache
setAvailableVersions vs t pc =
  pc{availableVersions = Just vs, availableVersionsFetchedAt = Just t}

-- JSON instances

instance Aeson.ToJSON CachedResponse where
  toJSON cr = Aeson.object
    [ "rev" Aeson..= cachedRev cr
    , "attrPath" Aeson..= cachedAttrPath cr
    ]

instance Aeson.FromJSON CachedResponse where
  parseJSON = Aeson.withObject "CachedResponse" $ \o ->
    CachedResponse <$> o Aeson..: "rev" <*> o Aeson..: "attrPath"

instance Aeson.ToJSON PackageCache where
  toJSON pc = Aeson.object $
    [ "versions" Aeson..= versions pc ]
    ++ maybe [] (\vs -> ["availableVersions" Aeson..= vs]) (availableVersions pc)
    ++ maybe [] (\t -> ["availableVersionsFetchedAt" Aeson..= t]) (availableVersionsFetchedAt pc)

instance Aeson.FromJSON PackageCache where
  parseJSON = Aeson.withObject "PackageCache" $ \o ->
    PackageCache
      <$> o Aeson..:? "versions" Aeson..!= Map.empty
      <*> o Aeson..:? "availableVersions"
      <*> o Aeson..:? "availableVersionsFetchedAt"

-- IO operations

cachePath :: Text -> Text -> IO FilePath
cachePath name system = do
  dir <- getXdgDirectory XdgCache "vx"
  pure $ dir <> "/" <> T.unpack name <> "-" <> T.unpack system <> ".json"

readCache :: FilePath -> IO PackageCache
readCache path = do
  exists <- doesFileExist path
  if not exists
    then pure emptyCache
    else do
      contents <- LBS.readFile path
      pure $ case Aeson.eitherDecode contents of
        Right pc -> pc
        Left _ -> emptyCache

writeCache :: FilePath -> PackageCache -> IO ()
writeCache path pc = do
  let dir = reverse $ dropWhile (/= '/') $ reverse path
  createDirectoryIfMissing True dir
  (tmpPath, h) <- openTempFile dir "vx-cache.tmp"
  LBS.hPut h (Aeson.encode pc)
  hClose h
  renameFile tmpPath path
