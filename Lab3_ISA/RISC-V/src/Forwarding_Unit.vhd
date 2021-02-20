library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

entity FU is
	port(
		RST : in std_logic; -- active high reset signal
		
		EX_MEM_RD : in std_logic_vector(RF_SIZE - 1 downto 0); -- destination register of the instruction in MEM stage
		MEM_WB_RD : in std_logic_vector(RF_SIZE - 1 downto 0); -- destination register of the instruction in WB stage
		ID_EX_RS1 : in std_logic_vector(RF_SIZE - 1 downto 0); -- source register 1 of the instruction in EX stage
		ID_EX_RS2 : in std_logic_vector(RF_SIZE - 1 downto 0); -- source register 2 of the instruction in EX stage
		
		ID_EX_OPC  : in INST; -- instruction currently in EX stage
		EX_MEM_OPC : in INST; -- instruction currently in MEM stage
		MEM_WB_OPC : in INST; -- instruction currently in WB stage
		
		FW_EX_MEM_A   : out std_logic; -- signals that highlight the need of forwarding
		FW_MEM_WB_A   : out std_logic;
		FW_EX_MEM_B   : out std_logic;
		FW_MEM_WB_B   : out std_logic;
		FW_EX_MEM_C   : out std_logic;
		FW_MEM_WB_C   : out std_logic); 
end FU;

architecture beh of FU is


begin

	FW: process(RST, EX_MEM_RD, MEM_WB_RD, ID_EX_RS1, ID_EX_RS2, ID_EX_OPC, EX_MEM_OPC, MEM_WB_OPC)	
		begin
			if (RST = '1') then
				FW_EX_MEM_A	<= '0';
				FW_MEM_WB_A <= '0';
				FW_EX_MEM_B <= '0';
				FW_MEM_WB_B <= '0';
				FW_EX_MEM_C <= '0';
				FW_MEM_WB_C	<= '0';			
			else
				-- if an instrtuction that does not need forwarding is present in EX stage, no forwarding is needed
				if (ID_EX_OPC /= LUI and ID_EX_OPC /= AUIPC and ID_EX_OPC /= JAL) then
					-- if RS1 is equal to MEM RD a forwarding is possible, but the instruction in MEM cannot be a lw, sw or beq
					if (EX_MEM_RD = ID_EX_RS1 and EX_MEM_OPC /= LW and EX_MEM_OPC /= SW and EX_MEM_OPC /= BEQ and ID_EX_RS1 /= "00000") then -- LW needs to STALL, SW does not have a RD
						FW_EX_MEM_A <= '1';
						FW_MEM_WB_A <= '0';
					-- a forwarding from WB is feasible when RS1 = RD in WB and a sw or beq are not present in wb
					elsif (MEM_WB_RD = ID_EX_RS1 and MEM_WB_OPC /= SW and MEM_WB_OPC /= BEQ and ID_EX_RS1 /= "00000") then
						FW_EX_MEM_A <= '0';
						FW_MEM_WB_A <= '1';
					else 
						FW_EX_MEM_A <= '0';
						FW_MEM_WB_A <= '0';
					end if;
				else
					FW_EX_MEM_A <= '0';
					FW_MEM_WB_A <= '0';
				end if;
				
				-- if the instruction has a second operand
				if (ID_EX_OPC = ADD or ID_EX_OPC = SLT or ID_EX_OPC = XOR_OP or ID_EX_OPC = SW) then
					-- if a data dependency is detected and the instruction in MEM is not a lw, sw or beq and the instruction in EX is not a SW
					if (EX_MEM_RD = ID_EX_RS2 and EX_MEM_OPC /= LW and EX_MEM_OPC /= SW and EX_MEM_OPC /= BEQ and ID_EX_OPC /= SW and ID_EX_RS2 /= "00000")  then
						FW_EX_MEM_B <= '1';
						FW_MEM_WB_B <= '0';
					-- a forwarding from WB is feasible also for a lw since its result is now available, but here the case of a sw in EX is still excluded
					elsif (MEM_WB_RD = ID_EX_RS2 and ID_EX_OPC /= SW and MEM_WB_OPC /= SW and MEM_WB_OPC /= BEQ and ID_EX_RS2 /= "00000") then
						FW_EX_MEM_B <= '0';
						FW_MEM_WB_B <= '1';
					else
						FW_EX_MEM_B <= '0';
						FW_MEM_WB_B <= '0';
					end if;
					
					-- if the instruction in EX is a sw and a data dependency is detected, a forwarding is performed regarding the data that will be written in memory					
					if (EX_MEM_RD = ID_EX_RS2 and EX_MEM_OPC /= LW  and EX_MEM_OPC /= SW and EX_MEM_OPC /= BEQ and ID_EX_OPC = SW and ID_EX_RS2 /= "00000") then
						FW_EX_MEM_C <= '1';	
						FW_MEM_WB_C <= '0';
					elsif (MEM_WB_RD = ID_EX_RS2 and ID_EX_OPC = SW  and MEM_WB_OPC /= SW and MEM_WB_OPC /= BEQ and ID_EX_RS2 /= "00000") then
						FW_EX_MEM_C <= '0';
						FW_MEM_WB_C <= '1';
					else
						FW_EX_MEM_C <= '0';	
						FW_MEM_WB_C <= '0';
					end if;	
				else
					FW_EX_MEM_B <= '0';
					FW_MEM_WB_B <= '0';
					FW_EX_MEM_C <= '0';	
					FW_MEM_WB_C <= '0';
				end if;
			end if;
	end process;

end beh;
