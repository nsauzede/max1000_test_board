#!/bin/bash

#rem cd software\test_tei0001_bsp
#rem c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --wait --run "niosv-bsp --create --type=hal --sopcinfo=../../quartus/NIOS_test_board.sopcinfo --script=hal_bsp.tcl ./settings.bsp"
#rem cd ..\..

cp source_files/software/test_tei0001/main.c software/test_tei0001/main.c

cd software/test_tei0001
rm test_tei0001.bin
rm build\test_tei0001.elf
rm build\test_tei0001.srec
#rem c:/intelfpga_lite/22.1std/niosv/bin/niosv-app --app-dir=./ --bsp-dir=../test_tei0001_bsp --incs=./ --srcs=./main.c --elf-name=test_tei0001.elf
#rem c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --wait --run "cmake -S ./ -B ./build -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release "
~/intelFPGA_lite/22.1std/niosv/bin/niosv-shell --wait --run "make -C ./build"
~/intelFPGA_lite/22.1std/niosv/bin/niosv-shell --wait --run "elf2flash --input build/test_tei0001.elf --output build/test_tei0001.srec --reset 0x00800000 --base 0x800000 --end 0x1000000 --boot ${HOME}/intelFPGA_lite/22.1std/niosv/components/bootloader/niosv_bootloader.srec"
~/intelFPGA_lite/22.1std/niosv/bin/niosv-shell --run " riscv32-unknown-elf-objcopy --input-target srec --output-target binary build/test_tei0001.srec test_tei0001.bin "
cd ../..

#exit 0

~/intelFPGA_lite/22.1std/quartus/bin/quartus_pgm --cable=Arrow-USB-Blaster --mode=jtag --operation="p;misc/d2xx_spi_flash_programmer/max1000_flash.sof"
cp -f software/test_tei0001/test_tei0001.bin software/test_tei0001/test_tei0001.bin.orig
truncate -s 8388608 software/test_tei0001/test_tei0001.bin

flashrom --programmer ft2232_spi:type=2232H,port=B,divisor=4 -c "W25Q64BV/W25Q64CV/W25Q64FV" --write software/test_tei0001/test_tei0001.bin

if [ -f quartus/output_files/test_board.sof ]; then
~/intelFPGA_lite/22.1std/quartus/bin/quartus_pgm --cable=Arrow-USB-Blaster --mode=jtag --operation="p;quartus/output_files/test_board.sof"
fi
