{
  modulesPath,
  pkgs,
  ...
}: let
  timeZone = "Europe/London";
  defaultLocale = "en_GB.UTF-8";

  hostname = "network-share";
  cluster_subnet = "10.0.7.0/24";
  ipv4_lan_address = "10.0.1.202";
  ipv4_netshare_address = "10.0.5.202";
  ipv4_cluster_address = "10.0.7.202";
  default_gateway = "10.0.1.1";
  nameservers = ["10.0.1.53"];

  time_machine_mount = "/mnt/mofp0/backups/TimeMachine";
  jellyfin_mount = "/mnt/mopower/swarm-data/jellyfin";
  windows_games_mount = "/mnt/mospeed/Games";
  shared_data_mount = "/mnt/mofp0/data";

  swarm_config_directory = "/mnt/mospeed/swarm-config";
  swarm_data_directory = "/mnt/mopower/swarm-data";
  nas_yom_old_directory = "/mnt/mospeed/NAS-YOM";
  nas_yom_directory = "/mnt/mofp0/data/NAS-YOM";
  nas_yom_ftp_directory = "/mnt/mofp0/data/NAS-YOM/FTP";
  kubernetes_home_cluster_configs = "/mnt/mofp0/kubernetes/home-cluster/configs";
  kubernetes_home_cluster_data = "/mnt/mofp0/kubernetes/home-cluster/data";

  nfs_export_permissions = "rw,sync,no_subtree_check,no_root_squash";
in {
  imports = [
    # Include the default lxc/lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  boot.isContainer = true;
  networking.hostName = hostname;

  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true;

  time.timeZone = timeZone;

  i18n = {
    defaultLocale = defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  # Supress systemd units that don't work because of LXC.
  # https://blog.xirion.net/posts/nixos-proxmox-lxc/#configurationnix-tweak
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  environment.systemPackages = with pkgs; [git];

  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        {
          address = ipv4_lan_address;
          prefixLength = 24;
        }
      ];
    };
    eth1 = {
      ipv4.addresses = [
        {
          address = ipv4_netshare_address;
          prefixLength = 24;
        }
      ];
    };
    eth2 = {
      ipv4.addresses = [
        {
          address = ipv4_cluster_address;
          prefixLength = 24;
        }
      ];
    };
  };
  networking.defaultGateway = default_gateway;
  networking.nameservers = nameservers;

  users.groups = {
    users = {
      gid = 100;
    };
  };

  users.users.sambayom = {
    uid = 1001;
    group = "users";
    isSystemUser = true;
  };

  users.users.ftpyom = {
    uid = 1002;
    group = "users";
    isSystemUser = true; # Do not create a home directory
  };

  networking.firewall = {
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [111 2020 2121 2049 4000 4001 4002 20048];
    allowedUDPPorts = [111 2049 4000 4001 4002 20048];
    allowedTCPPortRanges = [
      {
        from = 10000;
        to = 10100;
      }
    ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      ${swarm_config_directory}           ${cluster_subnet}(${nfs_export_permissions})
      ${swarm_data_directory}             ${cluster_subnet}(${nfs_export_permissions})
      ${nas_yom_old_directory}            ${cluster_subnet}(${nfs_export_permissions})
      ${nas_yom_directory}                ${cluster_subnet}(${nfs_export_permissions})
      ${kubernetes_home_cluster_configs}  ${cluster_subnet}(${nfs_export_permissions})
      ${kubernetes_home_cluster_data}     ${cluster_subnet}(${nfs_export_permissions})
    '';
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      userServices = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>

          <service>
            <type>_adisk._tcp</type>
            <port>445</port>
            <txt-record>sys=adVF=0x100</txt-record>
            <txt-record>dk0=adVN=TimeMachine,adVF=0x82</txt-record>
          </service>

          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    winbindd.enable = false;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "%h server";
        "dns proxy" = "no";
        "security" = "user";
        "logging" = "syslog";
        "panic action" = "/usr/share/samba/panic-action %d";
        "unix password sync" = "yes";
        "pam password change" = "yes";
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
        "load printers" = "no";
        "disable spoolss" = "yes";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "unix extensions" = "no";
        # Permissions
        "create mask" = "0660";
        "force create mode" = "0660";
        "directory mask" = "0770";
        "force directory mode" = "0770";
        #
        "use sendfile" = "yes";
        "aio read size" = "16384";
        "aio write size" = "16384";
        # Apple specific config options
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:model" = "RackMac"; # https://askubuntu.com/a/1379614
        "fruit:encoding" = "native";
        "fruit:metadata" = "stream";
        "spotlight backend" = "elasticsearch";
        # Extra options
        "min receivefile size" = "16384";
        "max connections" = "65535";
        "max open files" = "65535";
        # Added settings
        "server min protocol" = "SMB3_02"; # For iOS
        "acl allow execute always" = "yes";
      };

      "TimeMachine" = {
        "comment" = "TimeMachine backups";
        "path" = time_machine_mount;
        "read only" = "no";
        "inherit acls" = "yes";
        "store dos attributes" = "no";
        "fruit:encoding" = "private";
        "fruit:locking" = "none";
        "fruit:metadata" = "netatalk";
        "fruit:resource" = "file";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "1024 G";
        # Permissions
        "create mask" = "0664";
        "force create mode" = "0664";
        "directory mask" = "0775";
        "force directory mode" = "0775";
        "hide special files" = "yes";
      };

      "Jellyfin" = {
        "comment" = "Plex is not viable";
        "path" = jellyfin_mount;
        "read only" = "no";
        "inherit acls" = "yes";
        "store dos attributes" = "no";
        "recycle:repository" = ".recycle/%U";
        "recycle:keeptree" = "yes";
        "recycle:versions" = "yes";
        "recycle:touch" = "yes";
        "recycle:touch_mtime" = "no";
        "recycle:directory_mode" = "0777";
        "recycle:subdir_mode" = "0700";
        "recycle:exclude" = "";
        "recycle:exclude_dir" = "";
        "recycle:maxsize" = "0";
        "vfs objects" = " recycle catia fruit streams_xattr";
        # Permissions
        "create mask" = "0660";
        "force create mode" = "0660";
        "directory mask" = "0770";
        "force directory mode" = "0770";
        "hide special files" = "yes";
        "force group" = "users";
      };

      "Games" = {
        "comment" = "Games & Windows";
        "path" = windows_games_mount;
        "read only" = "no";
        "inherit acls" = "yes";
        "inherit permissions" = "yes";
        "recycle:repository" = ".recycle/%U";
        "recycle:keeptree" = "yes";
        "recycle:versions" = "yes";
        "recycle:touch" = "yes";
        "recycle:touch_mtime" = "no";
        "recycle:directory_mode" = "0777";
        "recycle:subdir_mode" = "0700";
        "recycle:exclude" = "";
        "recycle:exclude_dir" = "";
        "recycle:maxsize" = "0";
        "vfs objects" = " recycle catia fruit streams_xattr";
        # Permissions
        "create mask" = "0664";
        "force create mode" = "0664";
        "directory mask" = "0775";
        "force directory mode" = "0775";
        "hide special files" = "yes";
        "force group" = "users";
      };

      "SharedData" = {
        "comment" = "Main";
        "path" = shared_data_mount;
        "read only" = "no";
        "inherit acls" = "yes";
        "inherit permissions" = "yes";
        "recycle:repository" = ".recycle/%U";
        "recycle:keeptree" = "yes";
        "recycle:versions" = "yes";
        "recycle:touch" = "yes";
        "recycle:touch_mtime" = "no";
        "recycle:directory_mode" = "0777";
        "recycle:subdir_mode" = "0700";
        "recycle:exclude" = "";
        "recycle:exclude_dir" = "";
        "recycle:maxsize" = "0";
        "vfs objects" = " recycle catia fruit streams_xattr";
        # Permissions
        "create mask" = "0660";
        "force create mode" = "660";
        "directory mask" = "0770";
        "force directory mode" = "770";
        "hide special files" = "yes";
        "force group" = "users";
      };
    };
  };
  # For Windows
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.vsftpd = {
    enable = true;
    localRoot = nas_yom_ftp_directory;
    writeEnable = true;
    localUsers = true;
    chrootlocalUser = true;
    allowWriteableChroot = true;
    anonymousUploadEnable = false;
    # See http://vsftpd.beasts.org/vsftpd_conf.html for options
    extraConfig = ''
      listen_port=2020
      ftp_data_port=2121
      local_umask=007
      use_localtime=YES
      xferlog_enable=YES
      connect_from_port_20=YES
      pasv_min_port=10000
      pasv_max_port=10100
    '';
  };

  system.stateVersion = "24.11";
}
