library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

-- generic register with active high reset signal and active low enable signal

entity REG is
	generic(N : integer);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		EN  : in std_logic;
		
		DIN : in std_logic_vector(N - 1 downto 0);
		
		DOUT: out std_logic_vector(N - 1 downto 0));
end REG;

architecture beh of REG is


begin

	REG: process(RST, CLK)
		begin
			if (RST = '1') then
				DOUT <= "00000000010000000000000000000000";
			elsif (CLK'event and CLK = '1' and EN = '0') then
				DOUT <= DIN;
			end if;		
	end process;

end beh; 