module Vx.ApiSpec (spec) where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.KeyMap as KeyMap
import Test.Hspec
import Vx.Api

-- | Canned JSON matching the real Nixhub /v2/resolve response structure.
validResponse :: Aeson.Value
validResponse =
  Aeson.Object $
    KeyMap.fromList
      [ ("name", Aeson.String "hugo")
      , ("version", Aeson.String "0.147.9")
      ,
        ( "systems"
        , Aeson.Object $
            KeyMap.fromList
              [
                ( "x86_64-linux"
                , Aeson.Object $
                    KeyMap.fromList
                      [
                        ( "flake_installable"
                        , Aeson.Object $
                            KeyMap.fromList
                              [
                                ( "ref"
                                , Aeson.Object $
                                    KeyMap.fromList
                                      [("rev", Aeson.String "992f9165")]
                                )
                              , ("attr_path", Aeson.String "hugo")
                              ]
                        )
                      ]
                )
              ,
                ( "aarch64-darwin"
                , Aeson.Object $
                    KeyMap.fromList
                      [
                        ( "flake_installable"
                        , Aeson.Object $
                            KeyMap.fromList
                              [
                                ( "ref"
                                , Aeson.Object $
                                    KeyMap.fromList
                                      [("rev", Aeson.String "abc12345")]
                                )
                              , ("attr_path", Aeson.String "hugo")
                              ]
                        )
                      ]
                )
              ]
        )
      ]

spec :: Spec
spec = describe "Vx.Api" $ do
  describe "parseNixhubResponse" $ do
    let encode = Aeson.encode

    it "extracts rev and attrPath for a valid system" $ do
      parseNixhubResponse (encode validResponse) "x86_64-linux"
        `shouldBe` Right NixhubResponse{rev = "992f9165", attrPath = "hugo"}

    it "extracts correct data for a different system" $ do
      parseNixhubResponse (encode validResponse) "aarch64-darwin"
        `shouldBe` Right NixhubResponse{rev = "abc12345", attrPath = "hugo"}

    it "returns Left when system is not in response" $ do
      parseNixhubResponse (encode validResponse) "x86_64-darwin"
        `shouldBe` Left "system 'x86_64-darwin' not found in response"

    it "returns Left on malformed JSON" $ do
      let result = parseNixhubResponse "not json" "x86_64-linux"
      result `shouldSatisfy` isLeft

    it "returns Left when systems field is missing" $ do
      let noSystems = Aeson.encode $ Aeson.Object $ KeyMap.fromList [("name", Aeson.String "hugo")]
      parseNixhubResponse noSystems "x86_64-linux"
        `shouldBe` Left "missing field 'systems'"

isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft _ = False
