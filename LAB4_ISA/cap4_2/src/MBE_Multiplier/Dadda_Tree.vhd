library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all; 

entity Dadda_Tree is 
	port(
		pp 		   : in pp_matrix;							-- input matrix where partial products are stored
		S		   : in std_logic_vector(15 downto 0);		-- S bits vector to properly assign to each partial product
		
		sum_out	   : out std_logic_vector(63 downto 0);		-- first of the final two partial products remained in the last level
		carry_out  : out std_logic_vector(63 downto 0));	-- second partial products of the last two remained in the last level
end entity;

architecture structural of Dadda_Tree is
	
	-- matrix used to know, for each column, how many dots go over the maximum
	-- height of the next level
	constant di_res : n_res :=
		((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,3,5,5,7,7,8,8,8,8,7,6,5,4,3,2,1,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
		 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,3,5,5,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,6,5,4,3,2,1,10,0,0,0,0,0,0,0,0,0,0,0,0),
		 (0,0,0,0,0,0,0,0,0,0,1,1,3,3,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,5,4,3,2,1,10,0,0,0,0,0,0),
		 (0,0,0,0,0,0,1,1,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,2,1,10,0,0),
		 (0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,10),
		 (0,0,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2),
		 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
	
	-- array used to know the maximum height of the tree at the next level	
	constant d_m : d_max := (2, 2, 3, 4, 6, 9, 13);
	
	signal dadda_matrix : d_type; -- refer to the description in "types.vhd"
	signal Sn : std_logic_vector(15 downto 0); -- vector containing toggled S bits
	
	component FA
		port(	A:	In	std_logic;
				B:	In	std_logic;
				Ci:	In	std_logic;
				S:	Out	std_logic;
				Co:	Out	std_logic);
	end component; 
	
	component HA
		port(	A:	In	std_logic;
				B:	In	std_logic;
				S:	Out	std_logic;
				Co:	Out	std_logic);
	end component;
	
begin
	
	-- negated S bits generation
	S_gen: for i in 0 to 15 generate
		Sn(i) <= not(S(i));
	end generate;

	-- The goal to this generate statement is to construct the "V-shape" matrix starting from the "staircase" one where partial products are stored.
	-- From matrix pp values, the level 6 of dadda_matrix ("V-shape" matrix) has to be filled.
	-- Three main steps have been identified in order to simplify the generation and the index assignment:
		-- From column 0 to 33 of level 6 of dadda_matrix;
		-- Columns 33, 34, 35 have been filled outside of the generate statement, because they do not fit in the other two cases identified;
		-- From column 36 to 63 of level 6 of dadda_matrix.
	col: for i in 0 to 63 generate
		i0:if i < 33 generate
			-- index i is used to identify the column od dadda_matrix, while j the row
			col_i: for j in 0 to (i/2) generate	-- j used to fill dadda_matrix up to the proper row
				dadda_matrix(6, i)(j) <= pp(j)(i - 2*j); -- filling with pp right values
			end generate;
		
			-- if the column is an even one, an S bit has to be added at the end of the column, but not for column 32
			i1: if i mod 2 = 0 and i /= 32 generate
				dadda_matrix(6, i)(i/2 + 1) <= S(i/2);
			end generate;
		end generate;
		
		i2: if i > 35 and i <= 63 generate	
			-- starting from column 36, the even ones start with a '1', while the odd ones start with the correspondent toggled S bit
			i3: if i mod 2 = 0 generate
				dadda_matrix(6, i)(0) <= '1'; -- assigning the '1'
				col_even: for k in  1 to  33 - i/2 generate -- filling dadda_matrix until the right row using index k
					dadda_matrix(6, i)(k) <= pp(i/2 - 17 + k)(32 - (k - 1)*2);
				end generate;
			end generate;
			
			i4: if i mod 2 /= 0 generate
				dadda_matrix(6, i)(0) <= Sn(i/2 - 16); -- assigning the negated S bits
				col_odd: for k in 1 to 33 - (i+1)/2 generate -- filling dadda_matrix until the right row using index k
					dadda_matrix(6, i)(k) <= pp((i + 1)/2 - 17 + k)(31 - (k - 1)*2);				
				end generate;			
			end generate;
		end generate;
	end generate;

	-- Properly filling the columns 33, 34, 35
	dadda_matrix(6, 33) <= S(0) & pp(1)(31) & pp(2)(29) & pp(3)(27) & pp(4)(25) & pp(5)(23) & pp(6)(21) & pp(7)(19) & pp(8)(17) & pp(9)(15) & pp(10)(13) & pp(11)(11) & pp(12)(9) & pp(13)(7) & pp(14)(5) & pp(15)(3) & pp(16)(1);
	dadda_matrix(6, 34) <= S(0) & pp(1)(32) & pp(2)(30) & pp(3)(28) & pp(4)(26) & pp(5)(24) & pp(6)(22) & pp(7)(20) & pp(8)(18) & pp(9)(16) & pp(10)(14) & pp(11)(12) & pp(12)(10) & pp(13)(8) & pp(14)(6) & pp(15)(4) & pp(16)(2);
	dadda_matrix(6, 35) <= Sn(0) & Sn(1) & pp(2)(31) & pp(3)(29) & pp(4)(27) & pp(5)(25) & pp(6)(23) & pp(7)(21) & pp(8)(19) & pp(9)(17) & pp(10)(15) & pp(11)(13) & pp(12)(11) & pp(13)(9) & pp(14)(7) & pp(15)(5) & pp(16)(3);

	-- At this point, reduction following the Dadda Algorithm has to be performed
	level: for l in 6 downto 1 generate -- index l is used for the current level of reduction. We have to reach level one, after which only two partial products will remain
		columns: for c in 0 to 63 generate	-- index c indicates the current column
			i5: if di_res(l, c) > 0 and di_res(l,c) < 10 generate -- if di_res(l, c) is greater than 0, a resource has to be allocated. The di_res(l, c) equal to 10 is managed at the end
					-- FA generation: if the number of dots outside the maximum height of next level is greater or equal to 2, a FA is surely needed.
					-- The number of generated FA is equal to the di_res(l, c) divided by 2.
					-- The sum bit has to be put in the same column but at the next level, in the row given by index f.
					-- The carry bit has to be put in the next column but at the next level, in the one of the last rows, depending on the value of (d_m(l) - 1 - f).
					FA_gen: for f in 0 to ((di_res(l, c)/2) - 1) generate
							last_carry_ex : if c /= 63 or l /= 1 generate -- Avoiding the last column of level 1
								fa_gen : FA port map(A => dadda_matrix(l, c)(3*f), B => dadda_matrix(l, c)(3*f + 1), Ci => dadda_matrix(l, c)(3*f + 2), Co => dadda_matrix(l - 1, c + 1)(d_m(l) - 1 - f), S=> dadda_matrix(l - 1, c)(f));
							end generate;
							
							-- In the last column of level 1, a carry bit is generated but we do not have to tak care of it, so it is simply ignored
							last_carry_handle : if c = 63 and l = 1 generate
								fa_lc : FA port map(A => dadda_matrix(l, c)(3*f), B => dadda_matrix(l, c)(3*f + 1), Ci => dadda_matrix(l, c)(3*f + 2), S=> dadda_matrix(l - 1, c)(f));
							end generate;
					end generate;
					
					-- If di_res(l, c) is odd, it means that a HA has to be allocated
					HA_gen: if di_res(l, c) mod 2 /= 0 generate
						ha_gen : HA port map(A => dadda_matrix(l, c)(3*(di_res(l, c)/2)) , B => dadda_matrix(l, c)(3*(di_res(l, c)/2) + 1), Co => dadda_matrix(l - 1, c + 1)(d_m(l) - 1 - (di_res(l, c)/2)), S => dadda_matrix(l - 1, c)(di_res(l, c)/2));
					end generate;
					
					-- In columns affected by the allocation on FAs and/or HAs, the next level column has to be filled also with bits that were not fed to any FAs and/or HAs.
					-- The start index has to take into account the number of FAs and/or HAs allocated for the current column,
					-- while the end index must take into account the maximum height of the next level and the number of resources allocated for the previous column,
					-- in order to take care of the carry out bits put at the end of the current column itself.
					shift_back: for s in di_res(l, c)/2 + (di_res(l, c) mod 2) to d_m(l) - 1 - di_res(l, c - 1)/2 - (di_res(l, c - 1) mod 2) generate
						dadda_matrix(l - 1, c)(s) <= dadda_matrix(l, c)(s + 3*(di_res(l, c)/2) + 2*(di_res(l, c) mod 2) - (di_res(l, c)/2 + (di_res(l, c) mod 2)));
					end generate;
			end generate;
			
			-- This statement is used to propagate the unaffected columns to the next level
			i6: if (di_res(l,c) = 0) generate
				forward_col: for fc in 0 to 16 generate
					dadda_matrix(l - 1, c)(fc) <= dadda_matrix(l, c)(fc);
				end generate;
			end generate;
			
			-- If di_res(l, c) is equal to 10, it means that no FAs or HAs have to be allocated for the current column but a carry out bit
			-- has been put at the end of the next level column.
			-- The propagation of other bits has to take this into account and tune the end parameter to d_m(l) - 2.
			-- 10 has been used to identify this particular case
			i7: if (di_res(l,c) = 10) generate 				
				forward_col: for p in 0 to d_m(l) - 2 generate
					dadda_matrix(l - 1, c)(p) <= dadda_matrix(l, c)(p);
				end generate;
			end generate; 
			
	    end generate;
	end generate;
	
	-- Assigning sum_out and carry_out with the last two partial products remained
	sum_out(0)   <= dadda_matrix(0, 0)(0);
	carry_out(0) <= dadda_matrix(0, 0)(1);
	sum_out(1)   <= dadda_matrix(0, 1)(0);
	carry_out(1) <= '0';
	
	sum_carry_gen: for i in 2 to 63 generate
		sum_out(i)   <= dadda_matrix(0, i)(0);
		carry_out(i) <= dadda_matrix(0, i)(1);
	end generate;
	
	
end structural;

-- not(a and b) = not(a) + not(b)