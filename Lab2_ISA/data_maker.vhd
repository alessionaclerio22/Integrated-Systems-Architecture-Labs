library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is
  port (
    CLK  : in  std_logic;
    DATA : out std_logic_vector(31 downto 0));
end data_maker;

architecture beh of data_maker is

begin  -- beh

  process (CLK)
    file fp : text open read_mode is "./fp_samples.hex";
    variable ptr : line;
    variable val : std_logic_vector(31 downto 0);
  begin  -- process
    if CLK'event and CLK = '1' then  -- rising clock edge
      if (not(endfile(fp))) then
        readline(fp, ptr);
        hread(ptr, val);        
      end if;
      DATA <= val;
    end if;
  end process;

end beh;
