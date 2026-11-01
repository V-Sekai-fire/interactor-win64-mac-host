# interactor-win64-mac-host

Runs our win64 build on an Apple-silicon Mac, so a test there goes through the same kind of
translation layer as on the Steam Frame and the Steam Deck. The tools come from pixi, not Homebrew.

## Routes

| Route | What runs | State |
| --- | --- | --- |
| Wine under Rosetta 2 | a Wine macOS build from the Gcenx releases runs the win64 exe. Vulkan goes through Wine's winevulkan to MoltenVK and Metal | runs: the smoke test passes with its control |
| FEX and Proton in a small VM | Valve's ARM64 SteamOS in a libkrun VM (the steamac app, Hypervisor.framework, no QEMU) with Valve's FEX and Proton inside | not tried for our build |

The first route is the Mac's stand-in. The second is the closer match to the Frame, since it runs
the same FEX and Proton as the headset.

## Use

```sh
pixi install
pixi run install-wine 11.18        # downloads the release and checks its sha256 digest
pixi run smoke                     # Wine starts and runs a win64 command, and a planted failure is seen
pixi run run-win64 <build dir> <log> <exe> [app args]
```

`run-win64` passes `--rendering-driver vulkan --fixed-fps 60`, so a run draws in a real window on
the GPU and repeats from run to run. The log ends with `EXIT <code>`. Read the log for the Vulkan
device line: it must name the Apple GPU, or the run is not a GPU test.

## Measured

On an Apple M2 Pro, macOS 26.6.2, Wine 11.18 (an x86_64 binary under Rosetta 2): `smoke` prints
`run: PASS` and `control: PASS`. No win64 game build has run yet, so no frame time is claimed.

## Not done

- The second route. It needs the steamac app and a SteamOS image.
- A launch script for the Frame itself. The Frame was unreachable when this repo was made.
- Pinning the Wine release in the repo manifest.

MIT licence.
