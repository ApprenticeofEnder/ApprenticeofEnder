{lib, ...}: {
  toYaml = data: lib.generators.toYAML {} data;
}
