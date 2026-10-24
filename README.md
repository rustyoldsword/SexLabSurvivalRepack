# SexLab Survival Repack — source

Source code of the **SexLab Survival Repack** (SL Survival 0.716 based, adult 18+ mod for Skyrim Special Edition /
Anniversary Edition). The playable repack — plugins, compiled scripts, the SKSE DLL, textures and voice files — is
distributed as a release archive; this repository holds only the source and the tools used to build it.

SexLab Survival was created by **Monoman1**; the 0.716 base this repack builds on is maintained by **crajjjj**
(<https://github.com/crajjjj/SLSurvival>). The repack's changes are released here with the permission of the
original authors.

## What is in the repack

- **Integration and fix patch** for SL Survival 0.716: SexLab P+ (2.18 and 2.19 interaction API), Creation Club
  Survival Mode / Survival Mode Improved, WetFunction NG, SLSF Reloaded, SlaveTats NG, a script audit with fixes,
  a cleaned plugin, faster licence issuing, a male-player gate, calmer Steep Fall drops and more.
- **SexLab Survival Framework** — an SKSE plugin (CommonLibSSE-NG) that takes the heaviest Papyrus work off the
  script engine: town gates, the equip hub, nudity checks, guard searches, follower counting, the HUD export and a
  message feed.
- **Hopeless Escorts** — six spawned, mostly useless escorts that the guards hand out, or that the toll collector
  lets you pick from a list, with situational idle chatter, combat lines and their own dialogue.

## Layout

| Folder | Contents |
|---|---|
| `papyrus/patches` | The integration patch: edited SL Survival scripts and new adapters (`_SLS_Int*`) |
| `papyrus/slpp-2.19` | `_SLS_IntSlpp` for the SexLab P+ 2.19 interaction API |
| `papyrus/framework` | Scripts the framework overrides to route work into the DLL (`SLSFW` is its native API) |
| `papyrus/escorts` | Dialogue fragments of the Hopeless Escorts |
| `papyrus/stubs` | Compile-time stubs for third-party scripts that the Papyrus compiler cannot parse; never shipped |
| `framework` | The SKSE plugin: `src`, `xmake.lua`, FOMOD and packaging/verification scripts |
| `tools` | Generators and helpers: plugin/condition patchers (houseCARL manifests), the escort dialogue generator, the repack builder, `.pex` comparison/disassembly tools |
| `docs` | READMEs of the individual parts as they ship in the mod |

## Building

**Papyrus.** The Creation Kit's `PapyrusCompiler.exe` with `TESV_Papyrus_Flags.flg`. The import path is, in order:
the folder being compiled, `papyrus/patches`, `papyrus/stubs`, the SL Survival 0.716 sources (`scripts/source` of the
upstream repository and the dependency folders listed in its `skyrimse.ppj`), then SKSE and vanilla script sources.
`tools/integration/build.ps1` and `framework/tools/build_papyrus.ps1` do exactly this; set the paths at their top
to your installation (they default to `C:\Modding\MO2`).

**Framework DLL.** xmake 3 and MSVC (C++23). Clone CommonLibSSE-NG (alandtse, branch `ng`, release 4.39.2,
commit `e60c1238`) into `framework/lib/CommonLibSSE-NG`, then in `framework`:

```
xmake f -m releasedbg --skyrim_vr=n
xmake build SLSurvivalFramework
```

`framework/tools/package.ps1` assembles the mod folder with a SHA-256 manifest; `framework/tools/verify.ps1` checks an
installed copy against it.

**Tools.** Python 3. Paths are constants at the top of each script. The repack builders scan their output for
private strings listed in the `LEAK_PATTERNS` environment variable (a regular expression).

## License

The framework (`framework/`), the escort scripts and generators, and the tools are MIT-licensed (see `LICENSE`).
The SL Survival scripts in `papyrus/patches`, `papyrus/slpp-2.19` and `papyrus/framework` are modified versions of
the original mod's scripts and remain the work of their authors; they are published here as part of the repack
with their permission.
