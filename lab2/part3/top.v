// part3 (assign switches/LEDs)
module hihi(HEX0, SW);
    input [3:0] SW;
    output [6:0] HEX0;

    hex_decoder u0(
        .c(SW),
        .display(HEX0)
        );
endmodule
