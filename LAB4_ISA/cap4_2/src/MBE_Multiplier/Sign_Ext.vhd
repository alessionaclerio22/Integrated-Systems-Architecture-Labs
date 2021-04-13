library ieee; 
use ieee.std_logic_1164.all;
use work.types.all; 

-- Component used to know the S bit to assign to the partial product according to the suggestions in the file sign_extension_booth_multiplier_Stanford.pdf

entity Sign_Ext is 
	port(
		b_triplet : in std_logic_vector(2 downto 0); 		   
		S  		  : out std_logic);
end Sign_Ext; 

architecture beh of Sign_Ext is

begin

	-- If the partial product is positive, S = '0', S = '1' otherwise

	S 	 <= '0' when b_triplet = "000" else 
			'0' when b_triplet = "001" else
			'0' when b_triplet = "010" else
			'0' when b_triplet = "011" else
			'1' when b_triplet = "100" else
			'1' when b_triplet = "101" else
			'1' when b_triplet = "110" else
			'1' when b_triplet = "111" else
			'0';

end beh;