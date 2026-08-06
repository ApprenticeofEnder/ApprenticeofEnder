{
  lib,
  config,
  pkgs,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib;};
  # keep-sorted start
  inherit (ai_coding_lib) claude_tools;
  inherit (ai_coding_lib) collectLeafFiles;
  inherit (ai_coding_lib) global_bash;
  inherit (ai_coding_lib) lockfiles;
  inherit (ai_coding_lib) mcpToolSet;
  inherit (ai_coding_lib) mkClaudePermissionList;
  inherit (ai_coding_lib) sensitive_files;
  inherit (ai_coding_lib) serena_tools;
  # keep-sorted end

  context = import ../lib/context.nix {inherit lib pkgs;};

  skill_file_paths = collectLeafFiles ../skills "";

  skill_files = with builtins;
    listToAttrs (
      map (fn: {
        name = ".claude/skills/${fn}";
        value = {
          text = readFile (../skills + "/${fn}");
        };
      })
      skill_file_paths
    );

  mcp_tools = {
    serena = mcpToolSet {
      name = "serena";
      tools = {
        basic = serena_tools.basic;
        edit = serena_tools.edit;
      };
      home_manager = true;
      agent = "claude";
    };

    atlassian = mcpToolSet {
      name = "claude_ai_Atlassian";
      tools = {
        issues = [
          "getTransitionsForJiraIssue"
          "transitionIssue"
        ];
        confluence = [
          "getAccessibleAtlassianResources"
          "getConfluenceSpaces"
          "getPagesInConfluenceSpace"
          "getConfluencePage"
          "searchConfluenceUsingCql"
        ];
      };
      agent = "claude";
    };
  };

  otel = {
    endpoint = "http://localhost:4317";
    protocol = "grpc";
    metrics_exporter = "otlp";
    logs_exporter = "otlp";
  };
in {
  imports = [
    ./hooks
  ];
  home.shellAliases = {
    claude = lib.removeSuffix "\n" ''CC_SYSTEM_PROMPT=$(serena prompts print-cc-system-prompt-override) ${lib.getExe config.programs.claude-code.finalPackage} --system-prompt="$CC_SYSTEM_PROMPT"'';
  };

  home.file =
    skill_files
    // {
      ".claude/scripts/claude-hud-statusline.sh" = {
        source = ./scripts/claude-hud-statusline.sh;
        executable = true;
      };

      ".claude/skills/skill-rules.json" = {
        source = ./skill-rules.json;
      };
    };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    context = context;

    # `/plugin marketplace add` fails at runtime: it writes into settings.json,
    # which home-manager manages as a read-only symlink into /nix/store.
    # Declare marketplaces here instead so home-manager renders them into
    # settings.json's `extraKnownMarketplaces` at build time.
    marketplaces = {
      ender-agent-ops = pkgs.fetchFromGitHub {
        owner = "ApprenticeofEnder";
        repo = "ender-agent-ops";
        rev = "5d2814491074ba3b865941b89721254bfad69a62";
        hash = "sha256-DF0hp+neyDsQI+uLmvjeQfcnEt36uUpiFRdkJ13SsQE=";
      };
      claude-hud = pkgs.fetchFromGitHub {
        owner = "jarrodwatts";
        repo = "claude-hud";
        rev = "59eadbe9bd4aa3df2f740f828069a8def4363606";
        sha256 = "1996a65fllziwlirb5ym86fwm9rk6ff1vmvj3jrllxxayl5azazp";
      };
    };

    settings = {
      model = "sonnet";
      env = {
        # keep-sorted start
        CLAUDE_CODE_ENABLE_TELEMETRY = "1";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        GIT_EXTERNAL_DIFF = "difft";
        OTEL_EXPORTER_OTLP_ENDPOINT = otel.endpoint;
        OTEL_EXPORTER_OTLP_PROTOCOL = otel.protocol;
        OTEL_LOGS_EXPORTER = otel.logs_exporter;
        OTEL_METRICS_EXPORTER = otel.metrics_exporter;
        # keep-sorted end
      };
      enabledPlugins = {
        "claude-hud@claude-hud" = true;
        "skill-router@ender-agent-ops" = true;
      };

      statusLine = {
        type = "command";
        command = "~/.claude/scripts/claude-hud-statusline.sh";
      };
      permissions = {
        allow = lib.concatLists [
          (mkClaudePermissionList claude_tools.read [
            "*"
            "**/*.env.example"
            "**/*.env.tpl"
          ])
          (mkClaudePermissionList claude_tools.edit [
            "*"
            "**/*.env.example"
            "**/*.env.tpl"
          ])
          (mkClaudePermissionList claude_tools.bash [
            "git status"
            "git diff"
          ])
          mcp_tools.serena.basic
          mcp_tools.atlassian.issues
          mcp_tools.atlassian.confluence
        ];
        # ask = [];
        deny = lib.concatLists [
          (mkClaudePermissionList claude_tools.read sensitive_files.claude)
          (mkClaudePermissionList claude_tools.edit (sensitive_files.claude ++ lockfiles.claude))
          (mkClaudePermissionList claude_tools.bash global_bash.deny)
        ];
      };
    };
  };
}
