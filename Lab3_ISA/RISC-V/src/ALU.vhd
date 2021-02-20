library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity ALU is
	port(
		A 			: in std_logic_vector(NBIT - 1 downto 0); -- operand 1 coming from ID stage
		B 			: in std_logic_vector(NBIT - 1 downto 0); -- operand 2 coming from ID stage
		PC			: in std_logic_vector(NBIT - 1 downto 0); -- PC from ID stage
		
		ALU_CONTROL : in INST; -- signal from control unit
		
		OUT_ALU     : out std_logic_vector(NBIT - 1 downto 0)); -- output of the ALU
end ALU;

architecture beh of ALU is

	component Shifter
		port(
			OP_TO_BE_SHIFTED : in std_logic_vector(NBIT - 1 downto 0);
			SHIFT_AMOUNT 	 : in std_logic_vector(4 downto 0);
			
			SHIFTED_OUTPUT   : out std_logic_vector(NBIT - 1 downto 0));
	end component;
	
	
	signal comp : std_logic;
	signal shift: std_logic_vector(NBIT - 1 downto 0);
begin

	comp <= '1' when (A < B) else '0';
	
	SH : Shifter port map(OP_TO_BE_SHIFTED => A, SHIFT_AMOUNT => B(4 downto 0), SHIFTED_OUTPUT => shift);
	
	-- different operations are selected based on the control unit signal received
	OUT_ALU <= B when ALU_CONTROL = LUI else
				PC + B when ALU_CONTROL = AUIPC else
				PC + 4 when ALU_CONTROL = JAL else
				(others => '0') when ALU_CONTROL = BEQ else
				A + B when ALU_CONTROL = LW else
				A + B when ALU_CONTROL = SW else
				A + B when ALU_CONTROL = ADDI else
				A and B when ALU_CONTROL = ANDI else
				shift when ALU_CONTROL = SRAI else
				A + B when ALU_CONTROL = ADD else				
				A xor B when ALU_CONTROL = XOR_OP else
				"0000000000000000000000000000000" & comp when ALU_CONTROL = SLT else
				(others => '0');

end architecture;