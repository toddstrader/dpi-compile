// This file is covered by the MIT License, see the LICENSE file for details

// Black box wrapper module

// The user (read: customer) would get this and libfoo.so, Verilator
//   will build the header file from this module

// NB: this is just an example, ideally this would be automatically
//   generated from foo_impl.sv

module foo (
    input [31:0] a,
    output logic [31:0] x,
    input clk
);

    import "DPI-C" function chandle create_foo (string scope);
    import "DPI-C" function void eval_foo (
            chandle foo, int a, bit clk, output int x);
    import "DPI-C" function void final_foo (chandle foo);

    chandle foo;
    string scope;

    initial begin
        scope = $sformatf("%m");
        foo = create_foo(scope);
    end

    always @(*) begin
        // TODO -- try to understand clocks and be smarter here
        eval_foo(foo, a, clk, x);
    end

    final final_foo(foo);

endmodule

