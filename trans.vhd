--------------------------------------------------------------------------------
-- PROJECTFPGA.COM
--------------------------------------------------------------------------------
-- NAME:    UART TRANSMITTER
--------------------------------------------------------------------------------
-- AUTHORS: Ezeuko Emmanuel <ezeuko.arinze@projectfpga.com>
--------------------------------------------------------------------------------
-- WEBSITE: https://projectfpga.com/uart
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- UART TRANSMITTER FOR FPGA
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
entity transmitter is
port(
  dout : in  std_logic_vector(15 downto 0); --data to be transmitted
  rts : in  std_logic;--set by receiver to tell transmitter to start sending data
  baud_clock : in  std_logic;--The baud clock, will be used instead of main clock
  reset , stop: in  std_logic;
  txbit: out std_logic;
  sent_ok: out std_logic);

end entity;

architecture structure of transmitter is

signal txbusy: std_logic;
signal s_txbusy: std_logic;
signal nobits: std_logic;
signal parity_in: std_logic;
signal TXFSM : std_logic_vector(1 downto 0);
signal TXFSM_in : std_logic_vector(1 downto 0);
signal txbitcnt : std_logic_vector(7 downto 0);
signal txbitcnt_in : std_logic_vector(7 downto 0);
signal data_reg : std_logic_vector(18 downto 0);
signal data_reg_in : std_logic_vector(18 downto 0);
signal data_reg1 : std_logic_vector(18 downto 0);

--adding the parity generator circuit to the transmitter
component parity_generator is
port(
  tx_data            : in  std_logic_vector(15 downto 0);
  parity_bit         : out std_logic);--the name was changed to avoid 
  --conflict with the parity_bit here.
end component;
begin
  join_parity: parity_generator
    port map (tx_data=>dout, parity_bit=>parity_in );
 -- ends here

 --adds the stopbit, paritybit, 16-bit data, and the start bit together 
 --making total of 19bits to be sent out
 data_reg_in <= '0' & dout & parity_in & '1';
 data_reg1 <='1' & data_reg(data_reg'high downto 1);
 txbit      <= data_reg(18) or not txbusy;
nobits <= '1' when (txbitcnt= "10010") else '0';

process (reset, baud_clock)
begin
if reset='1' then
 TXFSM <=  (others => '0');
  txbitcnt <=  (others => '0');
   data_reg <=  (others => '0');
	 sent_ok <= '0';
	 txbusy <= '0';
  elsif rising_edge(baud_clock) then
 TXFSM <=  TXFSM_in;
  txbitcnt <=  txbitcnt_in;
	 sent_ok <= nobits;
	txbusy <= s_txbusy ;

	case TXFSM is

  when "00" =>
  sent_ok <= '0';
  txbusy <='1';
  if rts='1' then
  data_reg <= data_reg_in;
  txbitcnt <=  (others => '0');
  TXFSM <="01";
  end if;

  when "01" =>
  sent_ok <= '0';
  data_reg <= data_reg1;
  txbitcnt <= txbitcnt + 1;
  if(nobits = '1') then
  TXFSM <="11";
  else
  TXFSM <="10";
  end if;

  when "10" =>
  sent_ok <= '0';
  data_reg <= data_reg1;
  txbitcnt <= txbitcnt + 1;
  if(nobits = '1') then
  TXFSM <="11";
  else
  TXFSM <="01";
  end if;

when "11" =>
	sent_ok <= '1';
	txbusy <= '0';
	if (stop = '1') then

	TXFSM <= "11";
else
   TXFSM <= "00";
end if;
	end case;

end if;
end process;
end structure;