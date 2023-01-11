vlib work

vlog part2.v

vsim ALUreg

log {/*}
add wave {/*}

#Reset
force {SW[9]} 0 0ns, 1 {40ns} -r 50ns

#Data
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0

#Function
force {KEY[3]} 0 10ns
force {KEY[2]} 0 10ns
force {KEY[1]} 1 10ns

#Clock
force {KEY[0]} 0 0ns, 1 {10ns} -r 20ns

run 200ns