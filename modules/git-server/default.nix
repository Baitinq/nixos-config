{ pkgs, config, ... }:
let
  dataDir = "/home/git"; #needs to be created and owned by ${user}
  cgitPackage = pkgs.cgit;
  user = "git";
  group = "git";
  adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID99gQ/AgXhgwAjs+opsRXMbWpXFRT2aqAOUbN3DsrhQ";
in
{
  environment.systemPackages = [
    cgitPackage
  ];

  services = {
    nginx = {
      enable = true;
      virtualHosts."_" = {
        listen = [
          { addr = "0.0.0.0"; port = 80; }
          { addr = "[::]"; port = 80; }
        ];
        locations = {
          "/".extraConfig =
            let
              cgitrc = pkgs.writeText "cgitrc" ''
                root-title=Baitinq's git
                root-desc=Hi!

                about-filter=${cgitPackage}/lib/cgit/filters/about-formatting.sh
                source-filter=${cgitPackage}/lib/cgit/filters/syntax-highlighting.py
                commit-filter=${cgitPackage}/lib/cgit/filters/commit-links.sh


                enable-blame=1
                enable-commit-graph=1
                enable-follow-links=1
                enable-git-config=1
                enable-html-serving=1
                enable-index-links=1
                enable-index-owner=0
                enable-log-filecount=1
                enable-log-linecount=1
                enable-remote-branches=1
                enable-subject-links=1
                enable-tree-linenumbers=1

                remove-suffix=1

                snapshots=tar.gz tar.bz2 zip

                readme=:README
                readme=:README.md
                readme=:README.org
                readme=:README.txt
                readme=:readme
                readme=:readme.md
                readme=:readme.org
                readme=:readme.txt

                project-list=${config.services.gitolite.dataDir}/projects.list
                scan-path=${config.services.gitolite.dataDir}/repositories
              '';
            in
            ''include ${config.services.nginx.package}/conf/fastcgi_params;
                fastcgi_split_path_info ^(/?)(.+)$;
                fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
                fastcgi_param SCRIPT_FILENAME ${cgitPackage}/cgit/cgit.cgi;
                fastcgi_param CGIT_CONFIG ${cgitrc};
                fastcgi_param PATH_INFO $uri;
                fastcgi_param QUERY_STRING $args;
                fastcgi_param HTTP_HOST $server_name; '';
          "~* ^/(.+.(ico|css|png))$".extraConfig = ''
            alias ${cgitPackage}/cgit/$1;
          '';
        };
      };
    };

    gitolite = {
      enable = true;
      inherit user group adminPubkey dataDir;
    };

    fcgiwrap = {
      enable = true;
      inherit user group;
    };
  };
}
