MazuV-debug-system is an implement of RISC-V debug module.

A pure CPU can work well alone. But it’s not easy to locate problem in software. A debug module in soc can provide functions like making cpu halt, set breakpoints, etc. It helps programmer to find bugs in program or profile performance.

MazuV-debug-system is a debug system base on Risc-V debug spec 0.13 written in Verilog. Though it is a basic implementation, it can connect to picorv32 project and work on Openocd+GDB.

The demo is at: https://hackmd.io/AaQbx7X0RCeZTxcaugB9iw?view
