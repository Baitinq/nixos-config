{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, tmux
, gh
, git
}:

buildGoModule rec {
  pname = "claude-squad";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "smtg-ai";
    repo = "claude-squad";
    rev = "v${version}";
    hash = "sha256-OL+IG+NvrwAc0+7BlKJPKdSx8ZIbI/FtdvlAA807NYI=";
  };

  vendorHash = "sha256-BduH6Vu+p5iFe1N5svZRsb9QuFlhf7usBjMsOtRn2nQ=";

  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];
  
  buildInputs = [ tmux gh ];

  postInstall = ''
    wrapProgram $out/bin/claude-squad \
      --prefix PATH : ${lib.makeBinPath [ tmux gh ]}
  '';

  meta = with lib; {
    description = "Terminal app that manages multiple Claude Code, Codex, Gemini and other AI agents in separate workspaces";
    homepage = "https://github.com/smtg-ai/claude-squad";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "claude-squad";
  };
}
