library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.my_package.all;

entity RF is
	generic( NBIT_ADDR: integer;
			 NBIT_DATA: integer);
	port (  CLK: 		in std_logic;
			RST: 	    in std_logic;
			
			WR: 		in std_logic; -- if WR = '1' a write operation is to be performed
			
			ADD_WR: 	in std_logic_vector(NBIT_ADDR - 1 downto 0); -- address of write operation
			ADD_RD1: 	in std_logic_vector(NBIT_ADDR - 1 downto 0); -- address of read operation 1
			ADD_RD2: 	in std_logic_vector(NBIT_ADDR - 1 downto 0); -- address of read operation 2
			DATAIN: 	in std_logic_vector(NBIT_DATA - 1 downto 0); -- data to be written in memory
			
			OUT1: 		out std_logic_vector(NBIT_DATA - 1 downto 0); -- output read data 1
			OUT2: 		out std_logic_vector(NBIT_DATA - 1 downto 0)); -- output read data 2
end RF;

architecture beh of RF is

    subtype REG_ADDR is natural range 0 to (2**(NBIT_ADDR)) - 1; 
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT_DATA - 1 downto 0); 
	signal REGISTERS : REG_ARRAY; 

	
begin 

	
	-- asynch reading
    RF_r: process(RST, CLK)
		begin
			if RST = '1' then 
				OUT1 <= (others => '0');
				OUT2 <= (others => '0');
			else
				if WR = '1' then
					-- cases in which the same location is read and written are taken into account
					if ADD_WR = ADD_RD1 and ADD_WR /= ADD_RD2 then
						OUT1 <= DATAIN;
						OUT2 <= REGISTERS(conv_integer(ADD_RD2));
					elsif ADD_WR = ADD_RD2 and ADD_WR /= ADD_RD1 then
						OUT2 <= DATAIN;
						OUT1 <= REGISTERS(conv_integer(ADD_RD1));
					elsif ADD_WR = ADD_RD1 and ADD_WR = ADD_RD2 then
						OUT1 <= DATAIN;
						OUT2 <= DATAIN;
					else
						OUT1 <= REGISTERS(conv_integer(ADD_RD1));
						OUT2 <= REGISTERS(conv_integer(ADD_RD2));
					end if;
				else
					OUT1 <= REGISTERS(conv_integer(ADD_RD1));
					OUT2 <= REGISTERS(conv_integer(ADD_RD2));
				end if;
			end if;
	end process;
	
	-- synch writing
	RF_w : process(RST, CLK)
		begin
			if RST = '1' then
				REGISTERS <= (others => (others => '0'));
			elsif CLK'EVENT and CLK = '1' then
				REGISTERS(0) <= (others => '0');
				if WR = '1' and ADD_WR /= 0 then
					REGISTERS(conv_integer(ADD_WR)) <= DATAIN;
				end if;
			end if;
	end process;
end beh;

