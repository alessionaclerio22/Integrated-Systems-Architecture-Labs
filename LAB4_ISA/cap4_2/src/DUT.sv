module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [3:0] {INITIAL,WAIT_1,WAIT_2,WAIT_3,WAIT_4,WAIT_5,SEND} state);
    
    FPmul FPmul_under_test(.clk(in_inter.clk),.FP_A(in_inter.A),.FP_B(in_inter.B),.FP_Z(out_inter.data));
    
	shortreal A_sr;
	shortreal B_sr;
	shortreal OUT_sr;

    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT_1;
                end
                
                WAIT_1: begin
                    if(in_inter.valid) begin
						A_sr = $bitstoshortreal(in_inter.A);
						B_sr = $bitstoshortreal(in_inter.B);

                        $display("fpmul: input A = %b, input B = %b", in_inter.A, in_inter.B);
                        $display("fpmul: input A = %f, input B = %f", A_sr, B_sr);
                        in_inter.ready <= 0;
                        out_inter.valid <= 0;
                        state <= WAIT_2;
                    end
                end
                
                WAIT_2: begin
                    state <= WAIT_3;
                end
                
                WAIT_3: begin
                    state <= WAIT_4;
                end

				WAIT_4: begin
                    state <= WAIT_5;
                end
                
                WAIT_5: begin
                    out_inter.valid <= 1;
					OUT_sr = $bitstoshortreal(out_inter.data);
                    $display("fpmul: output OUT = %b, OUT_f = %f", out_inter.data, OUT_sr);
                    state <= SEND;
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        in_inter.ready <= 1;
                        out_inter.valid <= 0;
                        state <= WAIT_1;
                    end
                end
        endcase
    end
endmodule: DUT
