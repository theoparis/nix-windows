{
  lib,
  stdenv,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  version = "1.14.4";
  pname = "wimlib";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ];

  src = builtins.fetchurl {
    url = "https://wimlib.net/downloads/${pname}-${version}.tar.gz";
    sha256 = "NjPbK2yLJV64bTvz3zBZeWvR8I5QuMlyjH62ZmLlEwA=";
  };

  enableParallelBuilding = true;

  doCheck = (!stdenv.hostPlatform.isDarwin);

  preCheck = ''
    patchShebangs tests
  '';

  meta = with lib; {
    homepage = "https://wimlib.net";
    description = "Library and program to extract, create, and modify WIM files";
    platforms = platforms.unix;
    maintainers = [ ];
    license = with licenses; [
      gpl3
      lgpl3
      mit
    ];
  };
}
