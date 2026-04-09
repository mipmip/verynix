module Vx.ResolveSpec (spec) where

import Test.Hspec
import Vx.Api (NixhubResponse (..))
import Vx.Resolve

spec :: Spec
spec = describe "Vx.Resolve" $ do
  describe "buildNixRunCommand" $ do
    it "builds correct flake reference" $ do
      let response = NixhubResponse {rev = "abc123", attrPath = "hugo"}
          cmd = buildNixRunCommand response ["serve"]
      nixFlakeRef cmd `shouldBe` "github:NixOS/nixpkgs/abc123#hugo"

    it "passes through arguments" $ do
      let response = NixhubResponse {rev = "abc123", attrPath = "hugo"}
          cmd = buildNixRunCommand response ["serve", "--port", "8080"]
      nixArgs cmd `shouldBe` ["serve", "--port", "8080"]

    it "handles empty arguments" $ do
      let response = NixhubResponse {rev = "abc123", attrPath = "hugo"}
          cmd = buildNixRunCommand response []
      nixArgs cmd `shouldBe` []
