{ pkgs, pkgs-unstable, ... }:
let
  ghidraMcpRelease = pkgs.fetchzip {
    url = "https://github.com/LaurieWired/GhidraMCP/releases/download/2.0/GhidraMCP-release-2-0.zip";
    hash = "sha256-JRsBGII9k7/wsoUZicdGTHqzVu6a2qihQlf+iMj+lQU=";
  };
  ghidraMcpExtension = pkgs.runCommand "ghidra-mcp-extension-2.0" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p "$out"
    unzip -q ${ghidraMcpRelease}/ghidra_12.1.4_PUBLIC_20261010_GhidraMCP.zip -d "$out"
  '';
in
{
  home.packages = [ pkgs-unstable.ghidra ];

  home.file.".ghidra/.ghidra_12.1.4_PUBLIC/Extensions/GhidraMCP".source =
    "${ghidraMcpExtension}/GhidraMCP";
}