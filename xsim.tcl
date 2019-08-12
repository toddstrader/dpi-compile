add_wave *
add_force {/foo_tb/a0} -radix hex {5 0ns}
add_force {/foo_tb/a1} -radix hex {7 0ns}
add_force {/foo_tb/clk} -radix hex {0 0ns} {1 50000ps} -repeat_every 100000ps
run 400 ns
quit
