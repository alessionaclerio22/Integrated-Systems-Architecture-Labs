library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity FETCH is
	port(
		CLK               : in std_logic; -- clock signal
		RST               : in std_logic; -- active high reset
		
		STALL			  : in std_logic; -- stall signal from HU
		INSTRUCTION_ID	  : in INST; -- instruction currently in ID stage
		PC_FROM_ID_BRANCH : in std_logic_vector(NBIT - 1 downto 0); -- target address coming from ID when a branch is decoded
		PC_FROM_BTB       : in std_logic_vector(NBIT - 1 downto 0); -- target address coming from branch target buffer
		SEL_MUX           : in std_logic_vector(1 downto 0); -- selector of the multiplexer of PCs
		
		PC_TO_IMEM        : inout std_logic_vector(NBIT - 1 downto 0)); -- PC to be given to the IRAM
end FETCH;

architecture struct of FETCH is
	
	component MUX41
		port(
			in_0 : in std_logic_vector(NBIT - 1 downto 0);
			in_1 : in std_logic_vector(NBIT - 1 downto 0);
			in_2 : in std_logic_vector(NBIT - 1 downto 0);
			in_3 : in std_logic_vector(NBIT - 1 downto 0);
			
			sel  : in std_logic_vector(1 downto 0);
			
			out_mux : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	component REG is
		generic(N : integer);
		port(
			CLK : in std_logic;
			RST : in std_logic;
			EN  : in std_logic;
			
			DIN : in std_logic_vector(N - 1 downto 0);
			
			DOUT: out std_logic_vector(N - 1 downto 0));
	end component;
	

	signal OUT_PC_MUX : std_logic_vector(NBIT - 1 downto 0);	
	signal NEXT_PC    : std_logic_vector(NBIT - 1 downto 0);
	signal RESTORED_PC: std_logic_vector(NBIT - 1 downto 0);
	

begin
	-- right pc selection mux
	PC_MUX : MUX41 port map(in_0 => NEXT_PC, in_1 => PC_FROM_ID_BRANCH, in_2 => PC_FROM_BTB, in_3 => RESTORED_PC, sel => SEL_MUX, out_mux => OUT_PC_MUX);
	
	-- pc register
	PC_REG : REG generic map(N => NBIT)
					port map(CLK => CLK, RST => RST, EN => STALL, DIN => OUT_PC_MUX, DOUT => PC_TO_IMEM);

	-- NPC calculation
	NEXT_PC <= PC_TO_IMEM + 4;
	
	-- register for the restored pc
	R : REG generic map(N => NBIT)
					port map(CLK => CLK, RST => RST, EN => STALL, DIN => NEXT_PC, DOUT => RESTORED_PC);

end struct;