inputs: final: prev: {
  custom = {
    kindlegen = prev.callPackage ./kindlegen {};
    lemacs = prev.callPackage ./lemacs {};
    swhkd = prev.callPackage ./swhkd {};
    claude-squad = prev.callPackage ./claude-squad {};
    habla = prev.callPackage ./habla {};
    fn-agent = inputs.fn-agent.packages.${prev.stdenv.hostPlatform.system}.default;
    minecraft = prev.callPackage ./minecraft {};
  };
}
