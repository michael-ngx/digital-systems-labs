vlib work

vlog part2.v

vsim TOP

log {/*}
add wave {/*}

force {SW[8]} 0 0ns, 1 {20ns} -r 40ns

force {SW[7]} 0 0ns, 1 {20ns} -r 20ns
force {SW[6]} 0 0ns, 1 {10ns} -r 20ns
force {SW[5]} 0 0ns, 1 {5ns} -r 20ns
force {SW[4]} 0 0ns, 1 {10ns} -r 20ns

force {SW[3]} 0 0ns, 1 {5ns} -r 20ns
force {SW[2]} 0 0ns, 1 {10ns} -r 20ns
force {SW[1]} 0 0ns, 1 {5ns} -r 20ns
force {SW[0]} 0 0ns, 1 {10ns} -r 20ns

run 200ns