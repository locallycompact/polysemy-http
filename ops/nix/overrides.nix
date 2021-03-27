inputs:
{
  hackage,
  ...
}:
self: super:
let
  inherit (hackage) pack cabal2nixNoHpack subPkg subPkgNoHpack github;

  versions = [
    (pack "servant" "0.18" "1mwwqn012kwjigckka6msiwpxp8wracc55nk01y6hj9n8ndmnrm5")
    (pack "servant-client" "0.18" "0q8l3s92cg3d1350xx1fpz5z3z2wg61iyzg35gzw4yqwwi78k3fb")
    (pack "servant-client-core" "0.18" "1id3rjixdshlj57cdl1zxrrf2h8idvmcb2grlskxiq444iwc7alp")
    (pack "servant-server" "0.18" "0h4nkxxi5r0y1883ixlmirnx2avl666x2nid4lqgkzwsk0cjrbpm")
  ];
  versionOverrides = builtins.listToAttrs versions;

  custom = {
    co-log-polysemy = subPkg "co-log-polysemy" "co-log-polysemy" inputs.co-log;
    polysemy = cabal2nixNoHpack "polysemy" inputs.polysemy;
    polysemy-plugin = subPkgNoHpack "polysemy-plugin" "polysemy-plugin" inputs.polysemy;
    polysemy-log = subPkg "packages/polysemy-log" "polysemy-log" inputs.polysemy-log;
    polysemy-time = subPkg "packages/time" "polysemy-time" inputs.polysemy-time;
  };
in
  versionOverrides // custom
