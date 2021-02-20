library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity EXECUTE is 
	port(	
		PC		 		 : in std_logic_vector(NBIT - 1 downto 0); -- PC from ID stage
		INSTRUCTION_IN   : in std_logic_vector(NBIT - 1 downto 0); -- instruction coming from ID stage
		ALU_CONTROL		 : in INST; -- control signal for ALU

		A 				 : in std_logic_vector(NBIT - 1 downto 0); -- operand 1 from ID stage
		B 				 : in std_logic_vector(NBIT - 1 downto 0); -- operand 2 from ID stage
		IMM 			 : in std_logic_vector(NBIT - 1 downto 0); -- immediate coming from ID stage
		
		FW_OUTALU_EX_MEM : in std_logic_vector(NBIT - 1 downto 0); -- output of the ALU in MEM stage and value from WB to be forwarded
		FW_OUTVAL_MEM_WB : in std_logic_vector(NBIT - 1 downto 0);
		
		MUX_SEL_A 		 : in std_logic_vector(1 downto 0); -- selection signals for the multiplexers in EX stage
		MUX_SEL_B 		 : in std_logic_vector(1 downto 0);
		MUX_SEL_C    	 : in std_logic_vector(1 downto 0);

		OUT_ALU 		 : out std_logic_vector(NBIT - 1 downto 0); -- output of the ALU
		INSTRUCTION_OUT  : out std_logic_vector(NBIT - 1 downto 0); -- instruction through EX stage
		DATAIN_MEM 		 : out std_logic_vector(NBIT - 1 downto 0));-- data to be then written in memory
end EXECUTE;

architecture struct of EXECUTE is

	component ALU
		port(
			A 			: in std_logic_vector(NBIT - 1 downto 0);
			B 			: in std_logic_vector(NBIT - 1 downto 0);
			PC			: in std_logic_vector(NBIT - 1 downto 0);
			
			ALU_CONTROL : in INST;
			
			OUT_ALU     : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	component MUX31
		port(
			in_0 : in std_logic_vector(NBIT - 1 downto 0);
			in_1 : in std_logic_vector(NBIT - 1 downto 0);
			in_2 : in std_logic_vector(NBIT - 1 downto 0);
			
			sel  : in std_logic_vector(1 downto 0);
			
			out_mux : out std_logic_vector(NBIT - 1 downto 0));
	end component;
	
	component MUX41
		port(
			in_0 : in std_logic_vector(NBIT - 1 downto 0);
			in_1 : in std_logic_vector(NBIT - 1 downto 0);
			in_2 : in std_logic_vector(NBIT - 1 downto 0);
			in_3 : in std_logic_vector(NBIT - 1 downto 0);
			
			sel  : in std_logic_vector(1 downto 0);
			
			out_mux : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	signal ALU_OP_1 : std_logic_vector(NBIT - 1 downto 0);
	signal ALU_OP_2 : std_logic_vector(NBIT - 1 downto 0);
	signal ALU_OP_3 : std_logic_vector(NBIT - 1 downto 0);
	
begin

	ALU_CNTRL : ALU port map(A => ALU_OP_1, B => ALU_OP_2, PC => PC, ALU_CONTROL => ALU_CONTROL, OUT_ALU => OUT_ALU);
	
	MUXA : MUX31 port map(in_0 => A, in_1 => FW_OUTALU_EX_MEM, in_2 => FW_OUTVAL_MEM_WB, sel => MUX_SEL_A, out_mux => ALU_OP_1);
	
	MUXB : MUX41 port map(in_0 => B, in_1 => IMM, in_2 => FW_OUTALU_EX_MEM, in_3 => FW_OUTVAL_MEM_WB, sel => MUX_SEL_B, out_mux => ALU_OP_2);
	
	MUXC : MUX31 port map(in_0 => B, in_1 => FW_OUTALU_EX_MEM, in_2 => FW_OUTVAL_MEM_WB, sel => MUX_SEL_C, out_mux => ALU_OP_3);

	INSTRUCTION_OUT <= INSTRUCTION_IN;  
	
	DATAIN_MEM <= ALU_OP_3;

end struct;