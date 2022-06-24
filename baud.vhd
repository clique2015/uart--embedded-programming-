--------------------------------------------------------------------------------
-- PROJECTFPGA.COM
--------------------------------------------------------------------------------
-- NAME:    UART BAUD GENERATOR
--------------------------------------------------------------------------------
-- AUTHORS: Ezeuko Emmanuel <ezeuko.arinze@projectfpga.com>
--------------------------------------------------------------------------------
-- WEBSITE: https://projectfpga.com/uart
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- UART BAUD GENERATOR FOR FPGA
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
entity baud_generator is
port(
  baud_select : in  std_logic_vector(2 downto 0);
  clr_clk, reset, clock : in  std_logic;
   baud_clock : out std_logic);
end entity;
architecture rtl of baud_generator is
signal clock_16                 : std_logic;
signal clr_clkreg               : std_logic;
signal baud_clockreg            : std_logic;
signal clk_counter              : std_logic_vector(11 downto 0);
signal accumulator              : std_logic_vector(11 downto 0) ;
signal clock_16_counter         : std_logic_vector(3 downto 0) ;


begin


baud_selector: process (baud_select)
begin
 case baud_select is       --        baud rates
 when "000"                       => clk_counter <= X"007"; --  115.200
 when "001"                       => clk_counter <= X"00F"; -- 57.600
 when "010"                       => clk_counter <= X"017"; -- 38.400
 when "011"                       => clk_counter <= X"02F"; -- 19.200
 when "100"                       => clk_counter <= X"05F"; -- 9.600
 when "101"                       => clk_counter <= X"0BF"; --4.800
 when "110"                       => clk_counter <= X"17F"; --2.400
 when "111"                       => clk_counter <= X"2FF"; --1.200
 when others                      => clk_counter <= X"007"; -- 115.200
 end case;
 end process baud_selector;



 The_counter: process (reset, clock)
 begin

if reset='1' then
 accumulator <=  ( others => '0');
 clock_16 <= '0';
 elsif rising_edge(clock) then
 if clk_counter = accumulator then
 accumulator <= ( others => '0');
 clock_16 <= '1';
 else
accumulator <= accumulator + 1;
  clock_16 <= '0';
 end if;
 end if;
end process  The_counter;



 The_oversampling_stage: process (reset, clock)
begin
 if reset='1' then
  clr_clkreg <= '0';
  clock_16_counter <=  ( others => '0');
  elsif rising_edge(clock) then
  
  if (clr_clk = '1') then
  clr_clkreg <= '1'; 
    if (clr_clkreg = '0') then
	  clock_16_counter <= "1000";
	    elsif( clock_16 = '1' ) then		
  clock_16_counter<= clock_16_counter + 1 ;
  end if;
	    end if;
     else
	   clr_clkreg <= '0';  
		end if;



  end if;
  end if;

end if;
baud_clock <= '1' when (clock_16_counter = "1111") else '0';
end process The_oversampling_stage;

