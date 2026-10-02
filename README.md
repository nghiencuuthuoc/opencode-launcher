# OpenCode Launcher + Free Model Updater

Files:

- `opencode_launcher.bat` — launcher; Enter on folder uses launcher folder; Normal permission mode is default; Muse is default.
- `update_opencode_models.py` — retrieves current model IDs from the official OpenCode models API and writes the free list to Markdown.
- `opencode_model.md` — human-readable and BAT-parseable model list.
- `opencode_launcher_original.bat` — backup of the uploaded launcher before this update.

## Use

1. Put the files in the same folder.
2. Run `opencode_launcher.bat`.
3. At the model menu:
   - press Enter for Muse Spark 1.3 Contributor Free;
   - enter a number to select another free model;
   - enter `U` to refresh the list from the official OpenCode web API;
   - enter `C` to type any custom provider/model ID.
4. Permission mode remains non-auto by default. Select option 2 to add `--auto`.

## Update from command line

Run:

    python update_opencode_models.py

No third-party Python package is required (Python 3.8+ standard library only).

## Failure behavior

The updater uses an atomic replacement. If network/API/parsing fails, it does not overwrite the last known good `opencode_model.md`, so the BAT launcher can continue using the cached list.
