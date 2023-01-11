vlib work

vlog part1.v

vsim eightbitcounter

log {/*}
add wave {/*}

#Clock
force {KEY[0]} 0 0ns, 1 {5ns} -r 10ns

#Enable
force {SW[1]} 1
#Clear_b
force {SW[0]} 0 0ns, 1 {10ns} -r 60ns

run 200ns