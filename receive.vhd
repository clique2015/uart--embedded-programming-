--------------------------------------------------------------------------------
-- PROJECTFPGA.COM
--------------------------------------------------------------------------------
-- NAME:    UART RECEIVER
--------------------------------------------------------------------------------
-- AUTHORS: Ezeuko Emmanuel <ezeuko.arinze@projectfpga.com>
--------------------------------------------------------------------------------
-- WEBSITE: https://projectfpga.com/uart
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- UART RECEIVER FOR FPGA
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity receiver is
port(
   received_ok: out std_logic;
  rx_bit : in  std_logic;--The received bit
  baud_clock : in  std_logic;--The baud clock, will be used instead of main clock
  reset : in  std_logic;
  stop, ready: in std_logic;
  clr_clk: out std_logic;--resets the baud_clock to zero
    din : out  std_logic_vector(18 downto 0)); --received data
end entity;


--adding the parity generator circuit to the transmitter
component parity_generator is
port(
  rx_data            : in  std_logic_vector(15 downto 0);
  parity_bit         : out std_logic);--the name was changed to avoid 
  --conflict with the parity_bit here.
end component;
begin
  join_parity: parity_generator
    port map (rx_data=>data_reg(17 downto 0), parity_bit=>parity_in );
 -- ends here
 
 
architecture structure of receiver is
signal RXFSM : std_logic_vector(1 downto 0);--stores the current state
signal rxbitcnt : std_logic_vector(7 downto 0);
signal nobits, error_sig, parity_in : std_logic;
signal data_reg : std_logic_vector(18 downto 0);

begin
 din       <= data_reg;
nobits <= '1' when (rxbitcnt = "10001") else '0';
clr_clk <= not RXFSM(0) and not RXFSM(1) and   not rx_bit;
error_sig <= parity_in xor data_reg(1);

process (reset, baud_clock)
begin
if reset='1' then
RXFSM <=  (others => '0');
rxbitcnt <=  (others => '0');
error<=  '0';
data_reg <=  (others => '0');
  elsif rising_edge(baud_clock) then



   case RXFSM is

  when "00" =>
  if rx_bit ='0' then
  if cts = '1' then
  RXFSM <="01";
   rxbitcnt <= (others => '0');
  else
 RXFSM <= "00";
  end if;
    end if;

  when "01" =>
  data_reg <= rx_bit & data_reg(data_reg'high downto 1);
  rxbitcnt <= rxbitcnt + 1;
  if nobits = '1' then
  RXFSM <="11";
 else
  RXFSM <="10";
  end if;

  when "10" =>
  data_reg <= rx_bit & data_reg(data_reg'high downto 1);
  rxbitcnt <= rxbitcnt + 1;
  if nobits = '1' then
  RXFSM <="11";
 else
  RXFSM <="01";
  end if;

when "11" =>
if error_sig = '1' then
 error <= '1';
 else 
 error <= '0';
  rxbitcnt <= (others => '0');
  if stop = '1' then
	RXFSM <= "11";
else
	RXFSM <= "00";
end if;

	end case;
end if;
end process;
end structure;