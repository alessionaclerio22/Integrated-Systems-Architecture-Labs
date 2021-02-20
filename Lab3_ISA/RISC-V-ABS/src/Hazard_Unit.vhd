library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

entity HU is
	port(
		RST : in std_logic; -- active high reset
		
		ID_EX_RD   : in std_logic_vector(RF_SIZE - 1 downto 0); -- RD register of the instruction currently in EX stage
		EX_MEM_RD  : in std_logic_vector(RF_SIZE - 1 downto 0); -- RD register of the instruction currently in MEM stage
		IF_ID_RS1  : in std_logic_vector(RF_SIZE - 1 downto 0); -- source register 1 of the instruction currently in EX stage
		IF_ID_RS2  : in std_logic_vector(RF_SIZE - 1 downto 0); -- source register 2 of the instruction currently in EX stage
		
		ID_EX_OPC  : in INST; -- instruction currently in EX stage
		IF_ID_OPC  : in INST; -- instruction currently in ID stage
		EX_MEM_OPC : in INST; -- instruction currently in MEM stage
		
		STALL    : out std_logic); -- output that signals the need of stalling
end HU;

architecture beh of HU is


begin

	-- A stall is produced whenever a data hazard is detected, forcing a bubble in the pipeline, thus waiting for the correct data to be available

	HZ: process(RST, ID_EX_RD, IF_ID_RS1, IF_ID_RS2, ID_EX_OPC, IF_ID_OPC, EX_MEM_OPC, EX_MEM_RD)
		begin
			if (RST = '1') then
				STALL <= '0';
			else
				if (IF_ID_OPC /= LUI and IF_ID_OPC /= AUIPC and IF_ID_OPC /= JAL) then					
				-- LW R2, R1, 0    IF ID EX MEM WB
				-- ADD R3, R4, R2     IF ID  -  EX  MEM WB
				-- if a lw is in EX and the instruction in ID is not a beq
					if (ID_EX_OPC = LW and IF_ID_OPC /= BEQ) then 
						-- if a data dependency is detected, assert STALL in order to have the right data in execute stage					
						if (ID_EX_RD = IF_ID_RS1) then	
							STALL <= '1';
						elsif (ID_EX_RD = IF_ID_RS2 and IF_ID_OPC /= ANDI and IF_ID_OPC /= ADDI and IF_ID_OPC /= SRAI and IF_ID_OPC /= LW)	then
							STALL <= '1';
						else
							STALL <= '0';
						end if;					 
					-- if the instruction in ID is a beq
					elsif (IF_ID_OPC = BEQ) then
						-- if the instruction is not a nop
						-- ADDI R2, R2, 3      IF ID EX MEM WB
						-- BEQ R2, R5, loop       IF ID  - EX MEM WB
						if(ID_EX_OPC /= ADDI or ID_EX_RD /= "00000") then -- NOP
							-- if a data dependency arises, assert STALL in order to have the right data for forwarding in decode
							if (ID_EX_RD = IF_ID_RS1 or ID_EX_RD = IF_ID_RS2) then
								STALL <= '1';
							else
								STALL <= '0';
							end if;
						else
							STALL <= '0';
						end if;
					-- if a lw is in memory and a beq is in decode
					-- LW R2, 0(R1)      IF ID EX MEM WB					
					-- BEQ R2, R5, loop     IF ID --  -- EX MEM WB (the first stall is detected with the condition above)
					elsif (EX_MEM_OPC = LW and IF_ID_OPC = BEQ) then
						-- if a data dependency is present, assert STALL
						if (EX_MEM_RD = IF_ID_RS1 or EX_MEM_RD = IF_ID_RS2) then
							STALL <= '1';
						else
							STALL <= '0';
						end if;
					else
						STALL <= '0';
					end if;
				else
					 STALL <= '0';
				end if;
		end if;
	end process;

end beh; 
