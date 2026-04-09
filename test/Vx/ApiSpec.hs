module Vx.ApiSpec (spec) where

import Test.Hspec
import Vx.Api

spec :: Spec
spec = describe "Vx.Api" $ do
  describe "resolveVersion" $ do
    it "returns stub error for now" $ do
      result <- resolveVersion "hugo" "0.154.3"
      result `shouldBe` Left "not yet implemented"
