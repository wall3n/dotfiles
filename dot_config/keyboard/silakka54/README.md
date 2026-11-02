# silakka54 keymap

The keyboard stores this keymap in its own memory. Use this folder only to write the keymap again, for example after a firmware flash.

1. Quit Vial. Vial locks the keyboard while it is open.
2. Run the script:

   ```sh
   cd ~/.config/keyboard/silakka54 && uv run --with hidapi python apply.py
   ```

The script writes 4 layers and Permissive Hold, then reads the layers back. It targets a macOS Spanish-ISO host.

`keymap_factory_backup.json` holds the keymap from before this setup. `def.json` is the Vial definition read from the board.

If you change `apply.py`, also change `KEYMAP` in the split-trainer `index.html`.
