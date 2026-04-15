{
  description = "vx: Very niX — run any version of any Nix package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs:
        let
          haskellPackages = pkgs.haskell.packages.ghc98;
          vx = haskellPackages.callCabal2nix "vx" ./. { };
          vxWithCoverage = pkgs.haskell.lib.overrideCabal vx (old: {
            doCoverage = true;
            postCheck = (old.postCheck or "") + ''
              echo "=== HPC Coverage Report ==="

              # Find all mix directories (library + test suite)
              tix=$(find dist -name "vx-test.tix" -print -quit 2>/dev/null)
              hpcdirs=""
              for d in $(find dist/hpc/vanilla/mix -mindepth 1 -maxdepth 1 -type d 2>/dev/null); do
                hpcdirs="$hpcdirs --hpcdir=$d"
              done

              if [ -n "$tix" ] && [ -n "$hpcdirs" ]; then
                # Report only library modules (exclude test specs and Main)
                hpc report "$tix" $hpcdirs \
                  --exclude=Main \
                  --exclude=Vx.ParseSpec \
                  --exclude=Vx.ApiSpec \
                  --exclude=Vx.ResolveSpec \
                  --exclude=Vx.ExecSpec \
                  --exclude=Spec

                # Extract expression coverage percentage
                pct=$(hpc report "$tix" $hpcdirs \
                  --exclude=Main \
                  --exclude=Vx.ParseSpec \
                  --exclude=Vx.ApiSpec \
                  --exclude=Vx.ResolveSpec \
                  --exclude=Vx.ExecSpec \
                  --exclude=Spec \
                  2>/dev/null \
                  | grep -oP '(\d+)% expressions used' \
                  | grep -oP '\d+' || echo "0")

                # Generate HTML coverage report
                mkdir -p $out/share/hpc
                hpc markup "$tix" $hpcdirs \
                  --exclude=Main \
                  --exclude=Vx.ParseSpec \
                  --exclude=Vx.ApiSpec \
                  --exclude=Vx.ResolveSpec \
                  --exclude=Vx.ExecSpec \
                  --exclude=Spec \
                  --destdir=$out/share/hpc \
                  2>/dev/null || true
                echo "HTML coverage report: $out/share/hpc/hpc_index.html"

                echo "==========================="
                if [ -n "$pct" ] && [ "$pct" -lt 80 ]; then
                  echo "FAIL: Coverage is ''${pct}%, minimum is 80%"
                  exit 1
                else
                  echo "PASS: Coverage is ''${pct}%"
                fi
              else
                echo "WARNING: Could not find tix/mix files, skipping coverage check"
                echo "tix=$tix hpcdirs=$hpcdirs"
              fi
            '';
          });
        in {
          default = vx;
          coverage = vxWithCoverage;
        });

      devShells = forAllSystems (pkgs:
        let
          haskellPackages = pkgs.haskell.packages.ghc98;
          vx = haskellPackages.callCabal2nix "vx" ./. { };
        in {
          default = haskellPackages.shellFor {
            packages = _: [ vx ];
            nativeBuildInputs = [
              haskellPackages.cabal-install
              haskellPackages.haskell-language-server
              pkgs.ormolu
              pkgs.hlint
            ];
          };
        });
    };
}
