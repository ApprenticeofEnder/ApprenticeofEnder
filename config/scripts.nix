{
  pkgs,
  config,
  ...
}: {
  scripts = {
    hello = {
      packages = with pkgs; [chafa];
      description = "  👋 Show the Devenv logo art and a friendly greeting";
      exec = ''
        echo "👋🧩"
      '';
    };
    doctor = {
      packages = with pkgs; [
        figlet
        shellspec
      ];

      description = " 💊 Run Microdoctor health-check suite with docs output";
      exec = ''
        figlet -cf slant "💊 Microdoctor";
        shellspec -c "${config.env.DEVENV_ROOT}/tests" --quiet "$@";
      '';
    };

    kernel = {
      description = " 🎉 Fire up the Microvisor Kernel";
      exec = ''
        process-compose
      '';
    };

    console = {
      description = "🕹  Fire up the Microvisor Console";
      exec = ''
        ttyd --writable --browser --url-arg --once process-compose
      '';
    };

    di = {
      description = "      ⌨ Reload devenv";
      exec = "set -ex; direnv reload";
    };

    dn = {
      description = "     💥 Nuke & reload devenv";
      exec = "set -ex; git clean -fdX -e '!.env*'";
    };

    clean = {
      description = "  🧽 Remove all files matched by .gitignore (except any .env*)";
      exec = "set -ex; git clean -fdX -e '!.env*' -e '!.devenv*' -e '!.direnv*'";
    };

    nuke = {
      description = "   🚨 Remove all files matched by .gitignore, including .env*";
      exec = ''
        sudo git clean -fdX
      '';
    };

    yls = {
      description = "   GET BACK HERE yOU lITTLE sHIT!";
      exec = ''
        function divider(){
          echo "---------------------------------------"
        }

        TARGET="$1"

        which $TARGET

        divider

        where $TARGET

        divider

        brew list | grep $TARGET

        divider

        apt list | grep $TARGET
      '';
    };
  };
}
