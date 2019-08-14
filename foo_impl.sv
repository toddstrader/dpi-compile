// This file is covered by the MIT License, see the LICENSE file for details

// Super top-secret code

module foo_impl (
    input [31:0] a,
    output [31:0] x,
    input clk
);

    logic [31:0] accum_q = 0;
    wire [31:0] next_accum = accum_q + a + 1'b1;

    always_ff @(posedge(clk)) begin
        accum_q <= next_accum;
        $display("%m: next_accum = %0d", next_accum);
    end

    assign x = accum_q;

    initial $display("Starting up: %m");
    final $display("All done: %m");

endmodule
