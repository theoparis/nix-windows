final: previous: {
  muonStandalone = previous.callPackage ../packages/muon.nix { };
  muon = previous.callPackage ../packages/muon.nix { };
  wimlib = previous.callPackage ../packages/wimlib.nix { };
  llvm-full = previous.callPackage ../packages/llvm.nix { };

  # autotools doesn't build bash for mingw
  bash = previous.stdenv.mkDerivation {
    name = "bash";
    src = builtins.fetchurl {
      url = "https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz";
      sha256 = "1yrjmf0mqg2q8pqphjlark0mcmgf88b0acq7bqf4gx3zvxkc2fd1";
    };
    buildInputs = [ ];
    nativeBuildInputs = [ final.muonStandalone ];

    configurePhase = ''
      muon setup -Dprefix=$out build
    '';

    buildPhase = ''
      muon samu -C build
    '';

    installPhase = ''
      muon install -C build
    '';

    passthru = {
      shellPath = "/bin/bash";
    };
  };
}
