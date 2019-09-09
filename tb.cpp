// This file is covered by the MIT License, see the LICENSE file for details

// Example test

#include "Vfoo_tb.h"
#include <verilated_vcd_c.h>
vluint64_t main_time = false;
double sc_time_stamp() {
    return main_time;
}

void advance_time(Vfoo_tb* foo_tb, VerilatedVcdC* tfp) {
    foo_tb->clk = foo_tb->clk ? 0 : 1;
    foo_tb->eval();
    tfp->dump(main_time++);
}

int main() {
    Vfoo_tb foo_tb;

    VerilatedVcdC tfp;
    Verilated::traceEverOn(true);
    foo_tb.trace(&tfp, 99);
    tfp.open("foo.vcd");
    tfp.dump(main_time++);
    foo_tb.clk = 0;
    while (!Verilated::gotFinish()) {
        advance_time(&foo_tb, &tfp);
    }

    foo_tb.final();
    return 0;
}
