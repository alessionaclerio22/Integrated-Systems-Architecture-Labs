library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.my_package.all;

entity BTB is 
	port( CLK 		 	     : in std_logic; -- clock signal
		  RST 		 	     : in std_logic; -- active high reset
		  
		  PRED_T_NOT_T       : in std_logic; -- signals coming from the branch control unit that inform on how to update the prediction mechanism
		  PRED_T_T           : in std_logic;
		  PRED_NOT_T_T       : in std_logic;
		  PRED_NOT_T_NOT_T   : in std_logic;

		  UPDATE_EN          : in std_logic; -- signals the need of update
		  BTB_ADDR   	     : in std_logic_vector(NBIT_BTB_ADDR - 1 downto 0); -- address to the branch target buffer
		  UPDATE_TARGET_PC   : in std_logic_vector(NBIT - 1 downto 0); -- target PC to be written in the branch target buffer when a branch is encountered the first time
		  UPDATE_ADDRESS     : in std_logic_vector(NBIT_BTB_ADDR - 1 downto 0); -- address of the branch instruction whose information is to be updated
		  
		  TARGET_PC	 	     : out std_logic_vector(NBIT - 1 downto 0); -- target address provided in output when a branch is predicted taken
		  IS_TAKEN           : out std_logic); -- when asserted ('1'), it means that the branch is predicted taken
end BTB;

architecture beh of BTB is 
	
	type BTB_Array is array(0 to 2**NBIT_BTB_ADDR - 1) of std_logic_vector(NBIT - 1 downto 0); -- contains the target PC
	type two_bit_pred_Array is array(0 to 2**NBIT_BTB_ADDR - 1) of std_logic_vector(1 downto 0); -- contains the relatefd prediction
	signal BTB : BTB_Array;
	signal TWO_BIT_PREDICTOR : two_bit_pred_Array;
	signal is_branch_array : std_logic_vector(0 to 2**NBIT_BTB_ADDR - 1); -- additional bit to indicate if instruction is branch or not

begin 

	-- write process of the BTB
	BTB_WRITE : process(CLK, RST)
		begin			
			if RST = '1' then 
				BTB <= (others => (others => '0'));
				is_branch_array <= (others => '0');
			elsif CLK'event and CLK = '1' then
				-- if the update signal is asserted and the instruction was not previously detected as branch instruction, the target pc has to be set as well as the is_branch_array related bit
				if UPDATE_EN = '1' and is_branch_array(conv_integer(UPDATE_ADDRESS)) = '0' then
					BTB(conv_integer(UPDATE_ADDRESS)) <= UPDATE_TARGET_PC;	
					is_branch_array(conv_integer(UPDATE_ADDRESS)) <= '1';
				end if;
			end if;
	end process;

	-- read process of the btb
	BTB_READ : process(BTB_ADDR, RST)
		begin
			if RST = '1' then
				TARGET_PC <= (others => '0');
				IS_TAKEN <= '0';
			else			
				-- if the prediction value is greater or equal to 2, it means that the prediction is taken, so the target PC is read and the IS_TAKEN bit asserted
				if conv_integer(TWO_BIT_PREDICTOR(conv_integer(BTB_ADDR))) >= 2 then
					TARGET_PC <= BTB(conv_integer(BTB_ADDR));
					IS_TAKEN <= '1'; 
				else
					TARGET_PC <= (others => '0');
					IS_TAKEN <= '0'; 
				end if;	
			end if;
	end process;
	
	-- prediction mechanism update process
	-- according to the outcome of the prediction and the effective outcome of the branch instructions, the prediction bits are updated 
	-- states are updated according to a 2-bit prediction mechanism
	PREDICT_PROC : process(RST, CLK)
		begin
			if RST = '1' then
				TWO_BIT_PREDICTOR <= (others => (others => '0'));
			-- if an update is necessary
			elsif CLK'event and CLK = '1' and UPDATE_EN = '1' then
				-- predicted not taken and not taken
				if PRED_NOT_T_NOT_T = '1' then
					if TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) = "01"  then
						TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) <= "00";
					end if;
				-- predicted not taken and taken
				elsif PRED_NOT_T_T = '1' then
					if TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) = "01" then
						TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) <= "11";
					else	
						TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) <= "01";
					end if;
				-- predicted taken and taken
				elsif PRED_T_T = '1' then
					if TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) = "11" then
						TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) <= "10";
					end if;
				-- predicted taken and not taken
				elsif PRED_T_NOT_T = '1' then
					if TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) = "11" then
						TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) <= "01";
					else	
						TWO_BIT_PREDICTOR(conv_integer(UPDATE_ADDRESS)) <= "11";
					end if;
				end if;
			end if;			
	end process;

end beh;