library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity IRAM is
	port(
		RST : in std_logic;
		
		PC_IN : in std_logic_vector(NBIT - 1 downto 0);
		
		INSTRUCTION : out std_logic_vector(NBIT - 1 downto 0));
end IRAM;

architecture beh of IRAM is
	
	type mem_array is array (0 to 31) of bit_vector(NBIT - 1 downto 0);
	
	signal PC: std_logic_vector(NBIT - 1 downto 0);
	signal IMEM : mem_array := (
		x"00700813",
		x"0fc10217",
		x"ffc20213",
		x"0fc10297",
		x"01028293",
		x"400006b7",
		x"fff68693",
		x"02080863",
		x"00022403",
		x"41f45493",
		x"00944533",
		x"0014f493",
		x"00950533",
		x"00420213",
		x"fff80813",
		x"00d525b3",
		x"fc058ee3",
		x"000506b3",
		x"fd5ff0ef",
		x"00d2a023",
		x"000000ef",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013",
		x"00000013"
	);

begin

	PC <= PC_IN - "00000000010000000000000000000000";
	
	IMEM_PROC : process(RST, PC)
		begin
				if conv_integer((PC(NBIT - 1 downto 2))) < 32 then
					INSTRUCTION <= to_stdlogicvector(IMEM(conv_integer((PC(NBIT - 1 downto 2)))));
				else
					INSTRUCTION <= (others => '0');
				end if;
	end process;

end beh;
