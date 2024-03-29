// This file is covered by the MIT License, see the LICENSE file for details

// Example testbench module

module foo_tb (
    input clk
);
    integer cyc = 0;

    always_ff @(posedge clk) begin
        cyc <= cyc + 1;
        if (cyc == 4) begin
            $write("done\n");
            $finish;
        end
    end

    localparam X = 2;

    genvar i;
    generate
        for (i = 0; i < X; i = i + 1) begin: gen_loop
            logic [63:0] a = 0;
            logic [63:0] x;
            logic [128:0] long_in, long_out;

            assign long_in = {1'b0, {2{a}}};

            foo foo_inst (.a, .x, .long_in, .long_out, .clk);

            always_ff @(posedge clk) begin
                $display("tb[%0d]: (%0t) cyc=%0d a=%0d x=%0d", i, $time, cyc, a, x);
                a <= a + 10;
                if (cyc == 0) a <= (64'(i)+1)*5;
            end
        end
    endgenerate

endmodule
