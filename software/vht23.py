#!/usr/bin/env python
# -*- coding:utf-8 -*-


import sys
import os.path
import struct
import string
import argparse

testbench = """
library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity T_{name}_TEST is
end entity;

architecture Test of T_{name}_TEST is

    constant PERIOD : time := 20 ps;
    signal CLOCK : std_logic;
    signal RESET : std_logic;

    signal uart_rx : std_logic;
    signal uart_tx : std_logic;

    signal bootload_en : std_logic;
    signal bootload_addr : Word23;
    signal bootload_data : Word23;

    signal debug_instruction : Word23;
    signal debug_state : pipeline_state;
    signal debug_registers : std_logic_vector((24*64)-1 downto 0);

begin

    DUT: ENTITY work.E_CPU23(A_CPU23)
        port map(
            uart_rx => uart_rx,
            uart_tx => uart_tx,
            -- Bootloader
            bootload_en   => bootload_en,
            bootload_addr => bootload_addr,
            bootload_data => bootload_data,
            -- Debug
            debug_instruction => debug_instruction,
            debug_pipeline    => debug_state,
            debug_registers   => debug_registers,
            clk => CLOCK,
            rst => RESET
        );

    generateclock : process
    begin
        CLOCK <= '0';
        wait for PERIOD/2;
        CLOCK <= '1';
        wait for PERIOD/2;
    end process;

    function_test: process
    begin
        RESET <= '0';
        wait for PERIOD;
        bootload_en <= '1';
        {lines}
        wait for PERIOD;
        bootload_en <= '0';
        wait;
    end process;

end;
"""

line_template = """
        bootload_addr <= "{addr:024b}";
        bootload_data <= "{data:024b}";
        wait for PERIOD;
"""


def read_word(fHnd):
    bytes = map(ord, fHnd.read(3))
    return bytes[0] << 16 | bytes[1] << 8 | bytes[2]

if __name__ == "__main__":

    parser = argparse.ArgumentParser("VHDL Test File Generator")
    parser.add_argument("hexfile", type=str)
    output = parser.add_mutually_exclusive_group()
    output.add_argument("-O", action="store_true", default=False, dest="original")
    output.add_argument("--output", "-o", type=str, default=None)

    args = parser.parse_args()

    instrs = []
    fname, _ = os.path.splitext(args.hexfile)

    with open(args.hexfile, "rb") as inp:
        magic = read_word(inp)
        if magic != 0x23C0DE:
            sys.stderr.write("Invalid HEX File header")
            sys.exit(1)
        length = read_word(inp)
        for w in range(length):
            instrs.append(read_word(inp))

    testbench = testbench.format(
        name=fname.upper(),
        lines="".join(
            map(
                lambda (n, i): line_template.format(addr=n, data=i),
                enumerate(instrs)
            )
        )
    )

    if args.original:
        output = open(fname + ".vht", "wb")
    elif args.output is not None:
        output = open(args.output, "wb")
    else:
        output = sys.stdout

    output.write(testbench)
