module Vx.SuggestSpec (spec) where

import Test.Hspec
import Vx.Suggest

spec :: Spec
spec = describe "Vx.Suggest" $ do
  describe "parseVersion" $ do
    it "parses standard semver" $ do
      parseVersion "1.2.3" `shouldBe` [1, 2, 3]

    it "parses two-component version" $ do
      parseVersion "1.2" `shouldBe` [1, 2]

    it "parses single-component version" $ do
      parseVersion "42" `shouldBe` [42]

    it "handles non-numeric segments with -1" $ do
      parseVersion "1.0.0-rc1" `shouldBe` [1, 0, -1]

  describe "findNeighbors" $ do
    let versions = ["0.145.0", "0.147.9", "0.148.6", "0.150.0", "0.151.1"]

    it "finds lower and upper neighbor" $ do
      findNeighbors "0.149.1" versions `shouldBe` (Just "0.148.6", Just "0.150.0")

    it "returns Nothing for lower when target is below all" $ do
      findNeighbors "0.100.0" versions `shouldBe` (Nothing, Just "0.145.0")

    it "returns Nothing for upper when target is above all" $ do
      findNeighbors "0.200.0" versions `shouldBe` (Just "0.151.1", Nothing)

    it "returns adjacent versions when target matches exactly" $ do
      findNeighbors "0.148.6" versions `shouldBe` (Just "0.147.9", Just "0.150.0")

    it "handles single version list" $ do
      findNeighbors "1.0.0" ["2.0.0"] `shouldBe` (Nothing, Just "2.0.0")

    it "handles empty version list" $ do
      findNeighbors "1.0.0" [] `shouldBe` (Nothing, Nothing)

  describe "formatSuggestion" $ do
    it "formats both neighbors" $ do
      formatSuggestion "hugo" "0.149.1" (Just "0.148.6", Just "0.150.0")
        `shouldBe` "version 0.149.1 of hugo not found\n\nnearest available versions:\n  < 0.148.6\n  > 0.150.0"

    it "formats only lower neighbor" $ do
      formatSuggestion "hugo" "0.200.0" (Just "0.151.1", Nothing)
        `shouldBe` "version 0.200.0 of hugo not found\n\nnearest available version:\n  < 0.151.1"

    it "formats only upper neighbor" $ do
      formatSuggestion "hugo" "0.100.0" (Nothing, Just "0.145.0")
        `shouldBe` "version 0.100.0 of hugo not found\n\nnearest available version:\n  > 0.145.0"

    it "formats no neighbors" $ do
      formatSuggestion "hugo" "1.0.0" (Nothing, Nothing)
        `shouldBe` "version 1.0.0 of hugo not found"
