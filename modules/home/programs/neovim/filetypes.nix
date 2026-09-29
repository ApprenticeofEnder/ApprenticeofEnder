{...}: {
  filetype = {
    pattern = {
      ".env.*" = "ini";
      "*.tfstate.backup" = "json";
      "*.sh.tpl" = "sh";
      ".*/%.github/workflows/.*%.ya?ml" = "yaml.ghactions";
    };
    filename = {
      ".env" = "ini";
      ".terraformrc" = "hcl";
      "terraform.rc" = "hcl";
    };
    extension = {
      # keep-sorted start
      build = "systemd";
      container = "systemd";
      fitc = "jsonc";
      fitcfg = "jsonc";
      fitdef = "jsonc";
      fitmf = "jsonc";
      fitres = "jsonc";
      hcl = "hcl";
      image = "systemd";
      j2 = "jinja";
      jinja = "jinja";
      jinja2 = "jinja";
      kube = "systemd";
      network = "systemd";
      pod = "systemd";
      service = "systemd";
      socket = "systemd";
      tf = "terraform";
      tfstate = "json";
      timer = "systemd";
      tofu = "terraform";
      volume = "systemd";
      # keep-sorted end
    };
  };
}
