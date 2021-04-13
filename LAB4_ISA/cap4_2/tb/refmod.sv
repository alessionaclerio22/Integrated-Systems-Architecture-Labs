class refmod extends uvm_component;
    `uvm_component_utils(refmod)
    
    packet_in tr_in;
    packet_out tr_out;
    uvm_get_port #(packet_in) in;
    uvm_put_port #(packet_out) out;

	shortreal A_sr;
	shortreal B_sr;
	shortreal OUT_sr;
    
    function new(string name = "refmod", uvm_component parent);
        super.new(name, parent);
        in = new("in", this);
        out = new("out", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr_out = packet_out::type_id::create("tr_out", this);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            in.get(tr_in);
			A_sr = $bitstoshortreal(tr_in.A);
			B_sr = $bitstoshortreal(tr_in.B);

            OUT_sr = A_sr * B_sr;

			tr_out.data = $shortrealtobits(OUT_sr);
			
            $display("refmod: input A = %b, input B = %b", tr_in.A, tr_in.B);
			$display("refmod: input A = %f, input B = %f", A_sr, B_sr);
            $display("refmod: output OUT = %b, out_sr : %f",tr_out.data, OUT_sr);

			out.put(tr_out);
        end
    endtask: run_phase
endclass: refmod
