{
  config,
  pkgs,
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

  poc = awsCredentialProcess "poc" "op://Work/aws-access-key-poc";
  dev = awsCredentialProcess "dev" "op://Work/aws-access-key-dev";
in {
  programs.awscli = {
    enable = true;
    credentials = {
      default = {
        credential_process = "${dev}";
      };
      "poc" = {
        credential_process = "${poc}";
      };
      "dev" = {
        credential_process = "${dev}";
      };
      staging = {
        credential_process = "${dev}";
      };
    };
    settings = {
      # Bare `aws` (no --profile) resolves to the poc credentials.
      default = {
        region = "us-east-1";
      };
      "profile poc" = {
        region = "us-east-1";
      };
      "profile dev" = {
        region = "us-east-1";
      };
      "profile staging" = {
        source_profile = "dev";
        role_arn = "arn:aws:iam::289189983327:role/Administrator";
        region = "us-east-1";
      };
    };
  };
}
