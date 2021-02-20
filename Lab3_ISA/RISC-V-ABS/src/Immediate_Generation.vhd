library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.my_package.all;

entity IMM_GEN is 
	port(
		INSTRUCTION : in std_logic_vector(NBIT - 1 downto 0);
		INST_T		: in INST;
		IMMEDIATE   : out std_logic_vector(NBIT - 1 downto 0));
end IMM_GEN;

architecture beh of IMM_GEN is


begin
	IMMEDIATE <= INSTRUCTION(31 downto 12) & "000000000000" when (INST_T = LUI or INST_T = AUIPC) else
	
				 "00000000000" & INSTRUCTION(31) & INSTRUCTION(19 downto 12) & INSTRUCTION(20) & INSTRUCTION(30 downto 21) & '0' when (INST_T = JAL and INSTRUCTION(31) = '0') else
				 "11111111111" & INSTRUCTION(31) & INSTRUCTION(19 downto 12) & INSTRUCTION(20) & INSTRUCTION(30 downto 21) & '0' when (INST_T = JAL and INSTRUCTION(31) = '1') else
				 
				 "0000000000000000000" & INSTRUCTION(31) & INSTRUCTION(7) & INSTRUCTION(30 downto 25) & INSTRUCTION(11 downto 8) & '0' when (INST_T = BEQ and INSTRUCTION(31) = '0') else
				 "1111111111111111111" & INSTRUCTION(31) & INSTRUCTION(7) & INSTRUCTION(30 downto 25) & INSTRUCTION(11 downto 8) & '0' when (INST_T = BEQ and INSTRUCTION(31) = '1') else
				 
				 "00000000000000000000" & INSTRUCTION(31 downto 20) when (INST_T = LW and INSTRUCTION(31) = '0') else
				 "11111111111111111111" & INSTRUCTION(31 downto 20) when (INST_T = LW and INSTRUCTION(31) = '1') else
				 
				 "000000000000000000000" & INSTRUCTION(31 downto 26) & INSTRUCTION(11 downto 7) when (INST_T = SW and INSTRUCTION(31) = '0') else
				 "111111111111111111111" & INSTRUCTION(31 downto 26) & INSTRUCTION(11 downto 7) when (INST_T = SW and INSTRUCTION(31) = '1') else
				
				 "00000000000000000000" & INSTRUCTION(31 downto 20) when (INST_T = ADDI and INSTRUCTION(31) = '0') else
				 "11111111111111111111" & INSTRUCTION(31 downto 20) when (INST_T = ADDI and INSTRUCTION(31) = '1') else
				 "00000000000000000000" & INSTRUCTION(31 downto 20) when (INST_T = ANDI and INSTRUCTION(31) = '0') else
				 "11111111111111111111" & INSTRUCTION(31 downto 20) when (INST_T = ANDI and INSTRUCTION(31) = '1') else				 
				 "000000000000000000000000000" & INSTRUCTION(24 downto 20) when INST_T = SRAI else				 
				 (others => '0');
				 
end beh;