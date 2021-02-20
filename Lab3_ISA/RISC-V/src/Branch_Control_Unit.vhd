library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;


-- component in charge of generating the control signal for
-- the prediction mechanism update and the recovery from possible mispredictions
entity Branch_CU is
	port( 
		  EFFECTIVE_OUTCOME : in std_logic; -- effective branch outcome coming from ID
		  IS_BRANCH_TAKEN   : in std_logic; -- branch prediction, '1' if taken, '0' otherwise
		  INSTR             : in INST;		-- instruction currently in ID
		  STALL				: in std_logic; -- signal coming from HU identifying a stall will be needed
 
		  UPDATE_EN         : out std_logic;-- output signaling the need of updating the btb and prediction mechanism
		  FLUSH             : out std_logic;-- signals the need of flushing the IF/ID register when a wrong instruction is fetched (mispredictions)
		  RESTORE_PC        : out std_logic;-- signals the need of restoring the previous NPC, after a branch that was predicted taken but then was not
 
		  PRED_T_NOT_T      : out std_logic;-- set of signals correlating the prediction with the effective outcome of the branch (PREDICTION_EFFOUTCOME)
		  PRED_T_T          : out std_logic;
		  PRED_NOT_T_T      : out std_logic;
		  PRED_NOT_T_NOT_T  : out std_logic);
end Branch_CU;

architecture beh of Branch_CU is

	signal IS_BRANCH 	 : std_logic;
	
begin

	-- if instrunction in ID is branch, IS_BRANCH is asserted
	IS_BRANCH <= '1' when (INSTR = BEQ) else '0';
	
	-- process generating the proper signals to update the prediction mechanism but also for recovering from mispredictions
	P_BRANCH: process(IS_BRANCH, IS_BRANCH_TAKEN, EFFECTIVE_OUTCOME, STALL)
		begin
			if STALL = '0' then
				-- nothing to do when decoded instruction is not a beq
				if IS_BRANCH = '0' then
					UPDATE_EN <= '0';
					FLUSH <= '0';
					RESTORE_PC <= '0';
					PRED_T_NOT_T <= '0'; 
					PRED_T_T <= '0';      
					PRED_NOT_T_T <= '0';  
					PRED_NOT_T_NOT_T <= '0';
				-- if it is a beq and it was predicted not taken and it is actually not taken, only an update of the predictors is needed
				elsif IS_BRANCH = '1' and IS_BRANCH_TAKEN = '0' and EFFECTIVE_OUTCOME = '0' then
					UPDATE_EN <= '1';
					FLUSH <= '0';
					RESTORE_PC <= '0';
					PRED_T_NOT_T <= '0';  
					PRED_T_T <= '0';
					PRED_NOT_T_T <= '0';  
					PRED_NOT_T_NOT_T <= '1';   
				-- in case it is taken and it was predicted not taken, a flush of the fetched instruction is needed along with the updat of the prediction 
				elsif IS_BRANCH = '1' and IS_BRANCH_TAKEN = '0' and EFFECTIVE_OUTCOME = '1' then
					UPDATE_EN <= '1';
					FLUSH <= '1';
					RESTORE_PC <= '0';
					PRED_T_NOT_T <= '0';  
					PRED_T_T <= '0';
					PRED_NOT_T_T <= '1';  
					PRED_NOT_T_NOT_T <= '0';
				-- in case of taken prediction and effective taken, only update is done
				elsif IS_BRANCH = '1' and IS_BRANCH_TAKEN = '1' and EFFECTIVE_OUTCOME = '1' then
					UPDATE_EN <= '1';
					FLUSH  <= '0';
					RESTORE_PC <= '0';
					PRED_T_NOT_T <= '0';  
					PRED_T_T <= '1';     
					PRED_NOT_T_T <= '0';
					PRED_NOT_T_NOT_T <= '0';  
				-- in the case of a mispredicted taken branch a flush is needed but also restoring the old NPC alsong with the update of the prediction
				elsif IS_BRANCH = '1' and IS_BRANCH_TAKEN = '1' and EFFECTIVE_OUTCOME = '0' then
					UPDATE_EN <= '1';
					FLUSH <= '1';
					RESTORE_PC <= '1';
					PRED_T_NOT_T <= '1'; 
					PRED_T_T <= '0';
					PRED_NOT_T_T <= '0';  
					PRED_NOT_T_NOT_T <= '0';
				else
					UPDATE_EN <= '0';
					FLUSH <= '0';
					RESTORE_PC <= '0';
					PRED_T_NOT_T <= '0'; 
					PRED_T_T <= '0';
					PRED_NOT_T_T <= '0';  
					PRED_NOT_T_NOT_T <= '0';
				end if;
			else
				UPDATE_EN <= '0';
				FLUSH <= '0';
				RESTORE_PC <= '0';
				PRED_T_NOT_T <= '0'; 
				PRED_T_T <= '0';
				PRED_NOT_T_T <= '0';  
				PRED_NOT_T_NOT_T <= '0';
			end if;
	end process;

end beh;