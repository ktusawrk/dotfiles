# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "T14-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";
  # time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Prevent laptop from going to sleep when it is connected to power
  services.logind = {
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable VirtualBox. NOTE: must reboot after nixos-rebuild switch
  # See also adding user to "vboxusers" extraGroups
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.guest.enable = true;  

  # Configure keymap in X11
  services.xserver = {
    layout = "fi";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fi";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;                // Disabled at 24.11 upgrade
  # hardware.pulseaudio.enable = false; // Disabled at 24.11 upgrade
  # security.rtkit.enable = true;       // Disabled at 24.11 upgrade
  # services.pipewire = {               // Disabled at 24.11 upgrade
  #  enable = true;                     // Disabled at 24.11 upgrade
  #  alsa.enable = true;                // Disabled at 24.11 upgrade
  #  alsa.support32Bit = true;          // Disabled at 24.11 upgrade
  #  pulse.enable = true;               // Disabled at 24.11 upgrade
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  # };                                  // Disabled at 24.11 upgrade

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.1.9"
  ];
  

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      build-users-group = "nixbld";
      trusted-users = [
        "ktu"
	"root"
	"tester"
      ];
      # Subsituters
      trusted-public-keys = [
	"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [
	"https://cache.nixos.org"
      ];
      builders = lib.mkForce [
        "ssh://hertzarm aarch64-linux /root/.ssh/id_ed25519 8 1 kvm,bechmark,big-parallel,nixos-test; ssh://builder.vedenemo.dev x86_64-linux /root/.ssh/id_ed25519 8 1 kvm,bechmark,big-parallel,nixos-test"
      ];
      # Avoid copying unecessary stuff over SSH
      builders-use-substitutes = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ktu = {
    isNormalUser = true;
    description = "Kai Tusa";
    extraGroups = [ "networkmanager" "wheel" "vboxusers"];
    packages = with pkgs; [
      firefox
      pinta         # simple paint
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     wget
     emacs     
     git
     slack
     sticky                     # Sticky notes
     chromium
     solaar                     # Logitech MX keys configuration SW
     vscode                     # Visual Studio Code, unfree
     unixtools.xxd              # xxd tool is needed in the Ghaf build signature verifications process
     python3                    # Python3 is needed in the Ghaf build signature verifications process
     openssl                    # Openssl is needed in the Ghaf build signature verifications process
#    virtualbox                 # DON'T!! Adding virtualbox here makes it NOT work
     ntfs3g                     # Windows NT file system driver for external SSD drive compatibility
     azure-cli                  # Enable az command for Azure commands
     terraform                  # Infrastructure as code with Terraform
     openfortivpn               # Open source Fortinet compatible VPN client
     openconnect                # VPN client
     tree                       # Directory structure visualisation cli utility
     xdiskusage                 # Disk usage visualization with GUI
     libreoffice                # Open source office suite for editing documents offline
     drawio                     # Draw diagrams
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
