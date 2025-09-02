#!/usr/bin/env python3
import os
import pathlib

# Path to your SOF file
sof_file = pathlib.Path("./build/gateware/top.sof")

if not sof_file.exists():
    raise FileNotFoundError(f"Bitstream not found: {sof_file}")

# Quartus Programmer command for USB-Blaster
cmd = f"quartus_pgm -m jtag -o \"p;{sof_file}\""

print(f"[INFO] Programming FPGA with {sof_file} ...")
ret = os.system(cmd)

if ret != 0:
    print("[ERROR] quartus_pgm failed.")
else:
    print("[INFO] Programming succeeded.")

