library ieee;library work;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

-- simple 3-to-1 multiplexer with NBIT wide inputs

entity MUX31 is
	port(
		in_0 : in std_logic_vector(NBIT - 1 downto 0);
		in_1 : in std_logic_vector(NBIT - 1 downto 0);
		in_2 : in std_logic_vector(NBIT - 1 downto 0);
		
		sel  : in std_logic_vector(1 downto 0);
		
		out_mux : out std_logic_vector(NBIT - 1 downto 0));
end MUX31;

architecture beh of MUX31 is


begin

	out_mux <= in_0 when sel = "00" else
			   in_1 when sel = "01" else
			   in_2 when sel = "10" else
			   (others => '0');

end beh; 