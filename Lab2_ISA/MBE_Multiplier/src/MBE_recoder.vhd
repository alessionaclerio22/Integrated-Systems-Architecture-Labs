library ieee; 
use ieee.std_logic_1164.all; 

-- This component is mainly a multiplexer which choses among the values provided by A_gen based on the triplet from the multiplication operand b

entity MBE_recoder is 
	port(	
		a				: in  std_logic_vector(32 downto 0);
		a_2				: in  std_logic_vector(32 downto 0);
		a_n				: in  std_logic_vector(32 downto 0);
		a_2_n			: in  std_logic_vector(32 downto 0);
		b_triplet       : in  std_logic_vector(2 downto 0);
		rec_out			: out std_logic_vector(32 downto 0));
end MBE_recoder; 

architecture beh of MBE_recoder is

begin

	-- In the case of b_triplet = "000" a 33-bit 0 vector is provided at the output
	-- In the case of b_triplet = "111" a 33-bit 1 vector is provided at the output
	-- In all other cases, an input coming from A_gen is chosen according to b_triplet
	
	rec_out <=  (others => '0') when b_triplet = "000" else 
				a 				when b_triplet = "001" else 
				a				when b_triplet = "010" else 
				a_2 			when b_triplet = "011" else 
			    a_2_n		    when b_triplet = "100" else 
				a_n			    when b_triplet = "101" else 
				a_n 			when b_triplet = "110" else 
				(others => '1') when b_triplet = "111" else 
				(others => '0');
end beh;