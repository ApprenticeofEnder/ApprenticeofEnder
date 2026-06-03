{...}: {
  imports = map (agent: ./${agent}) [
    # keep-sorted start
    "count"
    "fencer"
    "huxian"
    "jaeger"
    "lanza"
    "skald"
    "tabloid"
    "tailor"
    "trigger"
    "wiseman"
    # keep-sorted end
  ];
}
