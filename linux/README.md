# Linux

Tools and setup for Linux workflow.

## Wine Prefix

Create a dedicated Wine prefix for the modding tools. This keeps everything isolated from your system Wine configuration.

```bash
export WINEPREFIX=/path/to/your/wineprefix
wineboot
```

The prefix needs two .NET runtimes installed via [winetricks](https://github.com/Winetricks/winetricks):

```bash
winetricks dotnetdesktop8   # for FileMonolith tools
winetricks dotnet461        # for SnakeBite/MakeBite
```

## Directory Structure

We recommend placing the downloaded tools alongside the repo, so everything is accessible under one parent directory:

```
metalgirlsolidv/
├── mgsv/                  # this repo
├── wineprefix/            # Wine prefix
├── FileMonolith.win-x64/  # Archive Unpacker, Mass Texture Converter
└── FtexTool v0.4.0/       # FtexTool
```

The `M:` Wine drive maps to this parent directory, which means the tools, the repo, and any output from FileMonolith (like `UnpackedFiles/` and `ConvertedTextures/`) are all reachable from the same drive letter. This keeps Wine path references simple and avoids scattering files across the filesystem.

## Tool Downloads

- [FileMonolith](https://github.com/BobDoleOwndU/FileMonolith) — Archive Unpacker and Mass Texture Converter for Fox Engine archives and textures.
- [FtexTool](https://github.com/BobDoleOwndU/FtexTool) — Converts between .ftex/.ftexs and .dds formats.
- [SnakeBite Mod Manager](https://www.nexusmods.com/metalgearsolidvtpp/mods/106) — Installs mods into the game. Includes MakeBite for building .mgsv mod packages.

SnakeBite's installer will place itself at `%LOCALAPPDATA%\SnakeBite` inside your Wine prefix (i.e. `$WINEPREFIX/drive_c/users/$USER/AppData/Local/SnakeBite`). Run it once through Wine to complete setup — it will ask for your game installation path.

MakeBite needs dictionary files in the repo directory (the same level as `mod/`). Copy them from the SnakeBite directory:

```bash
cp "$WINEPREFIX/drive_c/users/$USER/AppData/Local/SnakeBite/"*dictionary* /path/to/mgsv/
```

These files are gitignored.

## Drive Letter Mappings

The modding tools expect Windows-style drive letters. Create symlinks in the Wine prefix to map your game directory and project directory:

```bash
ln -s /path/to/Steam/steamapps/common/MGS_TPP "$WINEPREFIX/dosdevices/g:"
ln -s /path/to/this/repo/parent "$WINEPREFIX/dosdevices/m:"
```

With these mappings, `G:` points to the game installation and `M:` points to the parent directory containing this repo. SnakeBite setup should use `G:\` as the game path.

## Configuration

Copy the config template and fill in your paths:

```bash
cd linux/
cp tools.conf.example tools.conf
```

Edit `tools.conf` with the paths to your Wine prefix, game directory, and tool locations. The file is gitignored so your local paths won't be committed.

## Scripts

All scripts live in `linux/` and source `tools.conf` for paths.

**tools.sh** launches modding tools through Wine. Run it with no arguments for an interactive menu, or pass an exe path directly:

```bash
./tools.sh                        # interactive menu
./tools.sh /path/to/tool.exe      # run a specific tool
```

**build.sh** builds the mod from `mod/` using MakeBite, then installs it into the game with SnakeBite:

```bash
./build.sh
```

**ftex.sh** converts .ftex files to .dds and vice versa. It's designed to be used as a file handler from your desktop environment's "Open With" menu, but also works from the command line:

```bash
./ftex.sh /path/to/file.ftex
./ftex.sh /path/to/file.dds
```

To register it as a file handler, create a `.desktop` file at `~/.local/share/applications/ftextool.desktop` pointing to the script, and add MIME type definitions for .ftex and .dds files at `~/.local/share/mime/packages/ftex.xml`.

## Troubleshooting

Wine produces a lot of `fixme:` messages on stderr. The scripts filter these out of terminal output, but they're preserved in log files under `linux/logs/` for debugging.
