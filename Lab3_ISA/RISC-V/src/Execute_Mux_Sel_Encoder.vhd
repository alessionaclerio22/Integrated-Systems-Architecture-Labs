library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX_SEL_ENC is 
	port(
		FW_EX_MEM_A   : in std_logic; -- signals indicating the need of forwarding from MEM or WB stage towards EX stage
		FW_MEM_WB_A   : in std_logic;
		FW_EX_MEM_B   : in std_logic;
		FW_MEM_WB_B   : in std_logic;
		FW_EX_MEM_C   : in std_logic;
		FW_MEM_WB_C   : in std_logic;

		CU_MUX_SEL_B : in std_logic;
		
		MUX_SEL_A 	 : out std_logic_vector(1 downto 0); -- selection signals for the EX stage operands multiplexers
		MUX_SEL_B 	 : out std_logic_vector(1 downto 0);
		MUX_SEL_C 	 : out std_logic_vector(1 downto 0));
end MUX_SEL_ENC;

architecture beh of MUX_SEL_ENC is



begin
	
	-- selection signals that will be given to the muxes in execute stage
	MUX_SEL_A <= "01" when FW_EX_MEM_A = '1' else
				 "10" when FW_MEM_WB_A = '1' else
				 "00";
				 
	MUX_SEL_B <= "00" when FW_EX_MEM_B = '0' and FW_MEM_WB_B = '0' and CU_MUX_SEL_B = '0' else
				 "01" when FW_EX_MEM_B = '0' and FW_MEM_WB_B = '0' and CU_MUX_SEL_B = '1' else
				 "10" when FW_EX_MEM_B = '1' else
				 "11" when FW_MEM_WB_B = '1' else
				 "00";

	MUX_SEL_C <= "01" when FW_EX_MEM_C = '1' else
				 "10" when FW_MEM_WB_C = '1' else
				 "00";
end beh;