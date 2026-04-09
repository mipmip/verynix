module Vx.CacheSpec (spec) where

import Data.Time.Clock (UTCTime (..))
import Data.Time.Calendar (fromGregorian)
import System.Directory (getTemporaryDirectory, removeFile)
import System.IO (hClose, openTempFile)
import Test.Hspec
import Vx.Api (NixhubResponse (..))
import Vx.Cache

sampleResponse :: NixhubResponse
sampleResponse = NixhubResponse{rev = "992f9165", attrPath = "hugo"}

sampleTime :: UTCTime
sampleTime = UTCTime (fromGregorian 2026 4 9) 0

spec :: Spec
spec = describe "Vx.Cache" $ do
  describe "pure functions" $ do
    it "emptyCache has no versions" $ do
      lookupVersion "1.0" emptyCache `shouldBe` Nothing

    it "addVersion makes version retrievable" $ do
      let cache = addVersion "0.139.0" sampleResponse emptyCache
      lookupVersion "0.139.0" cache `shouldBe` Just sampleResponse

    it "addVersion preserves existing versions" $ do
      let other = NixhubResponse{rev = "abc12345", attrPath = "hugo"}
          cache = addVersion "0.138.0" other $ addVersion "0.139.0" sampleResponse emptyCache
      lookupVersion "0.139.0" cache `shouldBe` Just sampleResponse
      lookupVersion "0.138.0" cache `shouldBe` Just other

    it "lookupVersion returns Nothing for missing version" $ do
      let cache = addVersion "0.139.0" sampleResponse emptyCache
      lookupVersion "0.140.0" cache `shouldBe` Nothing

    it "setAvailableVersions stores version list" $ do
      let cache = setAvailableVersions ["0.139.0", "0.138.0"] sampleTime emptyCache
      availableVersions cache `shouldBe` Just ["0.139.0", "0.138.0"]
      availableVersionsFetchedAt cache `shouldBe` Just sampleTime

  describe "IO roundtrip" $ do
    it "writeCache then readCache preserves data" $ do
      tmpDir <- getTemporaryDirectory
      (tmpPath, h) <- openTempFile tmpDir "vx-cache-test.json"
      hClose h
      let cache = setAvailableVersions ["0.139.0"] sampleTime
                    $ addVersion "0.139.0" sampleResponse emptyCache
      writeCache tmpPath cache
      loaded <- readCache tmpPath
      lookupVersion "0.139.0" loaded `shouldBe` Just sampleResponse
      availableVersions loaded `shouldBe` Just ["0.139.0"]
      removeFile tmpPath

    it "readCache returns emptyCache for missing file" $ do
      loaded <- readCache "/tmp/vx-cache-nonexistent-file-12345.json"
      loaded `shouldBe` emptyCache

    it "readCache returns emptyCache for corrupted JSON" $ do
      tmpDir <- getTemporaryDirectory
      (tmpPath, h) <- openTempFile tmpDir "vx-cache-test.json"
      hClose h
      writeFile tmpPath "not valid json {{"
      loaded <- readCache tmpPath
      loaded `shouldBe` emptyCache
      removeFile tmpPath

    it "readCache returns emptyCache for empty file" $ do
      tmpDir <- getTemporaryDirectory
      (tmpPath, h) <- openTempFile tmpDir "vx-cache-test.json"
      hClose h
      writeFile tmpPath ""
      loaded <- readCache tmpPath
      loaded `shouldBe` emptyCache
      removeFile tmpPath
