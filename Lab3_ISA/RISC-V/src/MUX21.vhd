library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;
 
-- simple 2-to-1 multiplexer with NBIT wide inputs

entity MUX21 is
	port(
		in_0 : in std_logic_vector(NBIT - 1 downto 0);
		in_1 : in std_logic_vector(NBIT - 1 downto 0);
		
		sel  : in std_logic;
		
		out_mux : out std_logic_vector(NBIT - 1 downto 0));
end MUX21;

architecture beh of MUX21 is


begin

	out_mux <= in_0 when sel = '0' else
			   in_1 when sel = '1' else
			   (others => '0');

end beh; 