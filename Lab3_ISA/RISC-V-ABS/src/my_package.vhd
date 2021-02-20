library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package my_package is

	constant NBIT		: integer := 32;
	constant NBIT_BTB_ADDR	: integer := 5;
	constant RF_SIZE	: integer := 5;
	constant OPC_SIZE	: integer := 7;
	constant FUNCT_SIZE	: integer := 3;
	constant CW_SIZE	: integer := 5;
	constant EX_SIZE	: integer := 1;
	constant MEM_SIZE	: integer := 2;
	
	type INST is (LUI, AUIPC, JAL, BEQ, LW, SW, ADDI, ANDI, SRAI, ADD, SLT, XOR_OP, ABSV);


end package;