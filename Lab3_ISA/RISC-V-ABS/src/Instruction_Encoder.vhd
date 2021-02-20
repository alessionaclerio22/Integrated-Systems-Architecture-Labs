library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

entity I_ENC is
	port(
		OPCODE        : in std_logic_vector(OPC_SIZE - 1 downto 0);
		FUNCT         : in std_logic_vector(FUNCT_SIZE - 1 downto 0);
		
		INSTRUCTION   : out INST);
end I_ENC;

architecture beh of I_ENC is

begin

	INSTRUCTION <= LUI    when OPCODE = "0110111" else
				   AUIPC  when OPCODE = "0010111" else
				   JAL    when OPCODE = "1101111" else
				   BEQ    when OPCODE = "1100011" and FUNCT = "000" else
				   ABSV   when OPCODE = "0010011" and FUNCT = "001" else
				   LW     when OPCODE = "0000011" and FUNCT = "010" else
				   SW     when OPCODE = "0100011" and FUNCT = "010" else
				   ADDI   when OPCODE = "0010011" and FUNCT = "000" else
				   ANDI   when OPCODE = "0010011" and FUNCT = "111" else
				   SRAI   when OPCODE = "0010011" and FUNCT = "101" else
				   ADD    when OPCODE = "0110011" and FUNCT = "000" else
				   SLT    when OPCODE = "0110011" and FUNCT = "010" else
				   XOR_OP when OPCODE = "0110011" and FUNCT = "100" else
				   ADDI;

end beh;