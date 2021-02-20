library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.my_package.all;

entity Shifter is
	port(
		OP_TO_BE_SHIFTED : in std_logic_vector(NBIT - 1 downto 0); -- operand to be shifted
		SHIFT_AMOUNT 	 : in std_logic_vector(4 downto 0); -- shift amount
		
		SHIFTED_OUTPUT   : out std_logic_vector(NBIT - 1 downto 0)); -- shifted output
end Shifter;

architecture beh of Shifter is
	signal int_shamt : integer;

begin
	
	
	-- a for loop is used to shift of one position until the shift amount is reached
	P: process(OP_TO_BE_SHIFTED, SHIFT_AMOUNT)
		variable shifted : std_logic_vector(NBIT - 1 downto 0);
		variable int_shamt : integer;
		begin
			int_shamt := conv_integer(SHIFT_AMOUNT);
			shifted := OP_TO_BE_SHIFTED;
			for i in 0 to 31 loop
				exit when i = int_shamt;
				shifted := shifted(NBIT - 1) & shifted(NBIT - 1 downto 1);
			end loop;	
			SHIFTED_OUTPUT <= shifted;
	end process;
	
	
end beh;
