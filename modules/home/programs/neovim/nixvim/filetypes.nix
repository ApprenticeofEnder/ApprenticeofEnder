{...}: {
  filetype = {
    pattern = {
      ".env.*" = "ini";
      "*.tfstate.backup" = "json";
    };
    filename = {
      ".env" = "ini";
      ".terraformrc" = "hcl";
      "terraform.rc" = "hcl";
    };
    extension = {
      # keep-sorted start
      fitc = "jsonc";
      fitcfg = "jsonc";
      fitdef = "jsonc";
      fitmf = "jsonc";
      fitres = "jsonc";
      hcl = "hcl";
      j2 = "jinja";
      jinja = "jinja";
      jinja2 = "jinja";
      tf = "terraform";
      tfstate = "json";
      tofu = "terraform";
      # keep-sorted end
    };
  };
}
