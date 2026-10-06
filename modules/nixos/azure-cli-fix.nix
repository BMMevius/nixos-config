{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          azure-storage-blob = pyPrev.azure-storage-blob.overridePythonAttrs (old: rec {
            version = "12.29.0";
            src = prev.fetchPypi {
              pname = "azure_storage_blob";
              inherit version;
              hash = "sha256-KCTd1+vJBWA068drF5caOOmqWDWrsNVluXAEk/Kmxlc=";
            };
          });
        })
      ];
    })
  ];
}
