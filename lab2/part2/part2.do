vlib work

vlog part2.v

vsim part2

log {/*}
add wave {/*}

force {SW[0]} 0
force {SW[1]} 0
force {SW[9]} 0
run 10ns

force {SW[0]} 0
force {SW[1]} 0
force {SW[9]} 1
run 10ns

force {SW[0]} 0
force {SW[1]} 1
force {SW[9]} 0
run 10ns

force {SW[0]} 0
force {SW[1]} 1
force {SW[9]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 0
force {SW[9]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 0
force {SW[9]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {SW[9]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
force {SW[9]} 1
run 10ns