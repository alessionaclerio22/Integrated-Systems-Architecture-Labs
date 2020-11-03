library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity IIR_FILTER_ADVANCED is
	port (	CLK   : in std_logic;									-- clock signal
				RST_n : in std_logic;                           	-- reset signal, active low
				VIN   : in std_logic;                           	-- enable signal for DIN
				DIN   : in std_logic_vector(NBIT-1 downto 0);   	-- input data on 9 bits
				A1	  : in std_logic_vector(NBIT-1 downto 0);   	-- coefficient for the IIR Filter
				A2	  : in std_logic_vector(NBIT-1 downto 0);   	-- coefficient for the IIR Filter
				B0	  : in std_logic_vector(NBIT-1 downto 0);   	-- coefficient for the IIR Filter
				B1	  : in std_logic_vector(NBIT-1 downto 0);   	-- coefficient for the IIR Filter
				B2	  : in std_logic_vector(NBIT-1 downto 0);   	-- coefficient for the IIR Filter
				VOUT  : out std_logic;                          	-- enable signal for DOUT
				DOUT  : out std_logic_vector(NBIT-1 downto 0)); 	-- output data on 9 bits
end IIR_FILTER_ADVANCED;

architecture structural of IIR_FILTER_ADVANCED is
	type shift_registers_vector is array (0 to 2) of std_logic_vector(NBIT-1 downto 0);
	
	signal Vin_delayed_1	: std_logic;							-- 1-clock-cycle-delayed VIN
	signal Vin_delayed_2	: std_logic;							-- 2-clock-cycle-delayed VIN 
	signal Vin_delayed_3	: std_logic;							-- 3-clock-cycle-delayed VIN 
	signal Vin_delayed_4	: std_logic;							-- 4-clock-cycle-delayed VIN 
	signal Din_out_reg		: std_logic_vector(NBIT-1 downto 0);	-- output signal of the input register, that is to say 1-clock-cycle-delayed DIN
	signal Dout_ext         : std_logic_vector(NBIT-1 downto 0);	-- ouput before the output register
	
	signal sw			 	: shift_registers_vector;				-- shift registers for w[n]
	signal fb_0			 	: std_logic_vector(NBIT-1 downto 0);	-- feedback network values, to be subtracted by x[n]
	signal fb_1			 	: std_logic_vector(NBIT-1 downto 0);
	signal fb_ext_0		 	: std_logic_vector(2*NBIT-1 downto 0);	-- feed-back network values on 2*NBIT
	signal fb_ext_1		 	: std_logic_vector(2*NBIT-1 downto 0);
	signal w 				: std_logic_vector(NBIT-1 downto 0);	-- w[n]
	signal psum_b			: std_logic_vector(NBIT-1 downto 0);	-- sum of fb[i] to be subtracted from x[n]
	
	signal x_1 				: std_logic_vector(NBIT-1 downto 0);	-- x[n-1]
	signal pipe_a_in_2		: std_logic_vector(NBIT-1 downto 0);	-- input of first set of pipeline registers
	signal pipe_a_in_3      : std_logic_vector(NBIT-1 downto 0);    -- input of first set of pipeline registers
	signal pipe_a_in_2_ext  : std_logic_vector(2*NBIT-1 downto 0);  -- extended input of first set of registers (output of multiplier)
	signal pipe_a_in_3_ext  : std_logic_vector(2*NBIT-1 downto 0);  -- extended input of first set of registers (output of multiplier)
	signal pipe_a_0			: std_logic_vector(NBIT-1 downto 0);	-- output of first set of pipeline registers
	signal pipe_a_1         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_2         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_3         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_4         : std_logic_vector(NBIT-1 downto 0);    -- output of first set of pipeline registers
	signal pipe_a_0_ext		: std_logic_vector(2*NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_4_ext     : std_logic_vector(2*NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_a_0_outmul	: std_logic_vector(NBIT-1 downto 0);	-- output of multiplier on NBIT
	signal pipe_a_4_outmul  : std_logic_vector(NBIT-1 downto 0);    -- output of multiplier on NBIT


	signal pipe_b_0			: std_logic_vector(NBIT-1 downto 0);	-- output of second set of pipeline registers
	signal pipe_b_1         : std_logic_vector(NBIT-1 downto 0);    -- output of second set of pipeline registers
	signal pipe_b_2         : std_logic_vector(NBIT-1 downto 0);    -- output of second set of pipeline registers
	signal pipe_b_1_ext     : std_logic_vector(2*NBIT-1 downto 0);  -- extended output of multiplier on 2*NBIT
	signal pipe_b_1_outmul  : std_logic_vector(NBIT-1 downto 0);    -- output of multiplier on NBIT

	signal pipe_c_0			: std_logic_vector(NBIT-1 downto 0);	-- output of third of set of pipeline registers
	signal pipe_c_1         : std_logic_vector(NBIT-1 downto 0);    -- output of third set of pipeline registers
	signal pipe_c_2         : std_logic_vector(NBIT-1 downto 0);    -- output of third set of pipeline registers
	
	signal outadd_0 		: std_logic_vector(NBIT-1 downto 0);	-- output of last stage adder
	signal outadd_1			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder
	signal outadd_2			: std_logic_vector(NBIT-1 downto 0);    -- output of last stage adder
begin
	
	-- Loop involving the feedback signals, as in the basic version of the IIR Filter, with w as "output"
	fb_ext_0 	<= signed(sw(0))*signed(A1);
	fb_0		<= fb_ext_0(2*NBIT-2 downto NBIT-1);
	fb_ext_1 	<= signed(sw(1))*signed(A2);
	fb_1		<= fb_ext_1(2*NBIT-2 downto NBIT-1);
	psum_b		<= fb_0 + fb_1;	
	
	-- N = 0, stage 1 of pipeline
	w 	  		<= Din_out_reg - psum_b;

	-- w[n-2]*A1 and w[n-3]*A2 are calculated and then fed to pipeline registers
	pipe_a_in_2_ext  <= signed(sw(1))*signed(A1);
	pipe_a_in_2      <= pipe_a_in_2_ext(NBIT*2-2 downto NBIT-1);
	pipe_a_in_3_ext  <= signed(sw(2))*signed(A2);
	pipe_a_in_3      <= pipe_a_in_3_ext(NBIT*2-2 downto NBIT-1);


	-- N = 1, stage 2 of pipeline
	pipe_a_0_ext <= signed(pipe_a_0) * signed(B0);			-- w[n] delayed by one cycle is multiplied by B0 
	pipe_a_4_ext <= signed(pipe_a_4) * signed(B2);  		-- w[n-2] delayed by one cycle is multiplied by B2 
	pipe_a_0_outmul <= pipe_a_0_ext(NBIT*2-2 downto NBIT-1);-- shifting operands properly
	pipe_a_4_outmul <= pipe_a_4_ext(NBIT*2-2 downto NBIT-1);	
	outadd_0	<= pipe_a_3 + pipe_a_2;						-- sum of w[n-3]*A2 and w[n-2]*A1 delayed both by one cycle
	outadd_1	<= pipe_a_1 - outadd_0;						-- (x[n-1] delayed by one clock cycle) - outadd_0 

	--N = 2, third stage of pipeline
	pipe_b_1_ext <= signed(pipe_b_1)*signed(B1);
	pipe_b_1_outmul <= pipe_b_1_ext(NBIT*2-2 downto NBIT-1);

	-- N = 3, fourth stage of pipeline
	outadd_2	<= pipe_c_2 + pipe_c_1;
	DOUT_ext	<= outadd_2 + pipe_c_0;
	
	
	
	IIR: process(CLK, RST_n)
			begin
				if (RST_n = '0') then
					Vin_delayed_1 <= '0';
					Vin_delayed_2 <= '0';
					pipe_a_0 <= (others => '0');
					pipe_a_1 <= (others => '0');
					pipe_a_2 <= (others => '0');
					pipe_a_3 <= (others => '0');
					pipe_a_4 <= (others => '0');
					x_1		 <= (others =>'0');
					sw 		 <= (others => (others => '0'));
				elsif CLK' event and CLK = '1' then 
					if VIN = '1' then
						Vin_delayed_1 <= '1';
						Din_out_reg   <= DIN;
					else 
						Vin_delayed_1 <= '0';
						Din_out_reg   <= Din_out_reg;
					end if;

					if Vin_delayed_1 = '1' then
						Vin_delayed_2 <= '1';

						sw(0)    <= w;
						sw(1)    <= sw(0);
						sw(2)	 <= sw(1);
						x_1		 <= Din_out_reg;
						
						pipe_a_0 <= w;					
						pipe_a_1 <= x_1;				
						pipe_a_2 <= pipe_a_in_2;		
						pipe_a_3 <= pipe_a_in_3;		
						pipe_a_4 <= sw(1); 				
						
					else
						Vin_delayed_2 <= '0';

						sw(0)    <= sw(0);
						sw(1)    <= sw(1);
						sw(2)	 <= sw(2);
						x_1		 <= x_1;
						
						pipe_a_0 <= pipe_a_0;
						pipe_a_1 <= pipe_a_1;
						pipe_a_2 <= pipe_a_2;
						pipe_a_3 <= pipe_a_3;
						pipe_a_4 <= pipe_a_4; 
						
					end if;
				end if;
	end process;

	Vin_p : process(CLK, RST_n)
		begin
			if(RST_n = '0') then
				Vin_delayed_3 <= '0';
				Vin_delayed_4 <= '0';
				pipe_b_0 <= (others => '0');
				pipe_b_1 <= (others => '0');
				pipe_b_2 <= (others => '0');
				pipe_c_0 <= (others => '0');
				pipe_c_1 <= (others => '0');
				pipe_c_2 <= (others => '0');
				VOUT <= '0';
				DOUT 	 <= (others => '0');
			else
				if (CLK'event and CLK = '1') then
					if (Vin_delayed_2 = '1') then
						Vin_delayed_3 <= '1';
						
						pipe_b_0 <= pipe_a_0_outmul;	
						pipe_b_1 <= outadd_1;			
						pipe_b_2 <= pipe_a_4_outmul;	
					else
						Vin_delayed_3 <= '0';
						
						pipe_b_0 <= pipe_b_0;
						pipe_b_1 <= pipe_b_1;
						pipe_b_2 <= pipe_b_2;
					end if;
					
					if (Vin_delayed_3 = '1') then
						Vin_delayed_4 <= '1';

						pipe_c_0 <= pipe_b_0;
						pipe_c_2 <= pipe_b_2;
						pipe_c_1 <= pipe_b_1_outmul;
					else
						Vin_delayed_4 <= '0';

						pipe_c_0 <= pipe_c_0;
						pipe_c_1 <= pipe_c_1;
						pipe_c_2 <= pipe_c_2;
					end if;
					
					if (Vin_delayed_4 = '1') then
						VOUT <= '1';
						DOUT  	 <= DOUT_ext;
					else
						VOUT <= '0';
						DOUT  	 <= DOUT_ext;
					end if;
				end if;
			end if;
		end process;
	
end structural;
