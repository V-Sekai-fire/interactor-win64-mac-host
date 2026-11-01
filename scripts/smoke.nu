# Smoke test: Wine starts under Rosetta 2 and runs a win64 command. The control plants a command
# that must fail: a run that cannot fail proves nothing.
def main [] {
  let root = ($env.WINE_ROOT? | default $"($env.HOME)/.cache/win64-mac-host/wine")
  let wine = $"($root)/Wine Devel.app/Contents/Resources/wine/bin/wine"
  if not ($wine | path exists) { error make {msg: "run install-wine first"} }
  with-env {WINEPREFIX: $"($root)/prefix", WINEDEBUG: "-all", WINEDLLOVERRIDES: "mscoree,mshtml="} {
    let ok = (^$wine cmd /c "echo win64-ok" | complete)
    let bad = (^$wine cmd /c "exit 7" | complete)
    let pass = ($ok.exit_code == 0) and ($ok.stdout | str contains "win64-ok")
    let control = ($bad.exit_code == 7)
    print $"run: (if $pass { 'PASS' } else { 'FAIL' })"
    print $"control: (if $control { 'PASS, the planted failure was seen' } else { 'FAIL, a failing command read as success' })"
    if not ($pass and $control) { exit 1 }
  }
}
