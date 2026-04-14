module Vx.ParseSpec (spec) where

import Test.Hspec
import Test.Hspec.QuickCheck ()
import Vx.Parse

spec :: Spec
spec = describe "Vx.Parse" $ do
  describe "parsePackageSpec" $ do
    it "parses a valid package-version string" $
      parsePackageSpec "hugo-0.154.3"
        `shouldBe` Just (PackageSpec "hugo" (Just "0.154.3"))

    it "handles package names with hyphens" $
      parsePackageSpec "my-cool-pkg-1.0.0"
        `shouldBe` Just (PackageSpec "my-cool-pkg" (Just "1.0.0"))

    it "parses name-only as latest" $
      parsePackageSpec "hugo"
        `shouldBe` Just (PackageSpec "hugo" Nothing)

    it "parses name-latest as latest" $
      parsePackageSpec "hugo-latest"
        `shouldBe` Just (PackageSpec "hugo" Nothing)

    it "parses hyphenated name without version as latest" $
      parsePackageSpec "hugo-beta"
        `shouldBe` Just (PackageSpec "hugo-beta" Nothing)

    it "returns Nothing for empty input" $
      parsePackageSpec "" `shouldBe` Nothing
