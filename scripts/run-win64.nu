# Run a win64 build under Wine on this Mac, through Rosetta 2. Usage:
#   nu scripts/run-win64.nu <build dir> <log> <exe> [app args...]
# The build draws in a real window on the GPU: Vulkan goes through Wine's winevulkan to MoltenVK
# and Metal. The log ends with a line "EXIT <code>".
def main [dir: string, log: string, exe: string, ...args: string] {
  let root = ($env.WINE_ROOT? | default $"($env.HOME)/.cache/win64-mac-host/wine")
  let wine = $"($root)/Wine Devel.app/Contents/Resources/wine/bin/wine"
  if not ($wine | path exists) { error make {msg: $"no wine at ($wine); run install-wine.nu first"} }
  with-env {
    WINEPREFIX: $"($root)/prefix"
    WINEDEBUG: "-all"
    WINEDLLOVERRIDES: "mscoree,mshtml="
  } {
    cd $dir
    let r = (^$wine $exe --rendering-driver vulkan --fixed-fps 60 -- ...$args | complete)
    ($r.stdout + $r.stderr + $"EXIT ($r.exit_code)\n") | save --force $log
  }
}
