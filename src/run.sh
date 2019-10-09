riscv32-unknown-elf-gcc -nostdlib dm_rom.S -Ttext=0x0 -Tdata=0x200 -e0x0 -o /tmp/a.out
riscv32-unknown-elf-objdump -d /tmp/a.out > dm_rom.lst
riscv32-unknown-elf-objcopy -O verilog /tmp/a.out dm_rom.hex
