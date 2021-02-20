library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.my_package.all;


entity DRAM is 
	generic(WORD_SIZE: integer; -- size of a word
			ENTRIES  : integer);-- number of memory entries	
	port(   DATA_IN 		: in std_logic_vector(WORD_SIZE - 1 downto 0); -- data to be written in memory
			ADDRESS 		: in std_logic_vector(WORD_SIZE - 1 downto 0); -- address of memory used both for writing and reading
			READNOTWRITE 	: in std_logic; -- read and write control signal, '1' -> read, '0' -> write
			CLK 			: in std_logic; -- clock signal
			RST				: in std_logic; -- active high reset
			ENABLE 			: in std_logic; -- memory enable signal active high
			
			DATA_OUT 		: out std_logic_vector(WORD_SIZE - 1 downto 0)); -- data read from memory
end DRAM; 
 
architecture beh of DRAM is 

	type Ram_array is array (0 to ENTRIES - 1) of std_logic_vector (WORD_SIZE - 1 downto 0); 
	signal Mem : Ram_array;  
 
begin 

	process (CLK, RST) is
		begin 
		    if (RST = '1') then 	
			Mem <= ("00000000000000000000000000001010",
				"11111111111111111111111111010001",
				"00000000000000000000000000010110",
				"11111111111111111111111111111101",
				"00000000000000000000000000001100",
				"00000000000000000000000000011011",
				"11111111111111111111111111111100",
				"00000000000000000000000000000000"); -- initialization needed for the test program execution
		    ELSE
				if (ENABLE = '1') then  
					if (READNOTWRITE = '1') then
						DATA_OUT <= Mem(conv_integer(unsigned(ADDRESS(WORD_SIZE - 1 downto 2))));					
					elsif (READNOTWRITE = '0') and (CLK = '1' AND CLK'EVENT) then
						Mem(conv_integer(unsigned(ADDRESS(WORD_SIZE - 1 downto 2)))) <= DATA_IN; 
					else
						DATA_OUT <= (others => 'Z');
					end if;
				end if;
		    end if; 
	end process; 


end beh; 