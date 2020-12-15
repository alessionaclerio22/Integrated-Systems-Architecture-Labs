module tb_fpmul ();

   wire CLK_i;
   wire [31:0] DATA_i;
   wire [31:0] RES_i;

   clk_gen CG(.CLK(CLK_i));

   data_maker SM(.CLK(CLK_i),
		 .DATA(DATA_i));

    FPmul UUT(.CLK(CLK_i),
	     .FP_A(DATA_i),
		 .FP_B(DATA_i),
	     .FP_Z(RES_i));

endmodule

		   
