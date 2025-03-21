{
  lib,
  stdenv,
  fetchFromGitHub,
  obs-studio,
  cmake,
  qtbase,
  ndi,
  curl,
}:

stdenv.mkDerivation rec {
  pname = "distroav";
  version = "6.0.0";

  nativeBuildInputs = [
    cmake
    qtbase
  ];
  buildInputs = [
    obs-studio
    qtbase
    ndi
    curl
  ];

  src = fetchFromGitHub {
    owner = "DistroAV";
    repo = "DistroAV";
    rev = version;
    sha256 = "sha256-pr/5XCLo5fzergIQrYFC9o9K+KuP4leDk5/oRe5ct9Q=";
  };

  patches = [
    ./hardcode-ndi-path.patch
  ];

  postPatch = ''
    # Add path (variable added in hardcode-ndi-path.patch
    sed -i -e s,@NDI@,${ndi},g src/plugin-main.cpp

    # Replace bundled NDI SDK with the upstream version
    # (This fixes soname issues)
    rm -rf lib/ndi
    ln -s ${ndi}/include lib/ndi
  '';

  cmakeFlags = [ "-DENABLE_QT=ON" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-deprecated-declarations";

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Network A/V plugin for OBS Studio";
    homepage = "https://github.com/Palakis/obs-ndi";
    license = licenses.gpl2;
    maintainers = with maintainers; [ jshcmpbll ];
    platforms = platforms.linux;
    hydraPlatforms = ndi.meta.hydraPlatforms;
  };
}
