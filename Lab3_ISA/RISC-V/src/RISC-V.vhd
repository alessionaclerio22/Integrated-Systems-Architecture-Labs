library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.my_package.all;

entity RISC_V is 
	port(
		CLK : in std_logic; -- clock signal
		RST : in std_logic; -- active high reset signal
		
		OUTALU_IN_MEM  		 : inout std_logic_vector(NBIT - 1 downto 0); -- address of DRAM
		DATAMEM_IN_MEM 		 : out std_logic_vector(NBIT - 1 downto 0); -- data in DRAM
		MEMD_OUT_MEM   		 : in  std_logic_vector(NBIT - 1 downto 0); -- output of DRAM
		MEM_EN         		 : out std_logic; -- DRAM enable signal
		READNOTWRITE   		 : out std_logic; -- selection of operation (read/write) for DRAM

		PC_TO_IMEM     		 : inout std_logic_vector(NBIT - 1 downto 0); -- PC to IRAM
		INSTRUCTION_OUT_IF	 : in std_logic_vector(NBIT - 1 downto 0)); -- instruction read from DRAM
end RISC_V;

architecture struct of RISC_V is

	component MUX21
		port(
			in_0 : in std_logic_vector(NBIT - 1 downto 0);
			in_1 : in std_logic_vector(NBIT - 1 downto 0);
			
			sel  : in std_logic;
			
			out_mux : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	component I_ENC
		port(
			OPCODE        : in std_logic_vector(OPC_SIZE - 1 downto 0);
			FUNCT         : in std_logic_vector(FUNCT_SIZE - 1 downto 0);
			
			INSTRUCTION   : out INST);
	end component;
	
	component CU_RISC_V
		port(
			CLK : in std_logic;
			RST : in std_logic;
			
			STALL       : in std_logic;
			INSTRUCTION : INST;
			
			MUX_SEL_B   : out std_logic;
			ALU_INST    : out INST;

			MEM_EN      : out std_logic;
			READNOTWRITE: out std_logic;

			MUX_SEL_WB  : out std_logic;
			WR_RF       : out std_logic);
	end component;

	component FU
		port(
			RST : in std_logic;
			
			EX_MEM_RD : in std_logic_vector(RF_SIZE - 1 downto 0);
			MEM_WB_RD : in std_logic_vector(RF_SIZE - 1 downto 0);
			ID_EX_RS1 : in std_logic_vector(RF_SIZE - 1 downto 0);
			ID_EX_RS2 : in std_logic_vector(RF_SIZE - 1 downto 0);
			
			ID_EX_OPC  : in INST;
			EX_MEM_OPC : in INST;
			MEM_WB_OPC : in INST;
			
			FW_EX_MEM_A   : out std_logic;
			FW_MEM_WB_A   : out std_logic;
			FW_EX_MEM_B   : out std_logic;
			FW_MEM_WB_B   : out std_logic;
			FW_EX_MEM_C   : out std_logic;
			FW_MEM_WB_C   : out std_logic); -- DATA TO BE WRITTEN IN MEMORY
	end component;

	component MUX_SEL_ENC
		port(
			FW_EX_MEM_A   : in std_logic;
			FW_MEM_WB_A   : in std_logic;
			FW_EX_MEM_B   : in std_logic;
			FW_MEM_WB_B   : in std_logic;
			FW_EX_MEM_C   : in std_logic;
			FW_MEM_WB_C   : in std_logic;

			CU_MUX_SEL_B : in std_logic;
			
			MUX_SEL_A 	 : out std_logic_vector(1 downto 0);
			MUX_SEL_B 	 : out std_logic_vector(1 downto 0);
			MUX_SEL_C 	 : out std_logic_vector(1 downto 0));
	end component;

	component HU
		port(
			RST : in std_logic;
			
			ID_EX_RD   : in std_logic_vector(RF_SIZE - 1 downto 0);
			EX_MEM_RD  : in std_logic_vector(RF_SIZE - 1 downto 0);
			IF_ID_RS1  : in std_logic_vector(RF_SIZE - 1 downto 0);
			IF_ID_RS2  : in std_logic_vector(RF_SIZE - 1 downto 0);
			
			ID_EX_OPC  : in INST;
			IF_ID_OPC  : in INST;
			EX_MEM_OPC : in INST;
			
			STALL    : out std_logic);
	end component;
	
	component BFU
		port(
			RST : in std_logic;
			
			EX_MEM_RD : in std_logic_vector(RF_SIZE - 1 downto 0);
			IF_ID_RS1 : in std_logic_vector(RF_SIZE - 1 downto 0);
			IF_ID_RS2 : in std_logic_vector(RF_SIZE - 1 downto 0);
			
			IF_ID_OPC  : in INST;
			EX_MEM_OPC : in INST;
			
			FW_EX_MEM_RS1  : out std_logic;
			FW_EX_MEM_RS2  : out std_logic);
	end component;

	component BTB 
		port( CLK 		 	     : in std_logic;
			  RST 		 	     : in std_logic;
			  
			  PRED_T_NOT_T       : in std_logic;
			  PRED_T_T           : in std_logic;
			  PRED_NOT_T_T       : in std_logic;
			  PRED_NOT_T_NOT_T   : in std_logic;

			  UPDATE_EN          : in std_logic;
			  BTB_ADDR   	     : in std_logic_vector(NBIT_BTB_ADDR - 1 downto 0);
			  UPDATE_TARGET_PC   : in std_logic_vector(NBIT - 1 downto 0);
			  UPDATE_ADDRESS     : in std_logic_vector(NBIT_BTB_ADDR - 1 downto 0);
			  
			  TARGET_PC	 	     : out std_logic_vector(NBIT - 1 downto 0);
			  IS_TAKEN       	 : out std_logic);
	end component;
	
	component PC_SELECTOR 
		port(
			IS_BRANCH_TAKEN      : in std_logic;
			IS_BRANCH_TAKEN_D    : in std_logic;
			RESTORE_PC           : in std_logic;
			TAKEN_BRANCH_FROM_ID : in std_logic;
			INSTRUCTION			 : in INST;
			
			PC_MUX_SEL           : out std_logic_vector(1 downto 0));
	end component;
	
	component BRANCH_CU
		port( 
			  EFFECTIVE_OUTCOME : in std_logic;
			  IS_BRANCH_TAKEN   : in std_logic;
			  INSTR             : in INST;
			  STALL				: in std_logic;
	 
			  UPDATE_EN         : out std_logic;
			  FLUSH             : out std_logic;
			  RESTORE_PC        : out std_logic;
	 
			  PRED_T_NOT_T      : out std_logic;
			  PRED_T_T          : out std_logic;
			  PRED_NOT_T_T      : out std_logic;
			  PRED_NOT_T_NOT_T  : out std_logic);
	end component;

	component FETCH
		port(
			CLK               : in std_logic;
			RST               : in std_logic;
			
			STALL			  : in std_logic;			
			INSTRUCTION_ID	  : in INST;
			PC_FROM_ID_BRANCH : in std_logic_vector(NBIT - 1 downto 0);
			PC_FROM_BTB       : in std_logic_vector(NBIT - 1 downto 0);			
			SEL_MUX           : in std_logic_vector(1 downto 0);
			
			PC_TO_IMEM        : inout std_logic_vector(NBIT - 1 downto 0));
	end component;
	
    component DECODE
		port(
			CLK : in std_logic;
			RST : in std_logic;
			INSTRUCTION : in std_logic_vector(NBIT - 1 downto 0);
			INSTRUCTION_WB : in std_logic_vector(NBIT - 1 downto 0);
			INST_T		: in INST;
			PC 			: in std_logic_vector(NBIT - 1 downto 0);
			RF_WRITE_IN : in std_logic_vector(NBIT - 1 downto 0);
			
			WR			: in std_logic;
			STALL		: in std_logic;
			
			FW_EX_MEM_RS1  : in std_logic;
		    FW_EX_MEM_RS2  : in std_logic;
		    OUTALU_EX_MEM  : in std_logic_vector(NBIT - 1 downto 0);
		
			PC_BRANCH_ID	  : out std_logic_vector(NBIT - 1 downto 0);
			EFFECTIVE_OUTCOME : out std_logic;
			
			A			: inout std_logic_vector(NBIT - 1 downto 0);
			B			: inout std_logic_vector(NBIT - 1 downto 0);
			IMM			: out std_logic_vector(NBIT - 1 downto 0);
			INSTRUCTION_OUT : out std_logic_vector(NBIT - 1 downto 0);
			PC_OUT : out std_logic_vector(NBIT - 1 downto 0));
	end component;

	component EXECUTE
		port(	
			PC		 		 : in std_logic_vector(NBIT - 1 downto 0);
			INSTRUCTION_IN   : in std_logic_vector(NBIT - 1 downto 0);
			ALU_CONTROL		 : in INST;

			A 				 : in std_logic_vector(NBIT - 1 downto 0);
			B 				 : in std_logic_vector(NBIT - 1 downto 0);
			IMM 			 : in std_logic_vector(NBIT - 1 downto 0);
			
			FW_OUTALU_EX_MEM : in std_logic_vector(NBIT - 1 downto 0);
			FW_OUTVAL_MEM_WB : in std_logic_vector(NBIT - 1 downto 0);
			
			MUX_SEL_A 		 : in std_logic_vector(1 downto 0);
			MUX_SEL_B 		 : in std_logic_vector(1 downto 0);
			MUX_SEL_C   	 : in std_logic_vector(1 downto 0);

			OUT_ALU 		 : out std_logic_vector(NBIT - 1 downto 0);
			INSTRUCTION_OUT  : out std_logic_vector(NBIT - 1 downto 0);
			DATAIN_MEM 		 : out std_logic_vector(NBIT - 1 downto 0));
	end component;
	

	signal PC_FROM_ID_BRANCH        : std_logic_vector(NBIT - 1 downto 0);
	signal PC_FROM_BTB              : std_logic_vector(NBIT - 1 downto 0);
	signal SEL_MUX				    : std_logic_vector(1 downto 0);
	
	signal BRANCH_PREDICTION        : std_logic;
	signal BRANCH_PREDICTION_TO_BCU : std_logic;
	signal RESTORE_PC               : std_logic;
	signal EFFECTIVE_BRANCH_OUTCOME : std_logic;
	
	signal UPDATE_EN                : std_logic;
	signal PRED_T_NOT_T      		: std_logic;
	signal PRED_T_T          		: std_logic;
	signal PRED_NOT_T_T      		: std_logic;
	signal PRED_NOT_T_NOT_T  		: std_logic;

	signal UPDATE_TARGET_PC			: std_logic_vector(NBIT - 1 downto 0);
	signal UPDATE_ADDRESS           : std_logic_vector(NBIT_BTB_ADDR - 1 downto 0);
	
	-- PIPELINE REGISTERS SIGNALS
	signal PC_IN_ID			     : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_IN_ID     :std_logic_vector(NBIT - 1 downto 0);
	signal OP_ID				 : INST;

	signal A_OUT_ID             : std_logic_vector(NBIT - 1 downto 0); 
	signal B_OUT_ID             : std_logic_vector(NBIT - 1 downto 0);
	signal IMM_OUT_ID           : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_OUT_ID   : std_logic_vector(NBIT - 1 downto 0);
	signal PC_OUT_ID   		    : std_logic_vector(NBIT - 1 downto 0);	
	signal A_IN_EX              : std_logic_vector(NBIT - 1 downto 0);
	signal B_IN_EX              : std_logic_vector(NBIT - 1 downto 0);
	signal IMM_IN_EX            : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_IN_EX    : std_logic_vector(NBIT - 1 downto 0);
	signal PC_IN_EX 		     : std_logic_vector(NBIT - 1 downto 0);
	signal OP_EX				 : INST;

	signal OUTALU_OUT_EX		 : std_logic_vector(NBIT - 1 downto 0);
	signal DATAMEM_OUT_EX       : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_OUT_EX   : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_IN_MEM   : std_logic_vector(NBIT - 1 downto 0);
	signal OP_MEM				 : INST;

	signal OUTALU_OUT_MEM       : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_OUT_MEM  : std_logic_vector(NBIT - 1 downto 0);
	signal OUTALU_IN_WB         : std_logic_vector(NBIT - 1 downto 0);
	signal MEMD_IN_WB           : std_logic_vector(NBIT - 1 downto 0);
	signal INSTRUCTION_IN_WB    : std_logic_vector(NBIT - 1 downto 0);
	signal OP_WB				 : INST;

	signal MUX_SEL_A 			 : std_logic_vector(1 downto 0);
	signal MUX_SEL_B 			 : std_logic_vector(1 downto 0);
	signal MUX_SEL_C 			 : std_logic_vector(1 downto 0);
	signal FW_EX_MEM_A           : std_logic;
	signal FW_MEM_WB_A           : std_logic;
	signal FW_EX_MEM_B           : std_logic;
	signal FW_MEM_WB_B           : std_logic;
	signal FW_EX_MEM_C           : std_logic;
	signal FW_MEM_WB_C           : std_logic;

	signal RF_WRITE_IN			 : std_logic_vector(NBIT - 1 downto 0);

	signal BRANCH_FW_EX_MEM_RS1 :  std_logic;
	signal BRANCH_FW_EX_MEM_RS2 :  std_logic;

	signal STALL : std_logic;
	signal FLUSH_B : std_logic;
	signal FLUSH_J : std_logic;
	signal FLUSH : std_logic;

	signal CU_MUX_SEL_B     : std_logic;
 	signal ALU_INST    	    : INST;		
	signal MUX_SEL_WB    	: std_logic;
	signal WR_RF  			: std_logic;
	
begin

	FLUSH <= FLUSH_B or FLUSH_J; -- a flush is needed both if the branch control unit asserts it or a JAL is decoded
	FLUSH_J <= '1' when OP_ID = JAL else '0';
	
	-- in order to let the branch management units perform the right comparisons, the branch prediction
	-- has to be delayed of one clock cycle, since it is done during the ID stage
	-- while the effective outcome is generated only in the ID one
	IS_TAKEN_BCU: process(CLK, RST)
		begin
			if RST = '1' then
				BRANCH_PREDICTION_TO_BCU <= '0';
			elsif CLK'event and CLK = '1' and STALL = '0' then
				BRANCH_PREDICTION_TO_BCU <= BRANCH_PREDICTION;
			end if;
	end process;
	
	-- process in which all pipe registers are inferred
	-- if a stall or flush is not present, a simple "shift" of data between stage is done
	-- otherwise, proper actions are performed
	PIPE_REGS : process(RST, CLK) 
		begin
			if RST = '1' then
				-- IF/ID
				PC_IN_ID			<= (others => '0');
				INSTRUCTION_IN_ID   <= "00000000000000000000000000010011"; -- ADDI x0, 0, 0
				-- ID/EX                     
				A_IN_EX             <= (others => '0');
				B_IN_EX             <= (others => '0');
				IMM_IN_EX           <= (others => '0');
				INSTRUCTION_IN_EX   <= "00000000000000000000000000010011"; -- ADDI x0, 0, 0
				PC_IN_EX 		    <= (others => '0');
				OP_EX				<= ADDI;
				-- EX/MEM                   
				OUTALU_IN_MEM       <= (others => '0');
				DATAMEM_IN_MEM      <= (others => '0');
				INSTRUCTION_IN_MEM  <= "00000000000000000000000000010011"; -- ADDI x0, x0, 0
				OP_MEM           	<= ADDI;
				-- MEM/WB                    
				OUTALU_IN_WB        <= (others => '0');
				MEMD_IN_WB          <= (others => '0');
				INSTRUCTION_IN_WB   <= "00000000000000000000000000010011"; -- ADDI x0, x0, 0
				OP_WB				<= ADDI;
			elsif CLK'event and CLK = '1' then
				-- IF/ID
				if STALL = '0' and FLUSH = '0' then
					PC_IN_ID			<= PC_TO_IMEM;
					INSTRUCTION_IN_ID   <= INSTRUCTION_OUT_IF;
				-- to stall, the instruction in ID stage is decoded again
				elsif STALL = '1' then
					PC_IN_ID <= PC_IN_ID;
					INSTRUCTION_IN_ID <= INSTRUCTION_IN_ID;
				-- to flush, an ADDI R0, R0, 0 is inserted
				elsif FLUSH = '1' then
					PC_IN_ID <= (others => '0');
					INSTRUCTION_IN_ID <= "00000000000000000000000000010011"; -- ADDI x0, x0, 0
				end if;
				-- ID/EX
				A_IN_EX             <= A_OUT_ID;
				B_IN_EX             <= B_OUT_ID;
				IMM_IN_EX           <= IMM_OUT_ID;
				
				
				if STALL = '0' then
					INSTRUCTION_IN_EX   <= INSTRUCTION_OUT_ID;
					OP_EX				<= OP_ID;
				-- if stall is asserted, the instruction in EX stage must be a ADDI R0, R0, 0
				else
					INSTRUCTION_IN_EX   <= "00000000000000000000000000010011"; -- ADDI x0, x0, 0
					OP_EX				<= ADDI;
				end if;
				
				PC_IN_EX 		    <= PC_OUT_ID; 
				-- EX/MEM
				OUTALU_IN_MEM       <= OUTALU_OUT_EX;
				DATAMEM_IN_MEM      <= DATAMEM_OUT_EX;
				INSTRUCTION_IN_MEM  <= INSTRUCTION_OUT_EX;
				OP_MEM           	<= OP_EX;
				-- MEM/WB
				OUTALU_IN_WB        <= OUTALU_IN_MEM;
				MEMD_IN_WB          <= MEMD_OUT_MEM;
				INSTRUCTION_IN_WB   <= INSTRUCTION_IN_MEM;
				OP_WB				<= OP_MEM;
			end if;
	end process;
	
	INSTR_ENC : I_ENC port map(OPCODE => INSTRUCTION_IN_ID(6 downto 0), FUNCT => INSTRUCTION_IN_ID(14 downto 12), INSTRUCTION => OP_ID);
	
	CONTROL_UNIT : CU_RISC_V port map(CLK => CLK,
								RST => RST,
								
								STALL => STALL,
								INSTRUCTION => OP_ID,

								MUX_SEL_B => CU_MUX_SEL_B,
								ALU_INST  => ALU_INST,
								
								MEM_EN => MEM_EN,
								READNOTWRITE => READNOTWRITE,
								
								MUX_SEL_WB => MUX_SEL_WB,
								WR_RF => WR_RF);
	
	FETCH_STG : FETCH port map(CLK => CLK,
								RST => RST,
								INSTRUCTION_ID => OP_ID,
								STALL => STALL,
								PC_FROM_ID_BRANCH => PC_FROM_ID_BRANCH,
								PC_FROM_BTB => PC_FROM_BTB,
								SEL_MUX => SEL_MUX,
								PC_TO_IMEM => PC_TO_IMEM);
	
	BRANCH_FORWARDING_UNIT : BFU port map(RST => RST,
	
										EX_MEM_RD => INSTRUCTION_IN_MEM(11 downto 7),
										IF_ID_RS1 => INSTRUCTION_IN_ID(19 downto 15),
										IF_ID_RS2 => INSTRUCTION_IN_ID(24 downto 20),
										
										IF_ID_OPC => OP_ID,
										EX_MEM_OPC => OP_MEM,
										
										FW_EX_MEM_RS1 =>BRANCH_FW_EX_MEM_RS1, 
										FW_EX_MEM_RS2 =>BRANCH_FW_EX_MEM_RS2);
	
	DECODE_STG : DECODE port map(CLK => CLK,
								RST => RST,
	
								INSTRUCTION => INSTRUCTION_IN_ID,
								INSTRUCTION_WB => INSTRUCTION_IN_WB,
								PC => PC_IN_ID,
								INST_T => OP_ID,
								RF_WRITE_IN => RF_WRITE_IN,
								
			                    WR => WR_RF,
								STALL => STALL,
								
			                    FW_EX_MEM_RS1 => BRANCH_FW_EX_MEM_RS1,
								FW_EX_MEM_RS2 => BRANCH_FW_EX_MEM_RS2,
								OUTALU_EX_MEM => OUTALU_IN_MEM,
								
			                    PC_BRANCH_ID => PC_FROM_ID_BRANCH,
								EFFECTIVE_OUTCOME => EFFECTIVE_BRANCH_OUTCOME,
								
								A => A_OUT_ID,
								B => B_OUT_ID,
								IMM => IMM_OUT_ID,
								INSTRUCTION_OUT => INSTRUCTION_OUT_ID,
								PC_OUT => PC_OUT_ID);
			
	EXECUTE_STG : EXECUTE port map(PC => PC_IN_EX,
									INSTRUCTION_IN => INSTRUCTION_IN_EX,
									ALU_CONTROL => ALU_INST,
									
									A => A_IN_EX,
									B => B_IN_EX,
									IMM => IMM_IN_EX,
									
									FW_OUTALU_EX_MEM => OUTALU_IN_MEM,
									FW_OUTVAL_MEM_WB => RF_WRITE_IN,
									
									MUX_SEL_A => MUX_SEL_A,
									MUX_SEL_B => MUX_SEL_B,
								    MUX_SEL_C => MUX_SEL_C,
									
									OUT_ALU => OUTALU_OUT_EX,
									INSTRUCTION_OUT => INSTRUCTION_OUT_EX,
									DATAIN_MEM => DATAMEM_OUT_EX);
	
	WB_MUX21 : MUX21 port map(in_0 => OUTALU_IN_WB, in_1 => MEMD_IN_WB, sel => MUX_SEL_WB, out_mux => RF_WRITE_IN);

	PC_SEL : PC_SELECTOR port map(IS_BRANCH_TAKEN => BRANCH_PREDICTION,
								IS_BRANCH_TAKEN_D => BRANCH_PREDICTION_TO_BCU,
								RESTORE_PC => RESTORE_PC,
								TAKEN_BRANCH_FROM_ID => EFFECTIVE_BRANCH_OUTCOME,
								INSTRUCTION => OP_ID,
								
								PC_MUX_SEL => SEL_MUX);
	
	FORWARDING_UNIT : FU port map(RST => RST,
	
								EX_MEM_RD => INSTRUCTION_IN_MEM(11 downto 7),
								MEM_WB_RD => INSTRUCTION_IN_WB(11 downto 7),
								ID_EX_RS1 => INSTRUCTION_IN_EX(19 downto 15), 
								ID_EX_RS2 => INSTRUCTION_IN_EX(24 downto 20),
								
								ID_EX_OPC => OP_EX,
								EX_MEM_OPC => OP_MEM,
								MEM_WB_OPC => OP_WB,
								
								FW_EX_MEM_A   => FW_EX_MEM_A,
								FW_MEM_WB_A   => FW_MEM_WB_A,
								FW_EX_MEM_B   => FW_EX_MEM_B,
								FW_MEM_WB_B   => FW_MEM_WB_B,
								FW_EX_MEM_C   => FW_EX_MEM_C,
								FW_MEM_WB_C   => FW_MEM_WB_C);
	
	HAZARD_UNIT : HU port map(RST => RST,
	
							ID_EX_RD => INSTRUCTION_IN_EX(11 downto 7),
							EX_MEM_RD => INSTRUCTION_IN_MEM(11 downto 7),
							IF_ID_RS1 => INSTRUCTION_IN_ID(19 downto 15),
							IF_ID_RS2 => INSTRUCTION_IN_ID(24 downto 20),
							
							ID_EX_OPC => OP_EX,
							IF_ID_OPC => OP_ID,
							EX_MEM_OPC => OP_MEM,
							
							STALL => STALL);
							
	MUX_SEL_ENCODER : MUX_SEL_ENC port map(FW_EX_MEM_A   => FW_EX_MEM_A,
											FW_MEM_WB_A   => FW_MEM_WB_A,
											FW_EX_MEM_B   => FW_EX_MEM_B,
											FW_MEM_WB_B   => FW_MEM_WB_B,
											FW_EX_MEM_C   => FW_EX_MEM_C,
											FW_MEM_WB_C   => FW_MEM_WB_C,
											
											CU_MUX_SEL_B => CU_MUX_SEL_B,
											
											MUX_SEL_A => MUX_SEL_A,
											MUX_SEL_B => MUX_SEL_B,
											MUX_SEL_C => MUX_SEL_C);
	
	BRANCH_CONTROL : BRANCH_CU port map(EFFECTIVE_OUTCOME => EFFECTIVE_BRANCH_OUTCOME,
										IS_BRANCH_TAKEN => BRANCH_PREDICTION_TO_BCU,
										INSTR => OP_ID,
										STALL => STALL,
										
										UPDATE_EN => UPDATE_EN,
										FLUSH => FLUSH_B,
										RESTORE_PC => RESTORE_PC,
										
										PRED_T_NOT_T => PRED_T_NOT_T,
										PRED_T_T => PRED_T_T,
										PRED_NOT_T_T => PRED_NOT_T_T,
										PRED_NOT_T_NOT_T => PRED_NOT_T_NOT_T);
										
	BRANCH_TARGET_BUFFER : BTB port map(CLK => CLK,
										RST => RST,
										
										PRED_T_NOT_T => PRED_T_NOT_T,
										PRED_T_T => PRED_T_T,
										PRED_NOT_T_T => PRED_NOT_T_T,
										PRED_NOT_T_NOT_T => PRED_NOT_T_NOT_T,
										
										UPDATE_EN => UPDATE_EN,
										UPDATE_TARGET_PC => PC_FROM_ID_BRANCH,
										UPDATE_ADDRESS => PC_IN_ID(6 downto 2),									
										BTB_ADDR => PC_TO_IMEM(6 downto 2),
										
										TARGET_PC => PC_FROM_BTB,
										IS_TAKEN => BRANCH_PREDICTION); -- resize btb address							
				
end struct;