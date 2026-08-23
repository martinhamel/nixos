# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.enableAllFirmware = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  services.resolved.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 8010 ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Montreal";

  i18n.defaultLocale = "fr_CA.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_CA.UTF-8";
    LC_IDENTIFICATION = "fr_CA.UTF-8";
    LC_MEASUREMENT = "fr_CA.UTF-8";
    LC_MONETARY = "fr_CA.UTF-8";
    LC_NAME = "fr_CA.UTF-8";
    LC_NUMERIC = "fr_CA.UTF-8";
    LC_PAPER = "fr_CA.UTF-8";
    LC_TELEPHONE = "fr_CA.UTF-8";
    LC_TIME = "fr_CA.UTF-8";
  };

  # Enable the GNOME Desktop Environment.
  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ca";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "cf";

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    operation = "boot";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.martin = {
    isNormalUser = true;
    description = "Martin Hamel";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;

    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  programs.steam.enable = true;
  programs.firefox = {
    enable = true;
    
    # Installe les paquets de langue directement via Nix
    languagePacks = [ "fr" "en-US" ];
  
    # Force les paramètres linguistiques de Firefox
    preferences = {
      "intl.locale.requested" = "fr,en-US";
      "intl.accept_languages" = "fr-fr,en-us,en";
    };
  };
  programs.fish.enable = true;	

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    helix
    wl-clipboard
    fwupd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.fwupd.enable = true;
  services.flatpak.enable = true;
  services.languagetool = {
    enable = true;
    allowOrigin = "*";
  };
  services.searx = {
    enable = true;
    settings.server = {
      port = 8080;
      bind_address = "0.0.0.0";
      secret_key = "1234";
    };
  };
  services.fprintd.enable = true;
  virtualisation.podman = {
    enable = true;  
    # Indispensable pour que les conteneurs d'un podman-compose puissent communiquer entre eux
    defaultNetwork.settings.dns_enabled = true;
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.5.0";
      OLLAMA_FLASH_ATTENTION = "0";
      OLLAMA_IGPU_ENABLE = "1";
      
      # 🚀 Vous pouvez doubler la limite en toute sécurité
      OLLAMA_CONTEXT_LENGTH = "32768";
    };
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}

