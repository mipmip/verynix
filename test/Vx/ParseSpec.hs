module Vx.ParseSpec (spec) where

import Test.Hspec
import Test.Hspec.QuickCheck ()
import Vx.Parse

spec :: Spec
spec = describe "Vx.Parse" $ do
  describe "parsePackageSpec" $ do
    it "parses a valid package-version string" $
      parsePackageSpec "hugo-0.154.3"
        `shouldBe` Just (PackageSpec "hugo" "0.154.3")

    it "handles package names with hyphens" $
      parsePackageSpec "my-cool-pkg-1.0.0"
        `shouldBe` Just (PackageSpec "my-cool-pkg" "1.0.0")

    it "returns Nothing for input without a version" $
      parsePackageSpec "hugo" `shouldBe` Nothing

    it "returns Nothing for empty input" $
      parsePackageSpec "" `shouldBe` Nothing

    it "returns Nothing when version part doesn't start with a digit" $
      parsePackageSpec "hugo-beta" `shouldBe` Nothing
