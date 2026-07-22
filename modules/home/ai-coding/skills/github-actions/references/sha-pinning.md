## Getting a release SHA

Use the script in `scripts/sha-pinning.md` to get a list of release SHAs and versions.

Usage:

```bash
# Prints out release SHAs and versions in reverse alphabetical order by tag
scripts/sha-pinning.sh actions/checkout

# Output:
# 3d3c42e5aac5ba805825da76410c181273ba90b1        refs/tags/v7.0.1
# 9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0        refs/tags/v7.0.0
# d23441a48e516b6c34aea4fa41551a30e30af803        refs/tags/v6.1.0
# 9f698171ed81b15d1823a05fc7211befd50c8ae0        refs/tags/v6.0.3
# de0fac2e4500dabe0009e67214ff5f5447ce83dd        refs/tags/v6.0.2
# ...
```
