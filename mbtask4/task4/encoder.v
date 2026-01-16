module encoder (
    input  wire        clk,
    input  wire        reset,

    input  wire        a,     // encoder channel A
    input  wire        b,     // encoder channel B

    output reg signed [31:0] count
);

    // ----------------------------------
    // Synchronize encoder inputs
    // ----------------------------------
    reg a_sync1, a_sync2;
    reg b_sync1, b_sync2;

    always @(posedge clk) begin
        a_sync1 <= a;
        a_sync2 <= a_sync1;
        b_sync1 <= b;
        b_sync2 <= b_sync1;
    end

    // ----------------------------------
    // Previous state storage
    // ----------------------------------
    reg a_prev;

    // ----------------------------------
    // Quadrature decode
    // ----------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count  <= 32'sd0;
            a_prev <= 1'b0;
        end else begin
            a_prev <= a_sync2;

            // Count on rising edge of A
            if (a_sync2 && !a_prev) begin
                if (b_sync2)
                    count <= count - 1;  // reverse
                else
                    count <= count + 1;  // forward
            end
        end
    end

endmodule
