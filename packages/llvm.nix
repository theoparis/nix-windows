{
  stdenv,
  stdenvAdapters,
  wrapCC,
  cmakeMinimal,
  python3,
  perl,
  lib,
  ncurses,
  projects ? "clang;lld",
}:
let
  llvm = stdenv.mkDerivation {
    name = "llvm-full";
    src = builtins.fetchUrl {
      url = "https://github.com/llvm/llvm-project/archive/9432f7074c8ebacd33cb0b271054881c8f566276.tar.gz";
      sha256 = lib.fakeSha256;
    };

    nativeBuildInputs = [
      cmakeMinimal
      python3
      perl
    ];

    buildInputs = [
      ncurses
    ];

    configurePhase = ''
      cmake -S llvm -B build \
      	-DCMAKE_BUILD_TYPE=MinSizeRel \
      	-DLLVM_ENABLE_PROJECTS="${projects}" \
      	-DLLVM_ENABLE_PIC=ON \
        -DLLVM_LIBC_FULL_BUILD=ON \
        -DLIBC_HDRGEN_ONLY=ON \
      	-DMLIR_ENABLE_VULKAN_RUNNER=OFF \
      	-DMLIR_ENABLE_SPIRV_CPU_RUNNER=ON \
      	-DMLIR_ENABLE_EXECUTION_ENGINE=ON \
      	-DLLVM_ENABLE_RTTI=ON \
      	-DLLVM_ENABLE_TERMINFO=OFF \
      	-DLLVM_ENABLE_ZLIB=OFF \
      	-DLLVM_ENABLE_LIBXML2=OFF \
      	-DLLVM_ENABLE_LIBEDIT=OFF \
      	-DLLVM_ENABLE_LIBPFM=OFF \
      	-DLLVM_INCLUDE_DOCS=OFF \
      	-DLLVM_INCLUDE_TESTS=OFF \
      	-DLLVM_INCLUDE_BENCHMARKS=OFF \
      	-DLLVM_PARALLEL_LINK_JOBS=1 \
      	-DLLDB_ENABLE_LUA=OFF \
      	-DLLDB_ENABLE_PYTHON=OFF \
      	-DLLDB_ENABLE_LZMA=OFF \
      	-DLLDB_ENABLE_LIBEDIT=OFF \
      	-DLLDB_ENABLE_LIBXML2=OFF \
      	-DLLDB_ENABLE_CURSES=ON \
      	-DCMAKE_INSTALL_PREFIX=${placeholder "out"}
    '';
    buildPhase = ''
      cmake --build build --parallel $NIX_BUILD_CORES
    '';
    installPhase = ''
      cmake --install build
    '';
  };

  clang = wrapCC (
    stdenv.mkDerivation {
      name = "clang-full";
      dontUnpack = true;
      installPhase = ''
        			mkdir -p $out/bin
        			for bin in ${toString (builtins.attrNames (builtins.readDir "${llvm}/bin"))}; do
        				cat > $out/bin/$bin <<EOF
        #!${stdenv.shell}
        exec "${llvm}/bin/$bin" "\$@"
        EOF
        				chmod +x $out/bin/$bin
        		done
        		'';
      passthru.isClang = true;
    }
  );

  stdenv = stdenvAdapters.overrideCC stdenv clang;
in
{
  inherit llvm;
  inherit clang;
  inherit stdenv;
}
