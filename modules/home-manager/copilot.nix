{ lib, osConfig, pkgs, ... }:
{
  home.packages = [ pkgs.github-copilot-cli ];

  home.activation.copilotGhidraMcp = lib.mkIf (osConfig.networking.hostName == "laptop-bastiaan") (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.github-copilot-cli}/bin/copilot mcp add ghidra -- \
        ${pkgs.uv}/bin/uvx --from git+https://github.com/LaurieWired/GhidraMCP@2.0 \
        ghidra-mcp --ghidra-server http://127.0.0.1:8080/
    ''
  );
}