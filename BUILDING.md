# Building Scribe

## Requirements

- macOS 14.4 or later
- Xcode with Command Line Tools
- Git

## Local Build

```bash
make local
open ~/Downloads/Scribe.app
```

`make local` prepares `whisper.xcframework` in `~/Scribe-Dependencies`, builds in `.local-build`, and copies `Scribe.app` to `~/Downloads`.

It uses `LocalBuild.xcconfig`, `Scribe.local.entitlements`, and the `LOCAL_BUILD` Swift flag. Without an override, it uses the only available Apple Development identity or falls back to ad-hoc signing when none or multiple are found.

Choose an identity explicitly:

```bash
make local LOCAL_CODESIGN_IDENTITY="<SHA or name>"
```

Force ad-hoc signing:

```bash
make local LOCAL_CODESIGN_IDENTITY=-
```

Local builds do not include iCloud dictionary sync or automatic updates. Ad-hoc builds may require macOS permissions again after rebuilding. Normal project Debug and Release settings are unchanged.

## Other Commands

- `make check` — verify required tools
- `make whisper` — prepare `whisper.xcframework`
- `make build` — build the standard Debug configuration
- `make dev` — build and launch the app
- `make run` — launch `~/Downloads/Scribe.app`, or the first app found in DerivedData
- `make clean` — remove `~/Scribe-Dependencies`
- `make help` — list all commands

## Build with Xcode

```bash
make setup
open Scribe.xcodeproj
```

Select the `Scribe` scheme and use the Debug configuration. Xcode uses the project’s normal signing settings; `LOCAL_BUILD` applies only through `make local`.

## Troubleshooting

- Run `make check` to verify the required tools.
- Run `make whisper` if the framework is missing.
- If several Apple Development identities exist, set `LOCAL_CODESIGN_IDENTITY` explicitly.
- If Xcode refuses to run the `mlx-swift` build plugin, confirm the `-skipPackagePluginValidation` flag is still present in the Makefile's `local` target.
