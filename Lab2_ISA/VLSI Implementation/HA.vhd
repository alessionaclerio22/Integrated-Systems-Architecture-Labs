library ieee; 
use ieee.std_logic_1164.all; 

entity FA is 
	port(	A:	In	std_logic;
			B:	In	std_logic;
			S:	Out	std_logic;
			Co:	Out	std_logic);
end FA; 

architecture BEHAVIORAL of FA is

begin

  S  <= A xor B; --generate Sum
  Co <= A and B; --generate Carry Out
  
end BEHAVIORAL;