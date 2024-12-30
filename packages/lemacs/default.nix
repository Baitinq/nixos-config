{writeShellScriptBin, ...}:
writeShellScriptBin "lemacs" ''
  if [ -n "$DISPLAY" ]; then
      emacsclient -a "" -n -c "$@"
  else
      emacsclient -a "" -c "$@"
  fi
''
