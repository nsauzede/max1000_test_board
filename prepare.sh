#!/bin/bash

Q="${HOME}/intelFPGA_lite/22.1std"
if [ ! -f "$Q/niosv/components/bootloader/niosv_bootloader.srec" ]; then
echo "ERROR: Quartus/niosv at $Q doesn't have required niosv_bootloader.srec"
echo "If using an upgraded Quartus version, a workaround could be to link niosv/components/bootloader/niosv_m_bootloader.srec to niosv/components/bootloader/niosv_bootloader.srec"
exit 1
fi

./reflashbin.sh || exit 1

mkdir -p prebuilt/DBC83/hardware
cp -f quartus/NIOS_test_board.sopcinfo prebuilt/DBC83/hardware/NIOS_test_board.sopcinfo
mkdir -p prebuilt/DBC83/programming_files
cp -f quartus/output_files/test_board.pof prebuilt/DBC83/programming_files/test_board-DBC83.pof
mkdir -p prebuilt/DBC83/software
cp -f software/test_tei0001/test_tei0001.bin prebuilt/DBC83/software/test_tei0001.bin
cp -f software/test_tei0001/build/test_tei0001.elf prebuilt/DBC83/software/test_tei0001.elf
