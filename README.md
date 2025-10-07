# Peripheral Documentation: Iterative CORDIC Accelerator

Submitted By: [Apoorva Amargol](https://github.com/ApoorvaGithubAmargol) and [Vishal Srivatsava AV](https://github.com/bsod2528)
	

## 1. Overview and Rationale

The CORDIC (Coordinate Rotation Digital Computer) Accelerator is designed to offload the computationally intensive task of calculating sine and cosine functions from the main processor. By implementing the CORDIC algorithm in dedicated hardware, this peripheral provides deterministic, low-latency, and high-throughput trigonometric calculation.

This design emphasizes area efficiency (fitting within the ≈ 2K gate limit) through an iterative architecture, while still achieving excellent performance due to the fast clock speed of the SBC fabric.
Key Features

- Target Function: Vector Rotation Mode (Calculates cos(θ) and sin(θ)).

- Data Format: 32-bit angle input, 16-bit signed fixed-point calculation.

- Latency: Fixed at 17 clock cycles per result (1 initial cycle + 16 iteration cycles).

- Interface: Memory-mapped registers for command and data transfer.

## 2. Hardware Architecture and Implementation
### Iterative Design

The core uses a single datapath module (one set of adders/subtractors and shifters) controlled by a 5-bit counter (iter_cnt) and a simple FSM. This serialization ensures a minimum footprint in terms of gate count.

- IDLE State: Waiting for a bus write command to the Angle Register (ADDR_ANGLE).

- BUSY State (16 Cycles):
    - Initialize x, y, and z (angle input).

    - Iterate 16 times. The rotation shift operation (2−i) is implemented as a bit-shift (>>> iter_cnt), which is highly efficient combinational logic.

- DONE State: The done flag is set for one clock cycle, signaling the CPU that the results are ready.

### Performance Metric

The crucial performance metric is latency.

```sh
Latency=N iterations+1 setup cycle=16+1=17 clock cycles.
```

This fixed 17-cycle latency provides a predictable high-speed throughput (e.g., ≈340 ns at 50 MHz), which is a key advantage over variable-time software implementations, positioning this project strongly for the Best Performance Peripheral award.

## 3. Memory Map and Register Definition

The peripheral is memory-mapped to the SBC bus with a 6-bit address space. All registers are 32-bits wide.

| Address | Name | Access | Description
| --- | --- | --- | --- | 
| 6'h00 | ADDR_CTRL | Read | Status Register (Bit 0: done flag) |
| 6'h04 | ADDR_ANGLE | Write | Angle Input Register. Writing here starts the 17-cycle CORDIC calculation. |
| 6'h08 | ADDR_COS | Read | Cosine Output. Contains the cos(θ) result (sign-extended from 16-bit Q1.15). |
| 6'h0C | ADDR_SIN | Read | Sine Output. Contains the sin(θ) result (sign-extended from 16-bit Q1.15).

### Operation Flow
- Write Angle: CPU writes θ to ADDR_ANGLE. The peripheral asserts busy.
- Wait: CPU polls ADDR_CTRL until the done flag is set.
- Read Result: CPU reads cos(θ) and sin(θ) from the output registers.
- Ready: The peripheral clears done upon the next write to ADDR_ANGLE.