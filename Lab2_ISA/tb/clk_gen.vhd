library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clk_gen is
  port (
    CLK     : out std_logic);
end clk_gen;

architecture beh of clk_gen is

  constant Ts : time := 10 ns;
  
  signal CLK_i : std_logic;
  
begin 

  process
  begin
    if (CLK_i = 'U') then
      CLK_i <= '0';
    else
      CLK_i <= not(CLK_i);
    end if;
    wait for Ts/2;
  end process;

  CLK <= CLK_i;
end beh;
