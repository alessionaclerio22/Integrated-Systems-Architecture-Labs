library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity tb_RISC_V is
end tb_RISC_V;

architecture struct of tb_RISC_V is

	component RISC_V
		port(
			CLK : in std_logic;
			RST : in std_logic;
			
			OUTALU_IN_MEM  		 : inout std_logic_vector(NBIT - 1 downto 0);
			DATAMEM_IN_MEM 		 : inout std_logic_vector(NBIT - 1 downto 0);
			MEMD_OUT_MEM   		 : in  std_logic_vector(NBIT - 1 downto 0);
			MEM_EN         		 : out std_logic;
			READNOTWRITE   		 : out std_logic;

			PC_TO_IMEM     		 : inout std_logic_vector(NBIT - 1 downto 0);
			INSTRUCTION_OUT_IF	 : in std_logic_vector(NBIT - 1 downto 0));
	end component;

	component IRAM
		port(
			RST : in std_logic;
			
			PC_IN : in std_logic_vector(NBIT - 1 downto 0);
			
			INSTRUCTION : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	component DRAM 
		generic(WORD_SIZE: integer;
				ENTRIES  : integer);	
		port(   DATA_IN 		: in std_logic_vector(WORD_SIZE - 1 downto 0);  
				ADDRESS 		: in std_logic_vector(WORD_SIZE - 1 downto 0);
				READNOTWRITE 	: in std_logic;
				CLK 			: in std_logic;
				RST				: in std_logic;
				ENABLE 			: in std_logic;
				
				DATA_OUT 		: out std_logic_vector(WORD_SIZE - 1 downto 0)); 
	end component; 

	signal CLK_i		: std_logic := '0';
	signal RST_i		: std_logic;
	signal PC_i			: std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_i: std_logic_vector(NBIT - 1 downto 0);
	signal DIN_MEM_i	: std_logic_vector(NBIT - 1 downto 0);
	signal ADDR_i		: std_logic_vector(NBIT - 1 downto 0);
	signal ADDR_f		: std_logic_vector(NBIT - 1 downto 0);
	signal RW_i 		: std_logic;
	signal EN_i 		: std_logic;
	signal DOUT_MEM_i	: std_logic_vector(NBIT - 1 downto 0);
	
begin

	RST_i <= '1', '0' after 6 ns;
	
	CLK_GEN_PROC : process
		begin
			CLK_i <= not(CLK_i);
			wait for 0.5 ns;		
	end process;
	
	IMEM : IRAM port map(RST => RST_i, PC_IN => PC_i, INSTRUCTION => INSTRUCTION_i);
	
	ADDR_f <= ADDR_i - "00010000000000010000000000000000";
	DMEM : DRAM generic map(WORD_SIZE => NBIT, ENTRIES => 8)
				port map(DATA_IN => DIN_MEM_i, ADDRESS => ADDR_f, READNOTWRITE => RW_i, CLK => CLK_i, RST => RST_i, ENABLE => EN_i, DATA_OUT => DOUT_MEM_i);
				
	RISC : RISC_V port map(CLK => CLK_i, RST => RST_i, OUTALU_IN_MEM => ADDR_i, DATAMEM_IN_MEM => DIN_MEM_i, MEMD_OUT_MEM => DOUT_MEM_i, MEM_EN => EN_i,
							READNOTWRITE => RW_i, PC_TO_IMEM => PC_i, INSTRUCTION_OUT_IF => INSTRUCTION_i);

end struct;
