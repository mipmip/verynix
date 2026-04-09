module Vx.PlatformSpec (spec) where

import Test.Hspec
import Vx.Platform

spec :: Spec
spec = describe "Vx.Platform" $ do
  describe "nixSystem" $ do
    it "combines arch and os with hyphen" $ do
      nixSystem "x86_64" "linux" `shouldBe` "x86_64-linux"

    it "handles aarch64-darwin" $ do
      nixSystem "aarch64" "darwin" `shouldBe` "aarch64-darwin"

    it "handles aarch64-linux" $ do
      nixSystem "aarch64" "linux" `shouldBe` "aarch64-linux"

    it "handles x86_64-darwin" $ do
      nixSystem "x86_64" "darwin" `shouldBe` "x86_64-darwin"

  describe "currentSystem" $ do
    it "returns a non-empty string" $ do
      currentSystem `shouldSatisfy` (/= "")
