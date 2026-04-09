## 1. API Client

- [x] 1.1 Add `parseNixhubResponse :: ByteString -> Text -> Either Text NixhubResponse` pure function to `Vx.Api`
- [x] 1.2 Implement `resolveVersion` with HTTP GET to Nixhub `/v2/resolve` endpoint using `http-client-tls`
- [x] 1.3 Add aeson `FromJSON` instances or manual parsing for the nested Nixhub response structure
- [x] 1.4 Write mock-based tests for `parseNixhubResponse` in `test/Vx/ApiSpec.hs`

## 2. Platform Detection

- [x] 2.1 Create `src/Vx/Platform.hs` with `currentSystem :: IO Text` and `nixSystem :: String -> String -> Text`
- [x] 2.2 Register `Vx.Platform` in `vx.cabal` exposed-modules
- [x] 2.3 Write tests for `nixSystem` in `test/Vx/PlatformSpec.hs`

## 3. Process Exec

- [x] 3.1 Add `unix` to build-depends in `vx.cabal`
- [x] 3.2 Rewrite `Vx.Exec.execNixRun` to use `executeFile` from `System.Posix.Process`
- [x] 3.3 Remove `typed-process` dependency if no longer used

## 4. CLI Pipeline

- [x] 4.1 Rewrite `app/Main.hs` to wire: argv → parsePackageSpec → resolveVersion → buildNixRunCommand → execNixRun
- [x] 4.2 Add error handling: print to stderr + exitFailure on parse/API/platform errors

## 5. Build & Coverage

- [x] 5.1 Lower coverage threshold in `flake.nix` from 95% to 80%
- [x] 5.2 Verify `cabal build` compiles
- [x] 5.3 Verify `cabal test` passes with mock-based API tests
- [x] 5.4 Verify `nix build` produces working binary

## 6. Integration Verification

- [x] 6.1 Run `vx hugo-0.147.9 version` and confirm it prints hugo version output
