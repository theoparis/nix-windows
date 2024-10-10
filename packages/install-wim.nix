{
  stdenvNoCC,
  wimlib,
  isoUrl ? "https://drive.massgrave.dev/en-us_windows_11_iot_enterprise_ltsc_2024_x64_dvd_f6b14814.iso",
  p7zip,
}:
let
  # nixpkgs' wimlib tries to build libX11 and util-linux because of ntfs3g
  iso = builtins.fetchurl {
    url = isoUrl;
    sha256 = "0yjx8189wv8nw221r3sfsvfmbbq8klv6qpa13f6a87gwjqm6cnag";
  };
in
stdenvNoCC.mkDerivation {
  name = "install-wim";
  src = null;

  nativeBuildInputs = [
    p7zip
    wimlib
  ];

  installPhase = ''
    7z x ${iso} sources/install.wim
    wimlib-imagex extract sources/install.wim 1 --dest-dir=$out
    rm sources/install.wim
  '';
}
