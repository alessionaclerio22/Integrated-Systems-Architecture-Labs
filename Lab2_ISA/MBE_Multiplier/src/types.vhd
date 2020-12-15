library ieee; 
use ieee.std_logic_1164.all; 

package types is 
	type pp_matrix is array (0 to 16) of std_logic_vector(32 downto 0);		-- type used for the array in which each partial product will be stored
	type d_type is array (0 to 6, 0 to 63) of std_logic_vector(0 to 16);	-- three-dimensional matrix in which the "V-shape" structure made up of partial 
																			-- products will be stored. The first index (0 to 6) refers to the current level
																			-- of reduction, the second one (0 to 63) indicates the current column and the last
																			-- one (0 to 16) the row. Having 17 partial products, 17 rows will be present, while
																			-- 64 columns are due to the worst case given by the lenght of the first row in the
																			-- "V-shaped" matrix
																			
	type d_max is array (0 to 6) of integer;								-- array used to know the maximum height of the tree at the next level	
	type n_res is array (6 downto 0, 0 to 63) of integer;					-- matrix used to know, for each column, how many dots go over the maximum
																			-- height of the next level
end package;