{ config, pkgs, ... }:
let
  cfg = config.programs.command-not-found;
  commandNotFound = pkgs.substituteAll {
    name = "command-not-found";
    dir = "bin";
    src = ./command-not-found.pl;
    isExecutable = true;
    inherit (cfg) dbPath;
    perl = pkgs.perl.withPackages (p: [ p.DBDSQLite p.StringShellQuote ]);
  };
in
{
  programs.command-not-found.enable = false;
 
  environment.systemPackages = [ commandNotFound ];

  programs.bash.interactiveShellInit =
     ''
       # This function is called whenever a command is not found.
       command_not_found_handle() {
         local p=${commandNotFound}/bin/command-not-found
         if [ -x $p -a -f "/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite" ]; then
           # Run the helper program.
           $p "$@"
         else
           echo "$1: command not found" >&2
           return 127
         fi
       }
       dh(){
         echo "obase=16; ibase=10; $1"|bc
       }
       hd(){
         echo "obase=10; ibase=16; $1"|bc
       }
     '';

   programs.zsh.interactiveShellInit =
     ''
       # This function is called whenever a command is not found.
       command_not_found_handler() {
         local p=${commandNotFound}/bin/command-not-found
         if [ -x $p -a -f "/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite" ]; then
           # Run the helper program.
           $p "$@"
         else
           # Indicate than there was an error so ZSH falls back to its default handler
           echo "$1: command not found" >&2
           return 127
         fi
       }
       dh(){
         echo "obase=16; ibase=10; $1"|bc
       }
       hd(){
         echo "obase=10; ibase=16; $1"|bc
       }
     '';
}
