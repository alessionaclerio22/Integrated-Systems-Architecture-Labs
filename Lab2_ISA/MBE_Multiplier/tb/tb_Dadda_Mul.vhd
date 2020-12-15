library ieee; 
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity tb_Dadda_Mul is
end tb_Dadda_Mul; 

architecture struct of tb_Dadda_Mul is

	component Dadda_Multiplier 
		port(	
			a	: in  std_logic_vector(31 downto 0);
			b	: in  std_logic_vector(31 downto 0);
			m	: out std_logic_vector(63 downto 0));
	end component;
	
	signal m_i       : std_logic_vector(63 downto 0);
	signal m_expect  : std_logic_vector(63 downto 0);
    signal lfsr_out  : std_logic_vector(31 downto 0);
    signal lfsr_next : std_logic_vector(31 downto 0);
    signal Rst       : std_logic;
	signal Clk       : std_logic := '0';
	signal fb		 : std_logic;
	signal check	 : std_logic;
	
begin
	
    Rst <= '0', '1' after 5 ns;
    
	Clk_gen: process	
	begin
		Clk <= not(Clk);
		wait for 0.5 ns;
	end process;
    
    StateReg: process (Clk,Rst)
    begin
		if Rst = '0' then
			lfsr_out <= "00000000000000000000000000000001";
        elsif (Clk = '1' and Clk'event) then
			lfsr_out <= lfsr_next;
        end if;
    end process;
	
	Check_p: process(Clk)
		begin
			if m_expect = m_i then
				check <= '1';
			else
				check <= '0';
			end if;
	end process;

	
	fb <= lfsr_out(1) xor lfsr_out(5) xor lfsr_out(6) xor lfsr_out(31);
	lfsr_next <= lfsr_out(30 downto 0) & fb;
	
	D_M : Dadda_Multiplier port map ( a => lfsr_out, b => lfsr_next, m => m_i);
	m_expect <= std_logic_vector(unsigned(lfsr_out) * unsigned(lfsr_next));

end struct;


