#!/bin/bash
# Build HakiOS's U-Boot for one device: u-boot/ (made by apply.sh) with configs/hakios_<device>_defconfig, into
# u-boot/build-<device>/u-boot.bin: an AArch64 image with Linux's header, which ABL starts like a kernel.
#
#   uefi/u-boot/build.sh DEVICE
#
# CROSS_COMPILE: an AArch64 GCC (aarch64-linux-gnu-, or Arm's aarch64-none-elf-); found on PATH when not given.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)     # not resolved: uefi/ may be a link to a checkout elsewhere
ROOT=$(dirname "$(dirname "$HERE")")
UB=${U_BOOT:-$ROOT/u-boot}
dev=${1:?usage: build.sh DEVICE}
[ -d "$UB" ] || { echo "u-boot/build.sh: no $UB (uefi/u-boot/apply.sh first)" >&2; exit 1; }
[ -f "$UB/configs/hakios_${dev}_defconfig" ] || { echo "u-boot/build.sh: no hakios_${dev}_defconfig in $UB" >&2; exit 1; }
if [ -z "$CROSS_COMPILE" ]; then
	for c in aarch64-linux-gnu- aarch64-none-elf- aarch64-elf-; do
		command -v "${c}gcc" >/dev/null && { CROSS_COMPILE=$c; break; }
	done
	[ -n "$CROSS_COMPILE" ] || { echo "u-boot/build.sh: no AArch64 GCC on PATH (CROSS_COMPILE=...)" >&2; exit 1; }
fi
out=$UB/build-$dev
make -C "$UB" -s O="$out" CROSS_COMPILE="$CROSS_COMPILE" "hakios_${dev}_defconfig"
make -C "$UB" -s O="$out" CROSS_COMPILE="$CROSS_COMPILE" -j"$(nproc)"
ls -la "$out/u-boot.bin"
