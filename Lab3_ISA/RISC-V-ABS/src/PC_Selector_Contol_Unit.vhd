library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity PC_SELECTOR is
	port(
		IS_BRANCH_TAKEN      : in std_logic; -- branch prediction, '1' if taken, '0' otherwise
		IS_BRANCH_TAKEN_D    : in std_logic; -- branch prediction delayed by one clock cycle
		RESTORE_PC           : in std_logic; -- signals the need of restoring the previous NPC (mispredicted taken)
		TAKEN_BRANCH_FROM_ID : in std_logic; -- effective outcome of branch instruction coming from ID stage
		INSTRUCTION			 : in INST; -- instruction currently in ID stage
		
		PC_MUX_SEL           : out std_logic_vector(1 downto 0)); -- selector signal to mux in fetch stage
end PC_SELECTOR;

architecture beh of PC_SELECTOR is


begin

	PC_MUX_SEL <= "01" when (TAKEN_BRANCH_FROM_ID = '1' and IS_BRANCH_TAKEN_D = '0') or INSTRUCTION = JAL else -- case of predicted untaken and then taken or JAL instruction
				  "10" when IS_BRANCH_TAKEN = '1' else -- case of predicted taken from BTB
				  "11" when RESTORE_PC = '1' else -- case of predicted taken and then proved to be untaken
				  "00"; -- choose NPC

end beh;
