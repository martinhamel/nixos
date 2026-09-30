# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

{
imports = [
  # Include the results of the hardware scan.
  ./hardware-configuration.nix
];

# ==========================================================================
#  Boot & firmware
# ==========================================================================
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

hardware.enableAllFirmware = true;

# ==========================================================================
#  Matériel : graphique (AMD)
# ==========================================================================
hardware.graphics = {
  enable = true;
  enable32Bit = true;
  extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
};
services.xserver.videoDrivers = [ "amdgpu" ];

# ==========================================================================
#  Bluetooth
# ==========================================================================
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
};

# ==========================================================================
#  Réseau
# ==========================================================================
networking.hostName = "nixos";
networking.networkmanager.enable = true;
networking.firewall.allowedTCPPorts = [ 3000 8010 ];
services.resolved.enable = true;
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# ==========================================================================
#  Localisation & langues
# ==========================================================================
i18n.defaultLocale = "fr_FR.UTF-8";
i18n.extraLocaleSettings = {
  LC_IDENTIFICATION = "fr_FR.UTF-8";
  LC_MEASUREMENT    = "fr_FR.UTF-8";
  LC_MONETARY       = "fr_FR.UTF-8";
  LC_NAME           = "fr_FR.UTF-8";
  LC_NUMERIC        = "fr_FR.UTF-8";
  LC_PAPER          = "fr_FR.UTF-8";
  LC_TELEPHONE      = "fr_FR.UTF-8";
  LC_TIME           = "fr_FR.UTF-8";
};

services.gvfs.enable = true;

# Clavier X11
services.xserver.xkb = {
  layout = "ca";
  variant = "";
};

# Clavier console
console.keyMap = "cf";

# ==========================================================================
#  Affichage & session graphique (niri + noctalia + greetd)
  # ==========================================================================
  programs.niri = {
    enable = true;
    useNautilus = true; # Gestion de fichiers intégré
  };

  programs.noctalia = {
    enable = true;
  };

  services.displayManager.noctalia-greeter.enable = true;
  # Désactive le lecteur d'empreintes uniquement pour l'écran de connexion
  security.pam.services.greetd.allowNullPassword = true;
  security.pam.services.greetd.fprintAuth = false;
  security.pam.services.login.fprintAuth = false;


  # Service de géolocalisation
  services.geoclue2 = {
    enable = true;
    # Permet aux applications non-desktop d'accéder à la position
    enableDemoAgent = true;
    geoProviderUrl = "https://beacondb.net/v1/geolocate";
    appConfig = {
      "noctalia" = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };

  # ==========================================================================
  #  Son (PipeWire)
  # ==========================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # ==========================================================================
  #  Utilisateur
  # ==========================================================================
  users.users.martin = {
    isNormalUser = true;
    description = "Martin Hamel";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.fish;

    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  users.users.sarah = {
    isNormalUser = true;
    description = "Sarah";
    shell = pkgs.fish;
  };

  # ==========================================================================
  #  Programmes & profils
  # ==========================================================================
  programs.steam.enable = true;
  programs.nix-ld.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

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

  programs.direnv = {
    enable = true;
    # Intégration optimisée pour Nix (met en cache les environnements pour que ce soit instantané)
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Martin Hamel";
        email = "martin@ma4s.org";
      };
      init = {
        defaultBranch = "main"; # Fini "master" par défaut
      };
    };
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            cursor-theme = "Bibata-Modern-Classic";
            cursor-size = lib.gvariant.mkInt32 24;
          };
        };
      }
    ];
  };

  # ==========================================================================
  #  Paquets système
  # ==========================================================================
  environment.systemPackages = with pkgs; [
    # --- Bureautique ---
    collabora-desktop
    pandoc
    gnome-calculator
    papers
    eog

    # --- Navigation & Communication ---
    thunderbird
    (pkgs.symlinkJoin {
      name = "signal-desktop";
      paths = [ pkgs.signal-desktop ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/signal-desktop \
          --add-flags '--password-store="gnome-libsecret"'
      '';
    })
    proton-vpn
    gimp-with-plugins
    gimpPlugins.resynthesizer

    # --- Multimédia ---
    vlc
    ffmpeg
    frame
    media-downloader
    eog

    # --- Sécurité & mots de passe ---
    bitwarden-desktop
    authenticator

    # --- Outils système ---
    wget
    wl-clipboard
    fwupd
    playerctl
    bluez
    brightnessctl
    xdg-utils
    grim
    slurp
    killall
    adwaita-icon-theme
    fuzzel
    swaylock
    noctalia
    nautilus
    xwayland-satellite
    fastfetch
    fetch
    smile
    btop
    jujutsu
    bemoji
    wtype
    alacritty
    fuzzel
    waybar

    # --- Développement : base ---
    gcc           # Requis par Tree-sitter pour compiler les parseurs
    gnumake
    ripgrep       # Essentiel pour la recherche de texte (Telescope)
    unzip
    curl

    # --- Conteneurs ---
    podman-compose

    # --- Développement : langages & runtimes ---
    python3
    nodejs
    cargo
    rustc
    docker-language-server
    docker-compose-language-service

    # --- Développement : LSP & debuggers ---
    gettext
    rust-analyzer
    lldb
    nil
    nixd
    marksman
    typescript-language-server
    intelephense

    # --- Bases de données ---
    dbeaver-bin
    pgcli

    # --- Autres ---
    opencode
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    bibata-cursors
  ];

  # ==========================================================================
  #  Services
  # ==========================================================================
  services.upower.enable = true;
  services.fwupd.enable = true;
  services.flatpak.enable = true;
  services.fprintd.enable = true;

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

  # ==========================================================================
  #  Maintenance & mise à jour
  # ==========================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    operation = "boot";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # ==========================================================================
  #  Variables d'environnement globales
  # ==========================================================================
  environment.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "25.11"; # Did you read the comment?
}
