# nRF52840 nice!nano Arduino UF2 uploader (Linux)

A small Arduino IDE platform override that replaces serial-DFU upload with UF2 file copying for a nice!nano-compatible nRF52840 board running a UF2 bootloader.

## Tested setup

- Ubuntu Linux
- Arduino IDE 2.3.10 (AppImage)
- `nRFMicro-like Boards by pdcook`, version `1.0.2`
- Board: `nice!nano v2` (`nRFMicro:nrf52:nicenanov2`)
- UF2 bootloader reports Model `nice!nano`, Board-ID `nRF52840-nicenano`
- SoftDevice S140 6.1.1
- Linker script `nrf52840_s140_v6.ld`
- UF2 family ID `0xADA52840`

This is a tested configuration, not a universal uploader for every nRF52840 board. Verify your board's bootloader, flash layout and UF2 family before using it.

## What it does

Clicking **Upload** in Arduino IDE:
1. Compiles the sketch and creates an Intel HEX file.
2. Converts HEX to UF2 using the board package's `uf2conv.py`.
3. Waits up to 60 seconds for a volume labelled `NICENANO` containing `INFO_UF2.TXT`.
4. Copies the UF2 to that volume and runs `sync`.

You must manually enter bootloader mode during the wait prompt. On the tested board this was done by briefly shorting RST to GND twice quickly. Do not bridge VCC/RAW to GND.

## Files

- `boards.local.txt` — selects the custom uploader and selects the S140 v6 linker script.
- `platform.local.txt` — defines its upload command.
- `tools/upload-nicenano.sh` — conversion, detection and copy script.

The board package supplies `tools/uf2conv/uf2conv.py`; this repository does not replace it.

## Installation

1. Install `nRFMicro-like Boards by pdcook` version `1.0.2`.
2. Open the package directory:

   `~/.arduino15/packages/nRFMicro/hardware/nrf52/1.0.2/`

3. Back up existing files:

   ```bash
   cd ~/.arduino15/packages/nRFMicro/hardware/nrf52/1.0.2
   mkdir -p backup-before-uf2
   cp -a boards.txt platform.txt backup-before-uf2/
   [ ! -f boards.local.txt ] || cp -a boards.local.txt backup-before-uf2/
   [ ! -f platform.local.txt ] || cp -a platform.local.txt backup-before-uf2/
   ```

4. Copy this repository's `boards.local.txt` and `platform.local.txt` into that directory.
5. Copy `tools/upload-nicenano.sh` into the package's existing `tools/` directory.
6. Make it executable:

   ```bash
   chmod +x tools/upload-nicenano.sh
   ```

7. Select **nice!nano v2** and **S140 6.1.1** in Arduino IDE's Tools menu.
8. Restart Arduino IDE.

The supplied `boards.local.txt` sets `nicenanov2.build.ldscript=nrf52840_s140_v6.ld`, so you do not need to edit the package's `boards.txt`.

## Usage

1. Open a sketch and click **Upload**.
2. When the console says `Enter bootloader mode now (double reset)`, enter UF2 bootloader mode.
3. The script detects `NICENANO`, copies the UF2 and reports completion.

If the volume is not detected, the script stops without copying firmware.

## Safety and limitations

- Never replace or delete `CURRENT.UF2`; it belongs to the bootloader volume.
- The uploader copies only the generated application UF2.
- Do not use this on another board/bootloader without verifying its memory map and UF2 family ID.
- Keep a backup of original package files.
- Package updates may overwrite or stop honoring local overrides; recheck after updating.
- Tested on the setup listed above; other Linux distributions/package versions may need changes.

## Restore

Remove the local overrides and custom script:

```bash
cd ~/.arduino15/packages/nRFMicro/hardware/nrf52/1.0.2
rm -f boards.local.txt platform.local.txt
rm -f tools/upload-nicenano.sh
```

This removes the custom UF2 uploader and returns the package to its default upload setting. The original S140 v7 board definition remains unchanged because the v6 linker choice was supplied through `boards.local.txt`. Restart Arduino IDE.

## License

MIT. See `LICENSE`.
