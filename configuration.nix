# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./command-not-found/command-not-found.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use Zen Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Add RTL8811AU Support
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821au ];

  networking.hostName = "nixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s20u2.useDHCP = true;
  networking.interfaces.enp2s0.useDHCP = true;
  
    # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  
  # Discord overlay to download discord from the official site
  nixpkgs.overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz; });})];


  # Enable fstrim
  services.fstrim.enable = true;
  
  # Use JetBrains Mono nerd fonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
  # Add OpenGL 32-bit support
  hardware.opengl.driSupport32Bit = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bee = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   };

  # Disable password for sudo
  security.sudo.extraRules= [{
    groups = [ "wheel" ];
    commands = [{
        command = "ALL" ;
        options= [ "NOPASSWD" ];
    }];
  }];

  # Set ZSH as the default shell
  users.defaultUserShell = pkgs.zsh;
  
  # Config packages
   nixpkgs.config = {
     allowUnfree = true;
   
   chromium = {
       enableWideVine = true;
     };
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim
     wget
     any-nix-shell
     curl
     firefox
     chromium
     krita
     gimp
     curl
     gparted
     libreoffice-fresh
     vscode
     gcc
     jdk
     jetbrains.idea-ultimate
     eclipses.eclipse-java
     git
     discord
     neofetch
     gnome.gnome-tweaks
   ];

  services.gnome.chrome-gnome-shell.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

    # clean /tmp on boot
  boot.cleanTmpDir=true;

  # Enable ADB
  programs.adb.enable = true;

  # Define session variables
  environment = {
    sessionVariables = {
      EDITOR = [ "vim" ];
    };

#    shellAliases = {
#    };
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

