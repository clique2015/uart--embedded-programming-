library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity parity_generator is
port(
  tx_data            : in  std_logic_vector(15 downto 0);
  parity_bit         : out std_logic);
end parity_generator;

architecture rtl of parity_generator is

begin

parity_bit <= tx_data(0) xor tx_data(1)  xor tx_data(2)
xor tx_data(3)  xor tx_data(4)  xor tx_data(5)  xor tx_data(6)
 xor tx_data(7)  xor tx_data(8)  xor tx_data(9)  xor tx_data(10)
 xor tx_data(11)  xor tx_data(12)  xor tx_data(13)  xor tx_data(14)
 xor tx_data(15) ;

end rtl;