{ pkgs, ... }:
let
  satoshi = pkgs.stdenvNoCC.mkDerivation {
    pname = "satoshi-font";
    version = "1.0";

    src = pkgs.fetchzip {
      url = "https://api.fontshare.com/v2/fonts/download/satoshi";
      sha256 = "sha256-z5KM+IH4234HCzkE/nZn9fg+vADXUlcddCoHsO06t0w=";
      stripRoot = false;
      extension = "zip";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/opentype
      find $src -name '*.otf' -exec cp {} $out/share/fonts/opentype/ \;
      mkdir -p $out/share/fonts/truetype
      find $src -name '*.ttf' -exec cp {} $out/share/fonts/truetype/ \;
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Satoshi font family by Indian Type Foundry";
      homepage = "https://www.fontshare.com/fonts/satoshi";
      license = licenses.unfree;
    };
  };
in
{
  home.packages = [
    pkgs.google-fonts # includes Mulish
    satoshi
  ];

  fonts.fontconfig.enable = true;
}
