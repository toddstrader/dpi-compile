// This file is covered by the MIT License, see the LICENSE file for details

// Super top-secret code

module foo_impl (
    input [63:0] a,
    output [63:0] x,
    input [128:0] long_in,
    output [128:0] long_out,
    input clk
);

    logic [63:0] accum_q = 0;
    wire [63:0] next_accum = accum_q + a + 1'b1;

    always_ff @(posedge(clk)) begin
        //accum_q <= next_accum;
        //$display("%m: next_accum = %0d", next_accum);
        //$display("secret: clk=%0d a=%0d x=%0d", clk, a, x);
        accum_q <= accum_q + a + 1'b1;
    end

    assign x = accum_q;
    assign long_out = ~long_in;

    initial $display("Starting up: %m");
    final $display("All done: %m");

endmodule
