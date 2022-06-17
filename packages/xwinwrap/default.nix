{ lib, stdenv, fetchFromGitHub, xlibsWrapper }:

stdenv.mkDerivation rec {
  pname = "xwinwrap";
  version = "4";

  src = fetchFromGitHub {
    owner = "Baitinq";
    repo = "xwinwrap";
    rev = "401b5a5eb092173443253cdd57736cd6bf401e40";
    sha256 = "sha256-8+asreFjzD49O3sZlAXBsWD3PU0rqkbs/J3Dq9VeiYA=";
  };

  buildInputs = [ xlibsWrapper ];

  buildPhase =
    if stdenv.hostPlatform.system == "x86_64-linux" then ''
      make all
    '' else if stdenv.hostPlatform.system == "i686-linux" then ''
      make all
    '' else
      throw "xwinwrap is not supported on ${stdenv.hostPlatform.system}";

  installPhase = ''
    mkdir -p $out/bin
    mv xwinwrap $out/bin
  '';

  meta = with lib; {
    description =
      "A utility that allows you to use an animated X window as the wallpaper";
    longDescription = ''
      XWinWrap is a small utility written a loooong time ago that allowed you to
      stick most of the apps to your desktop background. What this meant was you
      could use an animated screensaver (like glmatrix, electric sheep, etc) or
      even a movie, and use it as your wallpaper. But only one version of this
      app was ever released, and it had a few problems, like:
      - Well, sticking didn’t work. So if you did a “minimize all” or “go to
      desktop” kind of thing, your “wallpaper” got minimized as well.
      - The geometry option didn’t work, so you could not create, e.g., a small
      matrix window surrounded by your original wallpaper.
      Seeing no-one picking it up, I decided to give it a bit of polish last
      weekend by fixing the above problems and also add a few features. And here
      it is, in its new avatar “Shantz XWinWrap”.
    '';
    license = licenses.hpnd;
    homepage = "https://shantanugoel.com/2008/09/03/shantz-xwinwrap/";
    maintainers = with maintainers; [ infinisil ];
    platforms = platforms.linux;
  };
}
