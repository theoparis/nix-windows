# WIP, needs git at build time
# See https://github.com/PowerShell/PowerShell/blob/master/PowerShell.Common.props#L18
{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "PowerShell";
  version = "7.4.5";

  src = fetchFromGitHub {
    owner = "PowerShell";
    repo = "PowerShell";
    rev = "v${version}";
    sha256 = "sha256-nwodYtqK/ioWJgepJCgJH82LwruwS4yl2/IHqyUhSWM=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nativeBuildInputs = [ ];
}
