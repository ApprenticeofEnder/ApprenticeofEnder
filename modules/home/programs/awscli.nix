{
  config,
  pkgs,
  lib,
  ...
}: let
  # Emit the credential JSON the AWS SDK expects, sourcing the access keys from
  # 1Password at runtime via `op`. Nothing secret is ever written to ~/.aws;
  # `op` resolves the references against the signed-in 1Password app on demand.
  op = config.op.cli;
  awsCredentialProcess = name: item:
    pkgs.writeShellScript "aws-credentials-${name}" ''
      set -euo pipefail
      access_key_id="$(${op} read --no-newline "${item}/access key id")"
      secret_access_key="$(${op} read --no-newline "${item}/secret access key")"
      ${pkgs.jq}/bin/jq -nc \
        --arg id "$access_key_id" \
        --arg secret "$secret_access_key" \
        '{Version: 1, AccessKeyId: $id, SecretAccessKey: $secret}'
    '';

  mkAwsProfile = {
    name,
    access_key_uri,
    enable ? true,
    region ? "us-east-1",
    source_profile ? null,
    role_arn ? null,
    output ? "json",
  }: let
    credential_process = awsCredentialProcess name access_key_uri;
    profile_name =
      if name == "default"
      then "default"
      else "profile ${name}";
  in
    if !enable
    then {
      credentials = {};
      settings = {};
    }
    else {
      # inherit name region source_profile role_arn output;
      credentials = {
        "${name}" = {
          credential_process = "${credential_process}";
        };
      };
      settings = {
        "${profile_name}" = {
          inherit region output source_profile role_arn;
        };
      };
    };

  profiles = {
    default = mkAwsProfile {
      name = "default";
      access_key_uri = "op://Work/aws-access-key-dev";
    };
    poc = mkAwsProfile {
      name = "poc";
      access_key_uri = "op://Work/aws-access-key-poc";
    };
    dev = mkAwsProfile {
      name = "dev";
      access_key_uri = "op://Work/aws-access-key-dev";
    };
    staging = mkAwsProfile {
      name = "staging";
      access_key_uri = "op://Work/aws-access-key-dev";
      source_profile = "dev";
    };
  };

  profile_credentials = with builtins;
    lib.mergeAttrsList (
      map (profile: profile.credentials) (attrValues profiles)
    );
  profile_settings = with builtins;
    lib.mergeAttrsList (
      map (profile: profile.settings) (attrValues profiles)
    );
in {
  programs.awscli = {
    enable = true;
    credentials = profile_credentials;
    settings = profile_settings;
  };
}
