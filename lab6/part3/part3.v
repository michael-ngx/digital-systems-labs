// ********************* NOTE: This part is an optional assignment for bonus mark. This attempt is partially correct. *********************************

`timescale 1ns/1ns
module part3(Clock, Resetn, Go, Divisor, Dividend, Quotient, Remainder, ResultValid);
    input Clock, Resetn, Go;
    input [3:0] Divisor, Dividend;
    output [3:0] Quotient, Remainder;
    output ResultValid;
    
    wire ld_n;
    wire ld_r;
    wire ld_alu_out, ld_reset;

    control u0(
        .Clock(Clock),
        .Resetn(Resetn),
        .Go(Go),

        .ResultValid(ResultValid),
        .ld_n(ld_n),
        .ld_r(ld_r),
        .ld_alu_out(ld_alu_out),
        .ld_reset(ld_reset)
    );

    datapath u1(
        .Clock(Clock),
        .Resetn(Resetn),

        .Divisor(Divisor),
        .Dividend(Dividend),
        .Quotient(Quotient),
        .Remainder(Remainder),
        
        .ld_n(ld_n),
        .ld_r(ld_r),
        .ld_alu_out(ld_alu_out),
        .ld_reset(ld_reset)
    );

endmodule

module control(
    input Clock, Resetn, Go,
    output reg ResultValid,
    output reg ld_n, ld_r, ld_alu_out, ld_reset
);

    localparam
        LOAD_NUMBERS = 5'd0,
        LOAD_WAIT = 5'd1,
        CYCLE_0 = 5'd2,
        CYCLE_1 = 5'd3,
        CYCLE_2 = 5'd4,
        CYCLE_3 = 5'd5,
        CYCLE_4 = 5'd6,
        CYCLE_4_WAIT = 5'd7;
    
    reg [5:0] current_state, next_state;


    always@(*) 
    begin: state_table
        case(current_state) 
            LOAD_NUMBERS: next_state = Go ? LOAD_WAIT : LOAD_NUMBERS;
            LOAD_WAIT: next_state = Go ? LOAD_WAIT : CYCLE_0;
            CYCLE_0: next_state = CYCLE_1;
            CYCLE_1: next_state = CYCLE_2;
            CYCLE_2: next_state = CYCLE_3;
            CYCLE_3: next_state = LOAD_NUMBERS;
            default: next_state = LOAD_NUMBERS;
        endcase
    end

    always@(*) 
    begin: enable_signals
        ld_n = 1'b0;
        ld_alu_out = 1'b0;
        ld_r = 1'b0;
        ld_reset = 1'b0;
        case(current_state)
            LOAD_NUMBERS: begin
                ld_n = 1'b1;
            end
            LOAD_WAIT: begin
                ld_reset = 1'b1;
                ResultValid = 1'b0;
            end
            CYCLE_0: begin
                
                ld_alu_out = 1'b1;
                ld_n = 1'b1;
            end
            CYCLE_1: begin
                
                ld_alu_out = 1'b1;
                ld_n = 1'b1;
            end
            CYCLE_2: begin
                
                ld_alu_out = 1'b1;
                ld_n = 1'b1;
            end
            CYCLE_3: begin
                ld_r = 1'b1;
            end

        endcase
    end

    always@(posedge Clock) 
    begin: state_FFs
        if(!Resetn) begin
            current_state <= LOAD_NUMBERS;
            ResultValid <= 1'b0;
        end
        else begin
            current_state <= next_state;
            if(ld_r)
                ResultValid <= 1'b1;
        end
    end 


endmodule


module datapath(
    input Clock, Resetn, ld_n, ld_alu_out, ld_r, ld_reset,
    input [3:0] Divisor, Dividend,
    output reg [3:0] Quotient,
    output reg [3:0] Remainder,
    output reg ResultValid
);
    reg signed [4:0] regDivisor;
    reg signed [4:0] registerA;
    reg [3:0] regDividend;
    reg [4:0] alu_out_A;
    reg [3:0] alu_out_dividend;
    reg signed [4:0] alu_out_divisor;

    always@(posedge Clock) begin
        if(!Resetn) begin
            Quotient <= 4'b0;
            Remainder <= 4'b0;
            registerA <= 5'b0;
            regDividend <= 4'b0;
            regDivisor <= 5'b0;
        end
        else begin
            if(ld_n == 1) begin
                registerA <= ld_alu_out ? alu_out_A : 5'b00000;
                regDividend <= ld_alu_out ? alu_out_dividend : Dividend;
                regDivisor <= ld_alu_out ? alu_out_divisor : {1'b0, Divisor};
            end
            if(ld_r == 1) begin
                Quotient <= alu_out_dividend;
                Remainder <= alu_out_A[3:0];
            end
            if(ld_reset  == 1) begin
                Quotient <= 0;
                Remainder <= 0;
            end
            
        end

    end

    always@(*) begin
        alu_out_divisor = regDivisor;
        alu_out_A = registerA << 1;
        alu_out_A[0] = {regDividend[3]};
        alu_out_dividend = regDividend << 1;

        alu_out_A = alu_out_A - regDivisor;
        
        alu_out_dividend[0] = alu_out_A[4] == 1 ? 1'b0 : 1'b1;      
        alu_out_A = alu_out_A[4] == 1 ? alu_out_A + regDivisor : alu_out_A;
    end



endmodule