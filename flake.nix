{
  outputs = { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs.lib) getExe pipe readFile toLower trim;
        inherit (pkgs.lib.fileset) toSource unions;

        py = pkgs.python3.pkgs;
        proj = pipe ./pyproject.toml [ readFile fromTOML (x: x.project) ];
        repo = pipe ./repo.txt [ readFile trim toLower ];
      in
      rec {
        packages = rec {
          default = py.buildPythonApplication rec {
            pname = proj.name;
            inherit (proj) version;

            src = toSource {
              root = ./.;
              fileset = unions [
                ./main.py
                ./pyproject.toml
              ];
            };

            pyproject = true;

            build-system = with py; [
              setuptools
            ];

            dependencies = with py; [
              requests
            ];

            meta.mainProgram = pname;
          };

          image = pkgs.dockerTools.buildImage {
            name = "ghcr.io/${repo}";
            tag = proj.version;

            config = {
              Cmd = [ (getExe default) ];
              Labels = {
                "org.opencontainers.image.source" = "https://github.com/${repo}";
                "org.opencontainers.image.description" = "testing image";
                "org.opencontainers.image.licenses" = "GPL-3.0-or-later";
              };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];

          packages = with pkgs; [
            dive
            dprint
          ];
        };
      });
}
