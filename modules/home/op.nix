{lib, ...}: {
  options = {
    op = {
      cli = lib.mkOption {
        type = lib.types.str;
        description = "The binary to use for 1Password's CLI";
      };
      ssh-sign = lib.mkOption {
        type = lib.types.str;
        description = "The binary to use for 1Password's SSH signing";
      };
      identity-agent = lib.mkOption {
        type = lib.types.str;
        description = "The socket to use for 1Password's SSH agent";
      };
    };
  };
}
