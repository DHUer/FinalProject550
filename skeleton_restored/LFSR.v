module LFSR(
    output [12:0] out,  // output of the counter
    input  en,   // enable for counter
    input  clk
    );

    //------------Internal Variables--------
    reg  [12:0] register;
    wire linear_feedback;

    initial begin
        register = {1'b1, 12'hCAB};
    end

    //-------------Code Starts Here-------
    assign linear_feedback = 
        ((register[12] ^ register[3]) ^ register[2]) ^ register[0];

    always @(posedge clk)
        if (en) begin
            register <= { register[11],
                        register[10], register[9],
                        register[8],  register[7],
                        register[6],  register[5],
                        register[4],  register[3],
                        register[2],  register[1],
                        register[0],  linear_feedback};
    end

    assign out = register;

endmodule
