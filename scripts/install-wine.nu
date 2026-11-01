# Install a Wine macOS build from the Gcenx release list into $WINE_ROOT, after checking the
# release asset's sha256 digest. Usage: nu scripts/install-wine.nu 11.18 [devel|staging]
def main [version: string, flavor: string = "devel"] {
  let root = ($env.WINE_ROOT? | default $"($env.HOME)/.cache/win64-mac-host/wine")
  let name = $"wine-($flavor)-($version)-osx64.tar.xz"
  mkdir $root
  let release = (http get $"https://api.github.com/repos/Gcenx/macOS_Wine_builds/releases/tags/($version)")
  let asset = ($release.assets | where name == $name)
  if ($asset | is-empty) { error make {msg: $"no asset ($name) in release ($version)"} }
  let url = ($asset | first | get browser_download_url)
  let digest = ($asset | first | get digest? | default "" | str replace "sha256:" "")
  if ($digest | is-empty) { error make {msg: $"release gives no digest for ($name)"} }
  cd $root
  ^curl -sfLO $url
  let got = (open --raw $name | hash sha256)
  if $got != $digest { error make {msg: $"digest mismatch for ($name): ($got) != ($digest)"} }
  print $"($name): OK"
  ^tar -xJf $name
  ^xattr -dr com.apple.quarantine . | ignore
  let wine = (wine-path $root $flavor)
  ^$wine --version
}

def wine-path [root: string, flavor: string] {
  let app = if $flavor == "staging" { "Wine Staging.app" } else { "Wine Devel.app" }
  $"($root)/($app)/Contents/Resources/wine/bin/wine"
}
