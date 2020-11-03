library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity IIR_FILTER_ADVANCED is
	port (	CLK   : in std_logic;
				RST_n : in std_logic;
				VIN   : in std_logic;
				DIN   : in std_logic_vector(NBIT-1 downto 0);
				A1	  : in std_logic_vector(NBIT-1 downto 0);
				A2	  : in std_logic_vector(NBIT-1 downto 0);
				B0	  : in std_logic_vector(NBIT-1 downto 0);
				B1	  : in std_logic_vector(NBIT-1 downto 0);
				B2	  : in std_logic_vector(NBIT-1 downto 0);
				A1B1  : in std_logic_vector(NBIT-1 downto 0);
				A2B1  : in std_logic_vector(NBIT-1 downto 0);
				VOUT  : out std_logic;
				DOUT  : out std_logic_vector(NBIT-1 downto 0));
end IIR_FILTER_ADVANCED;

architecture structural of IIR_FILTER_ADVANCED is
	type shift_registers_vector is array (0 to 2) of std_logic_vector(NBIT-1 downto 0);
	type shift_registers_vector_ext is array (0 to 2) of std_logic_vector(2*NBIT-1 downto 0);
	
	signal Vin_delayed_1			: std_logic;							-- 1-clock-cycle-delayed VIN 
	signal Din_out_reg				: std_logic_vector(NBIT-1 downto 0);
	signal Dout_ext				    : std_logic_vector(NBIT-1 downto 0);
	
	signal sw			 	: shift_registers_vector;				-- shift registers for w[n]
	signal fb_0			 	: std_logic_vector(NBIT-1 downto 0);	-- feed-back network values, to be subtracted by x[n]
	signal fb_1			 	: std_logic_vector(NBIT-1 downto 0);
	signal fb_ext_0		 	: std_logic_vector(2*NBIT-1 downto 0);	-- feed-back network values on 2*NBIT
	signal fb_ext_1		 	: std_logic_vector(2*NBIT-1 downto 0);
	signal w 				: std_logic_vector(NBIT-1 downto 0);	-- w[n]
	signal psum_b			: std_logic_vector(NBIT-1 downto 0);	-- sum of fb[i] to be subtracted from x[n]
	
	signal x_1 				: std_logic_vector(NBIT-1 downto 0);	-- x[n-1]
	signal pipe_a_0			: std_logic_vector(NBIT-1 downto 0);	-- output of first set of pipeline registers
	signal pipe_a_1         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_2         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_3         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_4         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_0_ext		: std_logic_vector(2*NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_1_ext     : std_logic_vector(2*NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_2_ext     : std_logic_vector(2*NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_3_ext     : std_logic_vector(2*NBIT-1 downto 0);  -- extended output of mutput of second set of pipeline registers
	signal pipe_a_4_ext     : std_logic_vector(2*NBIT-1 downto 0);  -- extended output of mutput of second set of pipeline registers
	signal pipe_a_0_outmul		: std_logic_vector(NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_1_outmul     : std_logic_vector(NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_2_outmul     : std_logic_vector(NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_3_outmul     : std_logic_vector(NBIT-1 downto 0);  -- extended output of mutput of second set of pipeline registers
	signal pipe_a_4_outmul     : std_logic_vector(NBIT-1 downto 0);  -- extended output of mutput of second set of pipeline registers
	
	signal outadd_0 		: std_logic_vector(NBIT-1 downto 0);	-- output of last stage adder
	signal outadd_1			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder
	signal outadd_2			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder

	signal pipe_b_0 		: std_logic_vector(NBIT-1 downto 0);	-- output of last stage adder
	signal pipe_b_1			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder
	signal pipe_b_2			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder
	signal pipe_b_3			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder
begin
	
	fb_ext_0 	<= signed(sw(0))*signed(A1);
	fb_0		<= fb_ext_0(2*NBIT-2 downto NBIT-1);
	fb_ext_1 	<= signed(sw(1))*signed(A2);
	fb_1		<= fb_ext_1(2*NBIT-2 downto NBIT-1);
	psum_b		<= fb_0 + fb_1;	

	w 	  		<= Din_out_reg - psum_b;
	
	pipe_a_0_ext <= signed(pipe_a_0) * signed(B0);
	pipe_a_1_ext <= signed(pipe_a_1) * signed(A1B1);
	pipe_a_2_ext <= signed(pipe_a_2) * signed(B2);
	pipe_a_3_ext <= signed(pipe_a_3) * signed(A2B1);
	pipe_a_4_ext <= signed(pipe_a_4) * signed(B1);
	
	pipe_a_0_outmul <= pipe_a_0_ext(NBIT*2-2 downto NBIT-1);
	pipe_a_1_outmul <= pipe_a_1_ext(NBIT*2-2 downto NBIT-1);
	pipe_a_2_outmul <= pipe_a_2_ext(NBIT*2-2 downto NBIT-1);
	pipe_a_3_outmul <= pipe_a_3_ext(NBIT*2-2 downto NBIT-1);
	pipe_a_4_outmul <= pipe_a_4_ext(NBIT*2-2 downto NBIT-1);
	
	outadd_0	<= pipe_a_4_outmul - pipe_a_3_outmul;
	outadd_1	<= pipe_b_3 + pipe_b_2;
	outadd_2	<= outadd_1 - pipe_b_1;
	DOUT_ext	<= outadd_2 + pipe_b_0;
	
	
	
	IIR: process(VIN, CLK, RST_n)
			begin
				if (RST_n = '0') then
					Vin_delayed_1 <= '0';
					pipe_a_0 <= (others => '0');
					pipe_a_1 <= (others => '0');
					pipe_a_2 <= (others => '0');
					pipe_a_3 <= (others => '0');
					pipe_a_4 <= (others => '0');
					pipe_b_0 <= (others => '0');
					pipe_b_1 <= (others => '0');
					pipe_b_2 <= (others => '0');
					pipe_b_3 <= (others => '0');
					x_1		 <= (others =>'0');
					DOUT 	 <= (others => '0');
					sw 		 <= (others => (others => '0'));
					VOUT 	 <= '0';
				elsif CLK' event and CLK = '1' then 
					if VIN = '1' then
						Vin_delayed_1 <= VIN;
						Din_out_reg   <= DIN;
					end if;
					if Vin_delayed_1 = '1' then
						sw(0)    <= w;
						sw(1)    <= sw(0);
						sw(2)	 <= sw(1);
						x_1		 <= Din_out_reg;
						
						pipe_a_0 <= w;
						pipe_a_1 <= sw(1);
						pipe_a_2 <= sw(1);
						pipe_a_3 <= sw(2);
						pipe_a_4 <= x_1; 
						
						pipe_b_0 <= pipe_a_0_outmul;
						pipe_b_1 <= pipe_a_1_outmul;
						pipe_b_2 <= pipe_a_2_outmul;
						pipe_b_3 <= outadd_0;
						
						DOUT  	 <= DOUT_ext;
						VOUT 	 <= '1';				
					end if;
				end if;
	end process;
	
end structural;
