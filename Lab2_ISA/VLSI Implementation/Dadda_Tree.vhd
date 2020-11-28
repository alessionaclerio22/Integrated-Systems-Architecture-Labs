library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity Dadda_Tree is 
	port(
		pp_0       : in std_logic_vector(32 downto 0);
		pp_1       : in std_logic_vector(32 downto 0);
		pp_2       : in std_logic_vector(32 downto 0);
		pp_3       : in std_logic_vector(32 downto 0);
		pp_4       : in std_logic_vector(32 downto 0);
		pp_5       : in std_logic_vector(32 downto 0);
		pp_6       : in std_logic_vector(32 downto 0);
		pp_7       : in std_logic_vector(32 downto 0);
		pp_8       : in std_logic_vector(32 downto 0);
		pp_9       : in std_logic_vector(32 downto 0);
		pp_10      : in std_logic_vector(32 downto 0);
		pp_11      : in std_logic_vector(32 downto 0);
		pp_12      : in std_logic_vector(32 downto 0);
		pp_13      : in std_logic_vector(32 downto 0);
		pp_14      : in std_logic_vector(32 downto 0);
		pp_15      : in std_logic_vector(32 downto 0);		
		pp_16      : in std_logic_vector(31 downto 0);
		S		   : in std_logic_vector(15 downto 0);
		
		sum_out	   : out std_logic_vector(62 downto 0);
		carry_out  : out std_logic_vector(62 downto 0));
end entity;

architecture structural of Dadda_Tree is
	-- array for columns, for each level
	-- for each column at a certain level, how many bits are out of the margin (including the carry bits)
	-- From those values, the number of FAs and HAs is known.
	type pp_matrix is array (0 to 16) of std_logic_vector(32 downto 0);
	type d_type is array (0 to 6, 0 to 63) of std_logic_vector(0 to 16);
	type d_max is array (0 to 5) of integer
	type n_res is array (0 to 5, 0 to 63) of integer
	
	constant di_res : n_res := (); 
	constant d_m : d_max := (2, 3, 4, 6, 9, 13);
	signal dadda_matrix : d_type;
	signal pp : pp_matrix;
	signal Sn : std_logic_vector(15 downto 0);
begin

	for i in range 0 to 15 generate
		Sn(i) <= not(S(i));
	end generate;

	pp(0)  <= pp_0;
	pp(1)  <= pp_1;
	pp(2)  <= pp_2;
	pp(3)  <= pp_3;
	pp(4)  <= pp_4;
	pp(5)  <= pp_5;
	pp(6)  <= pp_6;
	pp(7)  <= pp_7;
	pp(8)  <= pp_8;
	pp(9)  <= pp_9;
	pp(10) <= pp_10;
	pp(11) <= pp_11;
	pp(12) <= pp_12;
	pp(13) <= pp_13;
	pp(14) <= pp_14;
	pp(15) <= pp_15;
	pp(16) <= pp_16;
	

	for i in range 0 to 63 generate
		if i < 33 then
			for j in range 0 to (i/2) generate
				dadda_matrix(6, i)(j) <= pp(j)(i - 2*j);
			end generate;
		
			if i mod 2 = 0 then
				dadda_matrix(6, i)(i/2 + 1) <= S(i/2);
			end if;
		elsif i > 35 and i <= 63 then		
			if i mod 2 = 0 then
				dadda_matrix(6, i)(0) <= '1';
				for k in range 1 to (i/2) - 2*((i - 36)/2 + 1) generate
					dadda_matrix(6, i)(k) <= pp(i/2 - 16 + k)(32 - (k - 1)*2));
				end generate;
			else 
				dadda_matrix(6, i)(0) <= S(i/2 - 16);
				for k in range 0 to ((i+1)/2) - 2*(((i + 1) - 36)/2 + 1) generate
					dadda_matrix(6, i)(k) <= pp((i + 1)/2 - 16 + k)(31 - (k - 1)*2));				
				end generate;			
			end if;
		end if;
	end generate;

	dadda_matrix(6, 33) <= S(0) & pp(1)(31) & pp(2)(29) & pp(3)(27) & pp(4)(25) & pp(5)(23) & pp(6)(21) & pp(7)(19) & pp(8)(17) & pp(9)(15) & pp(10)(13) & pp(11)(11) & pp(12)(9) & pp(13)(7) & pp(14)(5) & pp(15)(3) & pp(16)(1);
	dadda_matrix(6, 34) <= S(0) & pp(1)(32) & pp(2)(30) & pp(3)(28) & pp(4)(26) & pp(5)(24) & pp(6)(22) & pp(7)(20) & pp(8)(18) & pp(9)(16) & pp(10)(14) & pp(11)(12) & pp(12)(10) & pp(13)(8) & pp(14)(6) & pp(15)(4) & pp(16)(2);
	dadda_matrix(6, 35) <= Sn(0) & Sn(1) & pp(2)(31) & pp(3)(29) & pp(4)(27) & pp(5)(25) & pp(6)(23) & pp(7)(21) & pp(8)(19) & pp(9)(17) & pp(10)(15) & pp(11)(13) & pp(12)(11) & pp(13)(9) & pp(14)(7) & pp(15)(5) & pp(16)(3)ù;

	for l in range 6 downto 0 generate
		for c in range 0 to 63 generate
			if di_res(l, c) > d_m(l) then
				for fa in range 0 to di_res(l, c)/2 generate
					fa_gen : FA port map(A => dadda_matrix(l, c)(3*fa), B => dadda_matrix(l, c)(3*fa + 1), Ci => dadda_matrix(l, c)(3*fa + 2), Co => dadda_matrix(l - 1, c + 1)(d_m(l - 1) - fa), S=> dadda_matrix(l - 1, c)(fa));
				end generate;
				
				if di_res(l, c) mod 2 /= 0 generate
					ha_gen : HA port map(A => dadda_matrix(l, c)(3*di_res(l, c)/2) , B => dadda_matrix(l, c)(3*di_res(l, c)/2 + 1), Co => dadda_matrix(l - 1, c + 1)(d_m(l - 1) - di_res(l, c)/2), S=> dadda_matrix(l - 1, c)(di_res(l, c));
				end generate;
				
				for s in range di_res(l, c)/2 + di_res(l, c) mod 2 to d_m(l - 1) - di_res(l, c - 1)/2 - di_res(l, c - 1) mod 2 generate
					dadda_matrix(l - 1, c)(s) <= dadda_matrix(l, c)(s + di_res(l, c)/2 + di_res(l, c) mod 2);
				end generate;
			end if;
	    end generate;
	end generate;
	
end structural;