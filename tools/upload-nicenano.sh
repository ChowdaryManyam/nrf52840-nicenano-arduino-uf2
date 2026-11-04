#!/usr/bin/env bash
set -euo pipefail
HEX_FILE="$1"
UF2_FILE="$2"
CONVERTER="$3"

if [[ ! -f "$HEX_FILE" ]]; then
    echo "ERROR: Compiled HEX file not found: $HEX_FILE"
    exit 1
fi

echo "======================================"
echo "      nice!nano UF2 uploader"
echo "======================================"
echo "[1/3] Converting HEX to UF2..."
python3 "$CONVERTER" -f 0xADA52840 -c -o "$UF2_FILE" "$HEX_FILE"
if [[ ! -s "$UF2_FILE" ]]; then
    echo "ERROR: UF2 conversion failed."
    exit 1
fi

echo "[2/3] Waiting for NICENANO bootloader..."
echo "Enter bootloader mode now (double reset)."
echo "Waiting up to 60 seconds..."
MOUNT=""
for i in $(seq 1 60); do
    MOUNT="$(findmnt -rn -S LABEL=NICENANO -o TARGET | head -n 1 || true)"
    if [[ -n "$MOUNT" && -f "$MOUNT/INFO_UF2.TXT" ]]; then
        break
    fi
    MOUNT=""
    sleep 1
done
if [[ -z "$MOUNT" ]]; then
    echo "ERROR: NICENANO drive not detected."
    echo "Check the USB connection and bootloader mode."
    exit 1
fi

echo "Found bootloader at: $MOUNT"
echo "[3/3] Copying firmware..."
cp "$UF2_FILE" "$MOUNT/"
sync
echo "======================================"
echo "       UF2 upload completed!"
echo "======================================"
