library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity DECODE is 
	port(
		CLK : in std_logic; -- clock signal
		RST : in std_logic; -- active high reset
	
		INSTRUCTION : in std_logic_vector(NBIT - 1 downto 0); -- instruction coming from IRAM
		INSTRUCTION_WB : in std_logic_vector(NBIT - 1 downto 0); -- instruction currenlty in WB (needed for destination register)
		INST_T		: in INST; -- instruction type for the instruction currently in ID stage
		PC 			: in std_logic_vector(NBIT - 1 downto 0); -- PC coming from IF stage
		RF_WRITE_IN : in std_logic_vector(NBIT - 1 downto 0); -- data to be written in RF
		
		WR			: in std_logic; -- control signal from CU informing to write in RF
		STALL		: in std_logic; -- signal from HU for stalling
		
		FW_EX_MEM_RS1  : in std_logic; -- signals that hightlight the need of forwarding from MEM or WB one of the two operands
		FW_EX_MEM_RS2  : in std_logic;
		OUTALU_EX_MEM  : in std_logic_vector(NBIT - 1 downto 0); -- output of ALU in MEM stage
		
		PC_BRANCH_ID	  : out std_logic_vector(NBIT - 1 downto 0); -- target address of a branch instruction
		EFFECTIVE_OUTCOME : out std_logic; -- real outcome of a decoded branch
		
		A			    : out std_logic_vector(NBIT - 1 downto 0); -- operand 1 read from RF
		B				: out std_logic_vector(NBIT - 1 downto 0); -- operand 2 read from RF
		IMM				: out std_logic_vector(NBIT - 1 downto 0); -- immediate read from instruction received by IRAM
		INSTRUCTION_OUT : out std_logic_vector(NBIT - 1 downto 0); -- instruction propagated through the ID stage
		PC_OUT		    : out std_logic_vector(NBIT - 1 downto 0));-- PC propagated through the ID stage
end DECODE;

architecture struct of DECODE is

	component RF 
		generic( NBIT_ADDR: integer;
				 NBIT_DATA: integer);
		port (  CLK: 		in std_logic;
				RST: 	    in std_logic;
				
				WR: 		in std_logic;
				
				ADD_WR: 	in std_logic_vector(NBIT_ADDR - 1 downto 0);
				ADD_RD1: 	in std_logic_vector(NBIT_ADDR - 1 downto 0);
				ADD_RD2: 	in std_logic_vector(NBIT_ADDR - 1 downto 0);
				DATAIN: 	in std_logic_vector(NBIT_DATA - 1 downto 0);
				
				OUT1: 		out std_logic_vector(NBIT_DATA - 1 downto 0);
				OUT2: 		out std_logic_vector(NBIT_DATA - 1 downto 0));
	end component;
	
	component IMM_GEN 
		port(
			INSTRUCTION : in std_logic_vector(NBIT - 1 downto 0);
			INST_T		: in INST;
			IMMEDIATE   : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	signal IMMEDIATE : std_logic_vector(NBIT - 1 downto 0);
	signal IMM_REAL  : std_logic_vector(NBIT - 1 downto 0);	
	signal A_REAL    : std_logic_vector(NBIT - 1 downto 0);
	signal B_REAL    : std_logic_vector(NBIT - 1 downto 0);
	signal A_RF      : std_logic_vector(NBIT - 1 downto 0);
	signal B_RF      : std_logic_vector(NBIT - 1 downto 0);

	
begin

	REGISTER_FILE : RF generic map(NBIT_ADDR => RF_SIZE, NBIT_DATA => NBIT)
						port map(CLK => CLK, RST => RST, WR => WR, ADD_WR => INSTRUCTION_WB(11 downto 7), ADD_RD1 => INSTRUCTION(19 downto 15),
						ADD_RD2 => INSTRUCTION(24 downto 20), DATAIN => RF_WRITE_IN, OUT1 => A_RF, OUT2 => B_RF);
						
	IMMEDIATE_GENERATION : IMM_GEN port map(INSTRUCTION => INSTRUCTION, INST_T => INST_T, IMMEDIATE => IMMEDIATE);
	
	IMM_REAL <= IMMEDIATE when STALL = '0' else (others => '0');
	IMM <= IMM_REAL;
	PC_BRANCH_ID <= PC + IMM_REAL; -- also for JAL
	
	A_REAL <= OUTALU_EX_MEM when (FW_EX_MEM_RS1 = '1') else
			  A_RF;
			  
	B_REAL <= OUTALU_EX_MEM when (FW_EX_MEM_RS2 = '1') else
			  B_RF;
			  
	A <= A_REAL when STALL = '0' else (others => '0');
	B <= B_REAL when STALL = '0' else (others => '0');
	
	EFFECTIVE_OUTCOME <= '1' when A_REAL = B_REAL and INST_T = BEQ and STALL = '0' else '0';
	
	INSTRUCTION_OUT <= INSTRUCTION;
	PC_OUT <= PC;
	

end struct;