vlib work
vlog part1.v

vsim part1
vsim -L altera_mf_ver part1

log {/*}
add wave {/*}

force {Clock} 0 0ns, 1 5ns -r 10ns

force {WriteEn} 0 5ns, 1 10ns

force {DataIn} 4'b0000 1ns, 4'b0000 11ns, 4'b0001 31ns, 4'b0100 36ns -r 60ns

force {Address} 5'b0000 1ns, 5'b0000 11ns, 5'b0001 31ns, 5'b0100 36ns -r 60ns

run 300ns
