library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

entity BFU is 
	port(
		RST : in std_logic; -- active high reset signal
		
		EX_MEM_RD : in std_logic_vector(RF_SIZE - 1 downto 0); -- RD of the instruction in MEM
		IF_ID_RS1 : in std_logic_vector(RF_SIZE - 1 downto 0); -- RS1 of the instruction in ID
		IF_ID_RS2 : in std_logic_vector(RF_SIZE - 1 downto 0); -- RS1 of the instruction in ID
		
		IF_ID_OPC  : in INST; -- instruction currently in ID
		EX_MEM_OPC : in INST; -- instruction currently in MEM
		
		FW_EX_MEM_RS1  : out std_logic; -- signals the need of forwarding from MEM operand 1
		FW_EX_MEM_RS2  : out std_logic); -- signals the need of forwarding from MEM operand 2
end BFU;

architecture beh of BFU is


begin

	PROC_BFU: process(RST, EX_MEM_OPC, IF_ID_OPC, EX_MEM_RD, IF_ID_RS1, IF_ID_RS2)
	
		begin
			if (RST = '1') then -- RESET is active
				FW_EX_MEM_RS1 <= '0';
				FW_EX_MEM_RS2 <= '0';
			else
				-- RS1
				-- if instruction is beq, RS1 = RD and the instruction in memory is not a beq, sw or a addi x0, x0, 0
				if (IF_ID_OPC = BEQ and IF_ID_RS1 = EX_MEM_RD and EX_MEM_OPC /= BEQ and EX_MEM_OPC /= SW and EX_MEM_RD /= "00000") then
					FW_EX_MEM_RS1 <= '1';
				else
					FW_EX_MEM_RS1 <= '0';
				end if;
				
				-- RS2
				-- if instruction is beq, RS2 = RD and the instruction in memory is not a beq, sw or a addi x0, x0, 0
				if (IF_ID_OPC = BEQ and IF_ID_RS2 = EX_MEM_RD and EX_MEM_OPC /= BEQ and EX_MEM_OPC /= SW  and EX_MEM_RD /= "00000") then
					FW_EX_MEM_RS2 <= '1';
				else
					FW_EX_MEM_RS2 <= '0';
				end if;
			end if;
	end process;


end beh;