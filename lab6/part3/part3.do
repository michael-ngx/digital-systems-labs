#part2 testing
vlib work

vlog part3.v

vsim part3

log {/*}
add wave {/*}

force {Clock} 0 0ns, 1 1ns -r 2ns
force {Resetn} 0 0ns, 1 4ns
force {Go} 0 0ns, 1 2ns, 0 12ns
force {Divisor} 4'd3 0ns
force {Dividend} 4'd7 0ns

run 200ns
