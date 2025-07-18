{
  description = "Template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };


  outputs =
    {
      nixpkgs,
      flake-utils,
      pyproject-nix,
      uv2nix,
      pyproject-build-systems,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Define the python version we wish to use
        python = pkgs.python312;

        # Use pkgs for this "system"
	pkgs = import nixpkgs {
	  inherit system;
	};
        inherit (pkgs) lib;

        # Load a uv workspace from a workspace root.
        workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

        # Create package overlay from workspace preferring wheels over sdist.
        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };

        # Use base package set from pyproject.nix builders.
        baseSet = pkgs.callPackage pyproject-nix.build.packages {
          inherit python;
        };

        # Construct a final package set from composing base + overlays
        pythonSet = baseSet.overrideScope (
          pkgs.lib.composeManyExtensions [
            pyproject-build-systems.overlays.default
            overlay
            (final: prev: {
              pyarrow = prev.pyarrow.overrideAttrs (old: {
                buildInputs = (old.buildInputs or []) ++ [
                  pkgs.arrow-cpp
                ];
                propagatedBuildInputs = (old.propagatedBuildInputs or [] ) ++ [
                  prev.numpy
                ];
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  final.setuptools
                  final.cython
                  pkgs.cmake
                ];
              });
            })
          ]
        );

        # Make a virtualenv from the final package set
        venv = pythonSet.mkVirtualEnv "venv" workspace.deps.default;
        inherit (pkgs.callPackages pyproject-nix.build.util { }) mkApplication;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.jq
            pkgs.uv
            venv
          ];
        };
        packages = {
          default = mkApplication {
            venv = venv;
            package = pythonSet.simple-python-template;
          };
        };
      }
    );
}