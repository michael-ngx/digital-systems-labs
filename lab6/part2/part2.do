#part2 testing
vlib work

vlog part2.v

vsim part2

log {/*}
add wave {/*}

force {Clock} 0 1ns, 1 2ns -r 2ns
force {Resetn} 0 0ns, 1 4ns
force {Go} 0 0ns, 1 10ns, 0 30ns, 1 32ns, 0 52ns, 1 54ns, 0 74ns, 1 76ns, 0 96ns, 1 120ns, 0 140ns, 1 142ns, 0 162ns, 1 164ns, 0 184ns, 1 186ns, 0 206ns
force {DataIn} 0 0ns, 8'd1 9ns, 8'd2 31ns, 8'd3 53ns, 8'd4 75ns, 8'd100 120ns, 8'd6 142ns, 8'd3 161ns, 8'd2 185ns

run 300ns
