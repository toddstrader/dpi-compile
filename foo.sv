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
    import "DPI-C" function void eval_foo (
            chandle foo,
            bit [63:0] a,
            bit clk,
            bit [128:0] long_in,
            output bit [128:0] long_out,
            output bit [63:0] x
    );
    import "DPI-C" function void final_foo (chandle foo);

    chandle foo;
    string scope;

    initial begin
        scope = $sformatf("%m");
        foo = create_foo(scope);
    end

    always @(*) begin
        // TODO -- try to understand clocks and be smarter here
        eval_foo(foo, a, clk, long_in, long_out, x);
    end

    final final_foo(foo);

endmodule

