{
  inputs,
  ...
}:
{
  perSystem =
    {
      config,
      self',
      pkgs,
      lib,
      baseWorkspace,
      pythonSets,
      editablePythonSets,
      pythonVersions,
      ...
    }:
    {
      # nix build
      packages = rec {
        pythonNixTemplate311 = pythonSets.py311.mkVirtualEnv "sops-generator-3.11" baseWorkspace.deps.default;
        pythonNixTemplate312 = pythonSets.py312.mkVirtualEnv "sops-generator-3.12" baseWorkspace.deps.default;

        default = pythonNixTemplate312;
      };

    };
}
