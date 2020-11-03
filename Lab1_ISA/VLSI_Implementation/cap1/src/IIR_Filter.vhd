library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;


entity IIR_Filter is
	 port (	CLK   : in std_logic;								-- clock signal
			RST_n : in std_logic;								-- reset signal, active low
			VIN   : in std_logic;								-- enable signal for DIN
			DIN   : in std_logic_vector(NBIT-1 downto 0);		-- input data on 9 bits
			A1	  : in std_logic_vector(NBIT-1 downto 0);		-- coefficient for the IIR Filter
			A2	  : in std_logic_vector(NBIT-1 downto 0);       -- coefficient for the IIR Filter
			B0	  : in std_logic_vector(NBIT-1 downto 0);       -- coefficient for the IIR Filter
			B1	  : in std_logic_vector(NBIT-1 downto 0);       -- coefficient for the IIR Filter
			B2	  : in std_logic_vector(NBIT-1 downto 0);       -- coefficient for the IIR Filter
			VOUT  : out std_logic;								-- enable signal for DOUT
			DOUT  : out std_logic_vector(NBIT-1 downto 0));		-- output data on 9 bits
end entity;

architecture behavioural of IIR_Filter is

	type shift_registers_vector is array (0 to 1) of std_logic_vector(NBIT-1 downto 0);			-- array of 2 elements on 9 bits
	type shift_registers_vector_ext is array (0 to 1) of std_logic_vector(2*NBIT-1 downto 0);	-- array of 2 elements on 18 bits
	
	signal Vin_delayed		: std_logic;							-- signal that is the 1-clock-cycle-delayed replica of VIN, used as enable for the internal registers
	signal Din_out_reg		: std_logic_vector(NBIT-1 downto 0);	-- output signal of the input register, that is to say 1-clock-cycle-delayed DIN
	
	signal sw			 	: shift_registers_vector;				-- array of internal registers' outputs
	signal fb			 	: shift_registers_vector;				-- array of feedback network values, already right-shifted after multiplication
	signal fb_ext		 	: shift_registers_vector_ext;			-- array of feedback network values as they are after multiplication, that is to say on 18 bits
	signal ff			 	: shift_registers_vector;				-- array of feedforward network values, already right-shifted after multiplication
	signal ff_ext		 	: shift_registers_vector_ext;           -- array of feedforward network values as they are after multiplication, that is to say on 18 bits
	signal w 				: std_logic_vector(NBIT-1 downto 0);	-- result of the subtraction Din_out_reg - psum_b
	signal psum_b			: std_logic_vector(NBIT-1 downto 0);	-- sum of feedback network values
	signal psum_f			: std_logic_vector(NBIT-1 downto 0);	-- sum of feedforward network values
	signal y_ext			: std_logic_vector(2*NBIT-1 downto 0);	-- result of w*B0 on 18 bits
	signal y 				: std_logic_vector(NBIT-1 downto 0);	-- result of w*B0 on 9 bits
	signal DOUT_ext		 	: std_logic_vector(NBIT-1 downto 0);	-- ouput before the output register

begin
	
	fb_ext(0) 	<= signed(sw(0))*signed(A1);				-- calculating the feedback network values and their sum
	fb(0)		<= fb_ext(0)(2*NBIT-2 downto NBIT-1);
	fb_ext(1) 	<= signed(sw(1))*signed(A2);
	fb(1)		<= fb_ext(1)(2*NBIT-2 downto NBIT-1);
	psum_b		<= fb(0) + fb(1);	

	ff_ext(0) 	<= signed(sw(0))*signed(B1);				-- calculating the feedforward network values and their sum
	ff(0)		<= ff_ext(0)(2*NBIT-2 downto NBIT-1);
	ff_ext(1) 	<= signed(sw(1))*signed(B2);
	ff(1)		<= ff_ext(1)(2*NBIT-2 downto NBIT-1);
	psum_f		<= ff(0) + ff(1);

	w 	  		<= Din_out_reg - psum_b;					-- subtraction between Din_out_reg and the sum of feedback network values
	y_ext	  	<= signed(w)*signed(B0);					-- calculation of w*B0 and proper right shift
	y			<= y_ext(NBIT*2-2 downto NBIT-1);
	DOUT_ext	<= y + psum_f;								-- output result
	
	-- Process in which the input data is provided to the internal circuit. If VIN is '1', Vin_delayed will be '1' in the next cycle.
	-- In this way, the internal circuit will act according to the value of Vin_delayed, as it is intended in the second process.
	IIR_1: process(CLK, RST_n)
			begin
				if (RST_n = '0') then
					Vin_delayed <= '0';
					Din_out_reg <= (others =>'0');
				elsif CLK' event and CLK = '1' then
					if (VIN = '1') then
						Din_out_reg <= DIN;
						Vin_delayed <= '1';
					else
						Vin_delayed <= '0';
						Din_out_reg <= DIN;
					end if;
				end if;
	end process;

	-- Process in which the internal registers are enabled only if Vin_delayed is '1'. Also, the result will be provided in output during the next clock cycle
	IIR_2 : process(CLK, RST_n)
		begin
			if(RST_n = '0') then
				DOUT 		<= (others => '0');
				sw 			<= (others => (others => '0'));
				VOUT 		<= '0';
			elsif(CLK' event and CLK = '1') then
				if Vin_delayed = '1' then
					VOUT  <= '1';
					sw(0) <= w;
					sw(1) <= sw(0);
					DOUT  <= DOUT_ext;
				else
					VOUT  <= '0';
					sw(0) <= sw(0);
					sw(1) <= sw(1);
					DOUT  <= DOUT_ext;
				end if;
			end if;
	end process;


	
end behavioural;
