library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- package containing all the used constants and the instruction type

package my_package is

	constant NBIT		: integer := 32;	-- processor parallelism
	constant NBIT_BTB_ADDR	: integer := 5; -- number of bits of the address signal of the branch target buffer
	constant RF_SIZE	: integer := 5;		-- number of bits of the address signal of the RF
	constant OPC_SIZE	: integer := 7;		-- opcode number of bits
	constant FUNCT_SIZE	: integer := 3;		-- funct number of bits
	constant CW_SIZE	: integer := 5;		-- size of control word from control unit
	constant EX_SIZE	: integer := 1;		-- number of control signals to deliver to EX stage
	constant MEM_SIZE	: integer := 2;		-- number of control signals to deliver to MEM stage
	
	type INST is (LUI, AUIPC, JAL, BEQ, LW, SW, ADDI, ANDI, SRAI, ADD, SLT, XOR_OP); -- instruction type


end package;