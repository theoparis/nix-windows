{
  lib,
  stdenv,
  fetchurl,
  libpkgconf,
  pkgconf,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "muon";
  version = "0.2.0";

  src = builtins.fetchurl {
    url = "https://github.com/theoparis/muon/archive/d6610533f1a6b35d4b77f5bbc0fcc6d9c5a2dd2c.tar.gz";
    sha256 = "11xs536hycxn145v0630y3v3mq6gajpvzllr09cpqgizwkim07w9";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [
    pkgconf
  ];

  buildInputs = [
    libpkgconf
    zlib
  ];

  strictDeps = true;

  postUnpack =
    let
      samurai-wrap = fetchurl {
        name = "samurai-wrap";
        url = "https://mochiro.moe/wrap/samurai-1.2-32-g81cef5d.tar.gz";
        hash = "sha256-aPMAtScqweGljvOLaTuR6B0A0GQQQrVbRviXY4dpCoc=";
      };
    in
    ''
      pushd $sourceRoot/subprojects
      tar xvf ${samurai-wrap}
      popd
    '';

  postPatch = ''
    patchShebangs bootstrap.sh
  '';

  buildPhase =
    let
      muonBool = lib.mesonBool;
      muonEnable = lib.mesonEnable;

      cmdlineForMuon = lib.concatStringsSep " " [
        (muonBool "static" stdenv.targetPlatform.isStatic)
        (muonEnable "samurai" true)
      ];
      cmdlineForSamu = "-j$NIX_BUILD_CORES";
    in
    ''
      runHook preBuild

      ./bootstrap.sh stage-1

      ./stage-1/muon setup ${cmdlineForMuon} stage-2
      ./stage-1/muon samu ${cmdlineForSamu} -C stage-2

      stage-2/muon setup -Dprefix=$out ${cmdlineForMuon} stage-3
      stage-2/muon samu ${cmdlineForSamu} -C stage-3

      runHook postBuild
    '';

  # tests are failing because they don't find Python
  doCheck = false;

  installPhase = ''
    runHook preInstall

    stage-3/muon -C stage-3 install

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://muon.build/";
    description = "Implementation of Meson build system in C99";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ AndersonTorres ];
    platforms = platforms.unix;
    broken = stdenv.hostPlatform.isDarwin; # typical `ar failure`
    mainProgram = "muon";
  };
})
