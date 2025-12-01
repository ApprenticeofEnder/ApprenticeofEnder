{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [ self.homeModules.default ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "robertbabaev";
    fullname = "Robert Babaev";
    email = "github@robertbabaev.tech";
  };

  home.stateVersion = "25.05";

  home.shellAliases = {
    opencode = ''AWS_BEARER_TOKEN_BEDROCK=$(op read "op://Work/Amazon Bedrock API Key/credential") opencode'';
  };
}
