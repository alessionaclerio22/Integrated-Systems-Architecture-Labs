module tb_fir ();

   wire CLK_i;
   wire RST_n_i;
   wire [8:0] DIN_i;
   wire VIN_i;
   wire [8:0] A1_i;
   wire [8:0] A2_i;
   wire [8:0] B0_i;
   wire [8:0] B1_i;
   wire [8:0] B2_i;
   wire [8:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .A1(A1_i),
		 .A2(A2_i),
		 .B0(B0_i),
		 .B1(B1_i),
		 .B2(B2_i),
		 .END_SIM(END_SIM_i));

    IIR_Filter UUT(.CLK(CLK_i),
	     .RST_n(RST_n_i),
	     .DIN(DIN_i),
             .VIN(VIN_i),
		 .A1(A1_i),
		 .A2(A2_i),
		 .B0(B0_i),
		 .B1(B1_i),
		 .B2(B2_i),
             .DOUT(DOUT_i),
             .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

endmodule

		   
