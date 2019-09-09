// This file is covered by the MIT License, see the LICENSE file for details

// Black box wrapper module

// The user (read: customer) would get this and libfoo.so, Verilator
//   will build the header file from this module

// NB: this is just an example, ideally this would be automatically
//   generated from foo_impl.sv

module foo (
    input [63:0] a,
    output logic [63:0] x,
    input [128:0] long_in,
    output logic [128:0] long_out,
    input clk
);

    import "DPI-C" function chandle create_foo (string scope);
`ifdef MODELSIM
    import "DPI-C" function chandle lookup_foo (string scope);
`endif
    import "DPI-C" function void comb_update_foo (
            chandle foo,
            bit [63:0] a,
            bit [128:0] long_in,
            output bit [128:0] long_out,
            output bit [63:0] x
    );
    import "DPI-C" function void seq_update_foo (
            chandle foo,
            bit clk,
            output bit [128:0] long_out,
            output bit [63:0] x
    );
    import "DPI-C" function void comb_ignore_foo (
            chandle foo,
            bit [63:0] a,
            bit [128:0] long_in
    );
    import "DPI-C" function void final_foo (chandle foo);

    chandle foo;
    string scope;

    initial begin
        scope = $sformatf("%m");
        foo = create_foo(scope);
    end

    time comb_time = 0;
    logic [63:0] x_comb;
    logic [128:0] long_out_comb;
    always @(a, long_in) begin
`ifdef MODELSIM
        automatic chandle ack = lookup_foo($sformatf("%m"));
`endif

	// TODO -- split off each input
        comb_update_foo(
`ifdef MODELSIM
    // TODO -- is this a ModelSim bug?  . . . file a ticket if so
                ack,
`else
                foo,
`endif
                a, long_in, long_out_comb, x_comb);
        comb_time = $time;
    end

    time seq_time = 0;
    logic [63:0] x_tmp;
    logic [63:0] x_seq;
    logic [128:0] long_out_tmp;
    logic [128:0] long_out_seq;
    time last_seq_time = 0;
    always @(edge(clk)) begin
	// NB -- one way to solve the problem:
	//$display("barrier ---> a=%0d", a);
	//$display("wrapper: (%0t) clk=%0d x_seq=%0d", $time, clk, x_seq);
`ifdef MODELSIM
        automatic chandle ack = lookup_foo($sformatf("%m"));
`endif

	// TODO -- does this represent a Verilator scheduler bug wrt DPI?
	// XSim also need this
	// NB -- this is another way to solve the problem:
	comb_ignore_foo(
`ifdef MODELSIM
                ack,
`else
                foo,
`endif
		a, long_in);

        seq_update_foo(
`ifdef MODELSIM
    // TODO -- is this a ModelSim bug?  . . . file a ticket if so
                ack,
`else
                foo,
`endif
                clk, long_out_tmp, x_tmp);
        x_seq <= x_tmp;
        long_out_seq <= long_out_tmp;
        seq_time <= $time;
    end

    // TODO -- perhaps get a seq num from the secret wrapper (secret's
    //           $time) instead, this would require Verilator
    //           runtime namespacing
    // TODO -- identify wholly combinatorial or sequential paths so
    //           we can avoid this mux if possible
    always @(*) begin
	//$display("wrapper: (%0t) c/s %0t/%0t", $time, comb_time, seq_time);
        if (seq_time > comb_time) begin
            x = x_seq;
            long_out = long_out_seq;
        end else begin
            x = x_comb;
            long_out = long_out_comb;
        end
    end

    final final_foo(foo);

endmodule

