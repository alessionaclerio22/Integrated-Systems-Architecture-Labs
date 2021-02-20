library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity Absolute_Value is
	port(op1    : in  std_logic_vector(NBIT - 1 downto 0);
	
		 output : out std_logic_vector(NBIT - 1 downto 0));
end entity;

architecture beh of Absolute_Value is
	signal op1_n : std_logic_vector(NBIT - 1 downto 0);
begin
	
	op1_n  <= not(op1);
	
	output <= op1_n + 1 when op1(NBIT - 1) = '1' else op1;

end beh;