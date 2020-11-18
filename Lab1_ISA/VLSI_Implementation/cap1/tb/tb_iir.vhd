library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity tb_iir is
end entity;

architecture arc of tb_iir is

	constant Ts : time := 10 ns;
	signal CLK   : std_logic;								
	signal RST_n : std_logic;								
	signal VIN   : std_logic;								
	signal DIN   : std_logic_vector(NBIT-1 downto 0);		
	signal A1	  : std_logic_vector(NBIT-1 downto 0);		
	signal A2	  : std_logic_vector(NBIT-1 downto 0);      
	signal B0	  : std_logic_vector(NBIT-1 downto 0);      
	signal B1	  : std_logic_vector(NBIT-1 downto 0);      
	signal B2	  : std_logic_vector(NBIT-1 downto 0);      
	signal VOUT  : std_logic;								
	signal DOUT  : std_logic_vector(NBIT-1 downto 0);		

	component IIR_Filter 
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
	end component;


begin

	A1 <= conv_std_logic_vector(-95,9);
	A2 <= conv_std_logic_vector(50,9);
	B0 <= conv_std_logic_vector(52,9);
	B1 <= conv_std_logic_vector(105,9);
	B2 <= conv_std_logic_vector(52,9);  
  
  
	p: process
		begin			
			VIN <= '0';
			DIN <= conv_std_logic_vector(0,9);
			wait for 17 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(0,9);
			wait for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(79,9);
			wait  for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(0,9);
			wait  for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(207,9);
			wait  for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(0,9);
			wait  for 12 ns;
			VIN <= '0';
			DIN <= conv_std_logic_vector(255,9);
			wait  for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(-1,9);
			wait  for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(207,9);
			wait  for 12 ns;
			VIN <= '1';
			DIN <= conv_std_logic_vector(-1,9);	
			wait;
	end process;
  
  
    process
		begin
			if (CLK = 'U') then
				CLK <= '0';
			else
				CLK <= not(CLK);
			end if;
			wait for Ts/2;
	end process;


	process
		begin 
			RST_n <= '0';
			wait for 3*Ts/2;
			RST_n <= '1';
			wait;
	end process;
  
	IIR : IIR_Filter port map (CLK => CLK, RST_n => RST_n, A1 => A1, A2 => A2, B0 => B0, B1 => B1, B2 => B2, DIN => DIN, DOUT => DOUT, VIN => VIN, VOUT => VOUT);

end arc;