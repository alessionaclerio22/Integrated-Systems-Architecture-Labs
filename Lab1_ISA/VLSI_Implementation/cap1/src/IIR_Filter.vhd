library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;


entity IIR_Filter is
	 port (	CLK   : in std_logic;
			RST_n : in std_logic;
			VIN   : in std_logic;
			DIN   : in std_logic_vector(NBIT-1 downto 0);
			A1	  : in std_logic_vector(NBIT-1 downto 0);
			A2	  : in std_logic_vector(NBIT-1 downto 0);
			B0	  : in std_logic_vector(NBIT-1 downto 0);
			B1	  : in std_logic_vector(NBIT-1 downto 0);
			B2	  : in std_logic_vector(NBIT-1 downto 0);
			VOUT  : out std_logic;
			DOUT  : out std_logic_vector(NBIT-1 downto 0));
end entity;

architecture behavioural of IIR_Filter is

	type shift_registers_vector is array (0 to 1) of std_logic_vector(NBIT-1 downto 0);
	type shift_registers_vector_ext is array (0 to 1) of std_logic_vector(2*NBIT-1 downto 0);
	
	signal Vin_delayed		: std_logic;
	signal Din_out_reg		: std_logic_vector(NBIT-1 downto 0);
	
	signal sw			 	: shift_registers_vector;
	signal fb			 	: shift_registers_vector;
	signal fb_ext		 	: shift_registers_vector_ext;
	signal ff			 	: shift_registers_vector;
	signal ff_ext		 	: shift_registers_vector_ext;
	signal w 				: std_logic_vector(NBIT-1 downto 0);
	signal psum_b			: std_logic_vector(NBIT-1 downto 0);
	signal psum_f			: std_logic_vector(NBIT-1 downto 0);
	signal y_ext			: std_logic_vector(2*NBIT-1 downto 0);
	signal y 				: std_logic_vector(NBIT-1 downto 0);
	signal DOUT_ext		 	: std_logic_vector(NBIT-1 downto 0);

begin
	
	fb_ext(0) 	<= signed(sw(0))*signed(A1);
	fb(0)		<= fb_ext(0)(2*NBIT-2 downto NBIT-1);
	fb_ext(1) 	<= signed(sw(1))*signed(A2);
	fb(1)		<= fb_ext(1)(2*NBIT-2 downto NBIT-1);
	psum_b		<= fb(0) + fb(1);	

	ff_ext(0) 	<= signed(sw(0))*signed(B1);
	ff(0)		<= ff_ext(0)(2*NBIT-2 downto NBIT-1);
	ff_ext(1) 	<= signed(sw(1))*signed(B2);
	ff(1)		<= ff_ext(1)(2*NBIT-2 downto NBIT-1);
	psum_f		<= ff(0) + ff(1);

	w 	  		<= Din_out_reg - psum_b;
	y_ext	  	<= signed(w)*signed(B0);
	y			<= y_ext(NBIT*2-2 downto NBIT-1);
	DOUT_ext	<= y + psum_f;
	
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
