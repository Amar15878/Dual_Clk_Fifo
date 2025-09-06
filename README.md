## Dual Clock FIFO (SystemVerilog)

# Overview
This module implements a dual-clock asynchronous FIFO for transferring data between independent write and read clock domains. 
It uses:
+ Binary pointers converted to Gray code to ensure safe cross-domain synchronization.
+ Two-flop synchronizers to mitigate metastability when passing pointer values between domains.
+ A one-slot-empty policy for full and empty flag generation.
+ EDA Playground Link: https://edaplayground.com/x/ZGij

# Features
Parameterizable data width (DATA_WIDTH) and FIFO depth (ADDR_WIDTH → depth = 2^ADDR_WIDTH).
Independent write and read clocks with their own resets.
Safe handling of asynchronous domains using Gray-coded pointers.

#Flags:
+ full_o: Asserted when the FIFO cannot accept more writes.
+ empty_o: Asserted when there is no data to read.

# Usage
+ Drive wr_en_i and wr_data_i with the write clock to enqueue data.
+ Drive rd_en_i with the read clock to dequeue data onto rd_data_o.
+ Reset signals (wr_rst_i, rd_rst_i) should be asserted long enough in both domains before normal operation.

# Simulation
+ A sample testbench toggles independent write/read clocks and pushes a small burst of data to demonstrate correct FIFO operation and pointer synchronization.

## Bug
During simulation, transient X values appear on full_o shortly after reset deassertion:
+ Time=5000 | rd_data_o=0 | empty=1 | full=x
+ Time=23000 | rd_data_o=0 | empty=0 | full=x
<img width="1055" height="450" alt="image" src="https://github.com/user-attachments/assets/97ea67e2-bfe5-423b-a221-478e9b158a49" />
