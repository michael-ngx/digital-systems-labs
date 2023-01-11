// part2 (assign switches/LEDs)
module TOP(input [9:0]SW, output [9:0]LEDR);
    mux2to1 u0(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[9]),
        .m(LEDR[0])
        );
endmodule