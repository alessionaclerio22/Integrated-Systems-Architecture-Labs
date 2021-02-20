library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;


-- hardwired CU that generates control signals for EX, MEM, WB stages

entity CU_RISC_V is
	port(
		CLK : in std_logic; -- clock signal
		RST : in std_logic; -- active high reset
		
		STALL       : in std_logic; -- signal from HU informing of the need of a stall
		INSTRUCTION : in INST; -- instruction currently in decode
		
		MUX_SEL_B   : out std_logic; -- control signals for EX stage
		ALU_INST    : out INST;

		MEM_EN      : out std_logic; -- control signals for MEM stage
		READNOTWRITE: out std_logic;

		MUX_SEL_WB  : out std_logic; -- control signals for WB stage
		WR_RF       : out std_logic);
end CU_RISC_V;

architecture beh of CU_RISC_V is

	signal CW 	   : std_logic_vector(CW_SIZE - 1 downto 0);
	signal CW_EX  : std_logic_vector(CW_SIZE - 1 downto 0);
	signal CW_MEM : std_logic_vector(CW_SIZE - EX_SIZE - 1 downto 0);
	signal CW_WB  : std_logic_vector(CW_SIZE - EX_SIZE - MEM_SIZE - 1 downto 0);
	signal ALU_INST_ID : INST;
	
begin

	
	-- generating the control word for the associated instruction 
	CW <= (others  => '0') when STALL = '1' else
		  "10001"  when INSTRUCTION = LUI  else
		  "10001"  when INSTRUCTION = AUIPC else
		  "10001"  when INSTRUCTION = JAL else
		  "00000"  when INSTRUCTION = BEQ else
		  "11111"  when INSTRUCTION = LW else
		  "11000"  when INSTRUCTION = SW else
		  "10001"  when INSTRUCTION = ADDI else
		  "10001"  when INSTRUCTION = ANDI else
		  "10001"  when INSTRUCTION = SRAI else
		  "00001"  when INSTRUCTION = ADD else
		  "00001"  when INSTRUCTION = SLT else
		  "00001"  when INSTRUCTION = XOR_OP else
		  "00000";
		
	-- generating the control word for the ALU for the associated instruction 
	ALU_INST_ID <= ADDI when STALL = '1' else
				    LUI 	when INSTRUCTION = LUI   else
				    AUIPC   when INSTRUCTION = AUIPC  else
				    JAL     when INSTRUCTION = JAL  else
				    BEQ     when INSTRUCTION = BEQ  else
				    LW      when INSTRUCTION = LW  else
				    SW      when INSTRUCTION = SW  else
				    ADDI    when INSTRUCTION = ADDI  else
				    ANDI    when INSTRUCTION = ANDI  else
				    SRAI    when INSTRUCTION = SRAI  else
				    ADD     when INSTRUCTION = ADD  else
				    SLT     when INSTRUCTION = SLT  else
				    XOR_OP  when INSTRUCTION = XOR_OP else
					ADDI;
	
	-- properly delaying the cw for the different stages of the pipeline
	CW_PROC : process(CLK, RST)
		begin
			if RST = '1' then
				CW_EX  <= (others => '0');
				CW_MEM <= (others => '0');
				CW_WB  <= (others => '0');
			elsif CLK'event and CLK = '1' then
				CW_EX  <= CW;
				CW_MEM <= CW_EX(CW_SIZE - EX_SIZE - 1 downto 0);
				CW_WB  <= CW_MEM(CW_SIZE - EX_SIZE - MEM_SIZE - 1 downto 0);
				
				ALU_INST <= ALU_INST_ID;
			end if;
	end process;

	-- ex stage
	MUX_SEL_B    <= CW_EX(CW_SIZE - 1);
	-- mem stage
	MEM_EN       <= CW_MEM(CW_SIZE - EX_SIZE - 1);
	READNOTWRITE <= CW_MEM(CW_SIZE - EX_SIZE - 2);
	-- wb stage
	MUX_SEL_WB   <= CW_WB(CW_SIZE - EX_SIZE - MEM_SIZE - 1);
	WR_RF        <= CW_WB(CW_SIZE - EX_SIZE - MEM_SIZE - 2);


end beh;