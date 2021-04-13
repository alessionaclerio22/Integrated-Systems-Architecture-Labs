library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all; 

-- Top entity connecting all other components

entity Dadda_Multiplier is 
	port(	
		a	: in  std_logic_vector(31 downto 0);
		b	: in  std_logic_vector(31 downto 0);
		m	: out std_logic_vector(63 downto 0));
end Dadda_Multiplier; 

architecture beh of Dadda_Multiplier is
	
	component Dadda_Tree
		port(
			pp 		   : in pp_matrix;
			S		   : in std_logic_vector(15 downto 0);
			
			sum_out	   : out std_logic_vector(63 downto 0);
			carry_out  : out std_logic_vector(63 downto 0));
	end component;
	
	component MBE_recoder
		port(	
			a				: in  std_logic_vector(32 downto 0);
			a_2				: in  std_logic_vector(32 downto 0);
			a_n				: in  std_logic_vector(32 downto 0);
			a_2_n			: in  std_logic_vector(32 downto 0);
			b_triplet       : in  std_logic_vector(2 downto 0);
			rec_out			: out std_logic_vector(32 downto 0));
	end component; 
	
	component A_gen
		port(	
			a			: in     std_logic_vector(31 downto 0);
			a_out		: inout  std_logic_vector(32 downto 0);
			a2_out		: inout  std_logic_vector(32 downto 0);
			a_n_out	 	: out    std_logic_vector(32 downto 0);
			a2_n_out	: out    std_logic_vector(32 downto 0));
	end component; 
	
	component Sign_Ext 
		port(
			b_triplet : in std_logic_vector(2 downto 0); 		   
			S  		  : out std_logic);
	end component;


	signal a_ext 			: std_logic_vector(32 downto 0);
	signal a2    			: std_logic_vector(32 downto 0);
	signal a_n   			: std_logic_vector(32 downto 0);
	signal a2_n  			: std_logic_vector(32 downto 0);
	signal first_triplet	: std_logic_vector(2 downto 0);
	signal last_triplet		: std_logic_vector(2 downto 0);
	signal pp				: pp_matrix;
	signal S_array          : std_logic_vector(15 downto 0);
	signal sum_out          : std_logic_vector(63 downto 0);
	signal carry_out        : std_logic_vector(63 downto 0);
	
begin
	
	first_triplet <= b(1) & b(0) & '0'; -- first triplet
	last_triplet  <= "00" & b(31);	-- last triplet

	-- A MBE_recoder has to be assgined at each triplet to generate the correspondent partial product, but not for the last triplet, which requires a simpler choice.
	-- Also a Sign_Ext is required for each triplet but not for the last one.
	MBE_0 : MBE_recoder port map(a			=> a_ext,
	                           a_2			=> a2,
	                           a_n			=> a_n,
	                           a_2_n		=> a2_n,
	                           b_triplet    => first_triplet,
	                           rec_out		=> pp(0)
	);
	
	S_gen_0 : Sign_Ext port map(
							   b_triplet	=> first_triplet,
							   S  		 	=> S_array(0)
	);
	pp_gen : for i in 2 to 16 generate
		MBE_i : MBE_recoder port map(a			=> a_ext,
								   a_2			=> a2,
								   a_n			=> a_n,
								   a_2_n		=> a2_n,
								   b_triplet    => b((2*i - 1) downto (2*i - 1 - 2)),
								   rec_out		=> pp(i - 1)
		);
		
		S_gen_0 : Sign_Ext port map(
								   b_triplet	=> b((2*i - 1) downto (2*i - 1 - 2)),
								   S  		 	=> S_array(i - 1)
		);
	end generate;	
	
	pp(16) <= '0' & a when last_triplet = "001" else
			  ( others => '0');

	-- Inputs to the MBE_recoder generation
	A_gen_i : A_gen port map(a		    => a,
						    a_out	    => a_ext,
						    a2_out	    => a2,
						    a_n_out	    => a_n,
						    a2_n_out    => a2_n
	);

	
	-- Dadda_Tree
	D_tree : Dadda_Tree port map( pp		=> pp,
	                              S		    => S_array,

	                              sum_out	=> sum_out,  
	                              carry_out => carry_out
	);

	m <= std_logic_vector(unsigned(sum_out) + unsigned(carry_out)); -- behavioural adder used to generate the final result

end beh;

