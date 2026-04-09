module Vx.ExecSpec (spec) where

import Test.Hspec
import Vx.Exec ()

spec :: Spec
spec = describe "Vx.Exec" $ do
  describe "execNixRun" $ do
    it "is tested via integration tests" $
      pending
