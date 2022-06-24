--------------------------------------------------------------------------------
-- PROJECTFPGA.COM
--------------------------------------------------------------------------------
-- NAME:    TOP_RECEIVER
--------------------------------------------------------------------------------
-- AUTHORS: Ezeuko Emmanuel <ezeuko.arinze@projectfpga.com>
--------------------------------------------------------------------------------
-- WEBSITE: https://projectfpga.com/uart
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- UART TRANSCEIVER FOR FPGA
--------------------------------------------------------------------------------
-- Copyright (C) 2020 projectfpga.com
--
-- This source file is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This source file is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity receiver is
  port(
    reset, rx_bit, clock, cts: in std_logic;
	 baud_sel : in std_logic_vector(2 downto 0);
    error : out std_logic;
	 din : out std_logic_vector(18 downto 0)
  );
end receiver;

architecture structure of receiver is

  component baud_generator
port(
  baud : in  std_logic_vector(2 downto 0);
  clr_clk, reset, clock : in  std_logic;
   baud_clock : out std_logic);
    end component;

	  component receiver
port(
   clr_clk, error: out std_logic;
  rx_bit, stop, cts, reset , baud_clk: in  std_logic;
    din : out  std_logic_vector(18 downto 0));
    end component;

  signal clr_clk, baud_clock, reset: std_logic;

begin

  eq_bit1: baud_generator
    port map ( baud_sel=>baud , clr_clk =>clr_clk, reset=>reset, clock=>clock, baud_clock=>baud_clock);

	   eq_bit3: receiver
    port map (rx_bit=>rx_bit, baud_clock=>baud_clock, error=> error, cts => cts,
	 reset=>reset, clr_clk=> clr_clk, din=>din, stop => '1');

end structure;