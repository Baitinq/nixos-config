{ pkgs, user, ... }:
{
  users.users."${user}".home = "/Users/${user}";

  environment.systemPackages =
    [
    ];

  services.nix-daemon.enable = true;
}
