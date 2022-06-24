--------------------------------------------------------------------------------
-- PROJECTFPGA.COM
--------------------------------------------------------------------------------
-- NAME:    TRANSMITTER TOP
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

entity transmitter is
  port(
    clk, reset, rts: in std_logic;
	 baud_sel : in std_logic_vector(2 downto 0);
	 dout : in std_logic_vector(15 downto 0);
    done, txbit : out std_logic;
  );
end transmitter;

architecture structure of transmitter is

  component baud_generator
port(
  baud : in  std_logic_vector(2 downto 0);
  clr_clk, reset, clk : in  std_logic;
  baud_clock : out std_logic);
    end component;

	  component trans
port(
  dout : in  std_logic_vector(15 downto 0); --data to be transmitted
  rts : in  std_logic;--set by receiver to tell transmitter to start sending data
  baud_clock : in  std_logic;--The baud clock, will be used instead of main clock
  reset , stop: in  std_logic;
  txbit: out std_logic;
  sent_ok: out std_logic);
    end component;


  signal baud, reset: std_logic;

begin
reset <= reset;

  eq_bit0: baud_generator
    port map (baud => baud_sel, clr_clk=> 0, reset => reset, clk => clk, baud_clock => baud);

  eq_bit2: transmitter
    port map (dout=>dout, rts=>rts, reset=>reset, txbit=>txbit, sent_ok=> done, stop => 1, baud_clock => baud);


end structure;