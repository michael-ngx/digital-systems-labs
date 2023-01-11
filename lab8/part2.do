#part2
vlib work
vlog part2.v

vsim part2
#vsim -L altera_mf_ver part2

log {/*}
add wave {/*}

force iXY_Coord 7'b0000100 0ps, 7'b0000001 30ps
force iLoadX 0 0ps, 1 10ps, 0 16ps, 1 80ps, 0 85ps, 1 250ps, 0 255ps
force iPlotBox 0 0ps, 1 33ps, 0 40ps, 1 95ps, 0 100ps, 1 270ps, 0 290ps
force iBlack 0 0ps, 1 138ps, 0 150ps, 1 222ps, 0 230ps, 1 310ps, 0 340ps

force iClock 0 0ps, 1 1ps -r 2ps
force iResetn 0 0ps, 1 6ps
force iColour 3'b100

run 500ps

############################################################################
##control
#vlib work
#vlog part2.v
#
#vsim control
#
#log {/*}
#add wave {/*}
#
#force iLoadX 0 0ps, 1 10ps, 0 16ps, 1 85ps, 0 100ps
#force iPlotBox 0 0ps, 1 33ps, 0 40ps, 1 110ps, 0 130ps
#force iClock 0 0ps, 1 1ps -r 2ps
#force iResetn 0 0ps, 1 6ps, 0 80ps, 1 90ps
#
#force sum 4'b1001 0ps, 4'b1111 50ps -r 60ps
#
#run 300ps
#
###########################################################################
##datapath
#vlib work
#vlog part2.v
#
#vsim datapath
#
#log {/*}
#add wave {/*}
#
#force iClock 0 0ps, 1 1ps -r 2ps
#force iResetn 0 0ps, 1 6ps, 0 80ps, 1 90ps
#force iColour 3'b100
#force iXY_Coord 7'b0000100 0ps, 7'b0000001 30ps
#
#force ld_x 0 0ps, 1 10ps, 0 16ps, 1 85ps, 0 100ps
#force ld_y 0 0ps, 1 33ps, 0 40ps, 1 110ps, 0 130ps
#force oPlot 0 0ps, 1 44ps
#force draw 0 0ps, 1 44ps
#
#run 300ps
