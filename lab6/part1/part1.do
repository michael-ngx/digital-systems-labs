vlib work
vlog part1.v

vsim part1

log {/*}
add wave {/*}

force {Clock} 0 0ns, 1 5ns -r 10ns

force {Resetn} 0 5ns, 1 10ns

force {w} 0 1ns, 1 11ns, 0 31ns, 1 36ns -r 60ns

run 300ns
