
                 
                 V   Y   O   M   M   E   D   H   A    S   o   C
                  ---------------------------------------------

                 Vyommedha SoC — An Open-Source FPGA CPU Initiative




# 🌌 Vyommedha SoC

Vyommedha SoC is a community-driven initiative to design, build, and deploy **System-on-Chip (SoC)** on FPGA boards using the **LiteX framework** and **VexRiscv CPU**.
Our first hardware platform is the **DE0-Nano FPGA**, where we have successfully deployed a basic SoC and tested firmware with the **Knight Rider LED pattern** 🚦.

---

## 📂 Repository Contents

* **`base.py`** → Main SoC description (CPU, memory, LEDs, switches, UART integration).
* **`ios.py`** → Peripheral definitions (LEDs, switches, buttons).
* **`pwm.py` / `tick.py` / `display.py`** → Example peripheral modules.
* **`firmware/`** → Application firmware (C code and linker files).
* **`test/`** → Python test scripts (e.g., LED tests, identifier).
* **`prog/` / `openocd_cfg/`** → Programming and JTAG/UART configuration.
* **`build/`** → Auto-generated build files (SoC gateware, software, CSR map).

---

## 🚀 Running on FPGA (DE0-Nano)

### 1. Clone and set up LiteX

```bash
git clone https://github.com/enjoy-digital/litex.git
cd litex
./litex_setup.py init install --user
```

### 2. Build the SoC

Inside the `Vyommedha` directory:

```bash
python3 base.py
```

This generates the FPGA bitstream and software build files inside `build/`.

### 3. Program the FPGA

```bash
./load.py
```

### 4. Run the Firmware

Open UART terminal and upload firmware:

```bash
litex_term /dev/ttyUSBx --speed 115200 --kernel firmware/firmware.bin
```

If successful, you should see the **BIOS boot messages** followed by your firmware (e.g., **Knight Rider LED animation**).

---

## 🛠️ How to Contribute Peripherals

Vyommedha SoC is designed to be **modular and extensible**. You can easily add your own peripherals!

### 1. Define the Peripheral

Add your peripheral logic in a new file (e.g., `my_peripheral.py`) using **Migen/LiteX modules**:

```python
from migen import *
from litex.soc.interconnect.csr import *

class MyPeripheral(Module, AutoCSR):
    def __init__(self):
        self._control = CSRStorage(8)   # write register
        self._status  = CSRStatus(8)    # read register

        # Example: loopback
        self.comb += self._status.status.eq(self._control.storage)
```

### 2. Integrate into SoC

Edit `base.py`:

```python
from my_peripheral import MyPeripheral

self.submodules.myperiph = MyPeripheral()
self.add_csr("myperiph")
```

### 3. Rebuild and Test

```bash
python3 base.py
./load.py
```

In software (`main.c` or tests), you can now use:

```c
myperiph_control_write(0x55);
printf("status = %02x\n", myperiph_status_read());
```

---

## 🙌 Supporters & Mentors

We deeply thank our **mentors, contributors, and community members** who supported Vyommedha SoC:

* [Enjoy-Digital / LiteX](https://github.com/enjoy-digital/litex)
* Our mentors from academia & industry who guided us on FPGA toolchains and SoC design.
* The open-source hardware community that keeps inspiring us.

---

## 🌍 Learn More

👉 Visit our website: [**Vyommedha Official Website**](https://vyommedha.org)
👉 Follow updates on [LinkedIn](https://linkedin.com)

---

## 📢 Call for Contributions

This is just the beginning. 🚀
We welcome **students, hobbyists, and professionals** to collaborate on:

* Expanding SoC peripherals
* Adding new FPGA platform support
* Firmware + software development
* Documentation & tutorials

Together, let’s build **India’s open-source hardware ecosystem** 🇮🇳✨

---

Would you like me to also include a **ready-made template peripheral** (like a GPIO example) in the repo so new contributors can just copy-paste and modify?
