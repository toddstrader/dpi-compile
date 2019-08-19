// This file is covered by the MIT License, see the LICENSE file for details

// Example testbench module

module foo_tb (
    input [63:0] a0, a1,
    output [63:0] x0, x1,
    input clk
);

    logic [1:0] [63:0] a, x;
    assign a[0] = a0;
    assign a[1] = a1;
    assign x0 = x[0];
    assign x1 = x[1];

    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin: gen_loop
            foo foo_inst (.a (a[i]), .x (x[i]), .clk (clk));
        end
    endgenerate

endmodule
