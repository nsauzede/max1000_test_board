
rem cd software\test_tei0001_bsp
rem c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --wait --run "niosv-bsp --create --type=hal --sopcinfo=../../quartus/NIOS_test_board.sopcinfo --script=hal_bsp.tcl ./settings.bsp"
rem cd ..\..

cd software/test_tei0001
del test_tei0001.bin
del build\test_tei0001.elf
del build\test_tei0001.srec
rem c:/intelfpga_lite/22.1std/niosv/bin/niosv-app --app-dir=./ --bsp-dir=../test_tei0001_bsp --incs=./ --srcs=./main.c --elf-name=test_tei0001.elf
rem c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --wait --run "cmake -S ./ -B ./build -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release "
c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --wait --run "make -C ./build"
c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --wait --run "elf2flash --input build/test_tei0001.elf --output build/test_tei0001.srec --reset 0x00800000 --base 0x800000 --end 0x1000000 --boot c:/intelfpga_lite/22.1std/quartus/../niosv/components/bootloader/niosv_bootloader.srec"
c:/intelfpga_lite/22.1std/niosv/bin/niosv-shell --run " riscv32-unknown-elf-objcopy --input-target srec --output-target binary build/test_tei0001.srec test_tei0001.bin "
cd ..\..

c:\intelFPGA_lite\22.1std\quartus\bin64\quartus_pgm --cable=Arrow-USB-Blaster --mode=jtag --operation=p;misc\d2xx_spi_flash_programmer\max1000_flash.sof
misc\d2xx_spi_flash_programmer\d2xx_spi_flash_programmer_1.0.exe --channel=B --program --verify --file=software\test_tei0001\test_tei0001.bin
