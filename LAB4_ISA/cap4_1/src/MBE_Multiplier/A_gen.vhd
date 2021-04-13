library ieee; 
use ieee.std_logic_1164.all; 

-- component used to generate the 33-bit-wide inputs to the MBE_recoder

entity A_gen is 
	port(	
		a			: in       std_logic_vector(31 downto 0);	-- a is one of the two operands in the multiplication
		a_out		: inout    std_logic_vector(32 downto 0);
		a2_out		: inout    std_logic_vector(32 downto 0);
		a_n_out	 	: out      std_logic_vector(32 downto 0);
		a2_n_out	: out      std_logic_vector(32 downto 0));
end A_gen; 

architecture beh of A_gen is
begin
	
	a_out   <= '0' & a;	-- extended a on 33 bits
	
	a2_out  <= a & '0'; -- 2*a which is on 33 bits
	
	a_n_out <= not(a_out); -- 1's complement version of the extended a a_out

	a2_n_out <= not(a2_out); -- 1's complement version of 2*a a2_out

end beh;

-- 00001000

-- a_out    = 0 & 00001000 = 000001000 = 8
-- a2_out   = 00001000 & 0 = 000010000 = 16
-- a_n_out  = not(0 & 00001000) = 111110111 = -9
-- a2_n_out = not(000010000) = 111101111 = -17