{
  programs.ruff = {
    enable = true;
    settings = {
      line-length = 80;
      indent-width = 4;

      lint = {
        select = [
          # pycodestyle
          "E"
          # Pyflakes
          "F"
          # pyupgrade
          "UP"
          # flake8-bugbear
          "B"
          # flake8-simplify
          "SIM"
          # isort
          "I"
          # fastapi
          "FAST"
        ];

        extend-select = ["E501"];

        isort.known-first-party = ["api" "tests"];

        dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$";
      };

      format = {
        docstring-code-format = true;
        docstring-code-line-length = "dynamic";
      };
    };
  };
}
