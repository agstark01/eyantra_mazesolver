module mbMotionController (
    input  wire        clk,
    input  wire        reset,

    // Maze solver command
    input  wire [2:0]  motion_cmd,

    // Sensors
    input  wire [15:0] front_dist,
    input  wire [15:0] left_dist,
    input  wire [15:0] right_dist,

    input  wire signed [7:0] left_enc,
    input  wire signed [7:0] right_enc,

    // Motor commands (NARROW!)
    output reg  [7:0]  left_pwm,
    output reg  [7:0]  right_pwm,
    output reg         left_dir,
    output reg         right_dir
);

    // -----------------------------
    // Parameters (tune later)
    // -----------------------------
    localparam STOP       = 3'd0;
    localparam FORWARD    = 3'd1;
    localparam TURN_LEFT  = 3'd2;
    localparam TURN_RIGHT = 3'd3;
    localparam U_TURN     = 3'd4;

    localparam BASE_SPEED      = 8'd110;
    localparam FRONT_STOP_DIST = 16'd15;

    localparam KP_ENC  = 3;
    localparam KD_ENC  = 1;
    localparam KP_WALL = 1;

    // -----------------------------
    // INTERNAL signals (WIDE = OK)
    // -----------------------------
    reg signed [7:0] enc_error;
    reg signed [7:0] enc_error_d;
    reg signed [7:0] enc_error_prev;

    reg signed [7:0] wall_error;

    reg signed [7:0] correction;
    reg signed [7:0] left_speed;
    reg signed [7:0] right_speed;

    // -----------------------------
    // Control loop
    // -----------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            left_pwm        <= 8'd0;
            right_pwm       <= 8'd0;
            left_dir        <= 1'b1;
            right_dir       <= 1'b1;
            enc_error_prev  <= 8'd0;
        end else begin

            // defaults
            left_dir  <= 1'b1;
            right_dir <= 1'b1;

            case (motion_cmd)

                STOP: begin
                    left_pwm  <= 8'd0;
                    right_pwm <= 8'd0;
                end

                FORWARD: begin
                    if (front_dist < FRONT_STOP_DIST) begin
                        left_pwm  <= 8'd0;
                        right_pwm <= 8'd0;
                    end else begin
                        // Encoder straight correction
                        enc_error   <= left_enc - right_enc;
                        enc_error_d <= enc_error - enc_error_prev;

                        // Wall centering (light influence)
                        wall_error <= left_dist - right_dist;

                        correction <= (KP_ENC  * enc_error)
                                    + (KD_ENC  * enc_error_d)
                                    + (KP_WALL * wall_error);

                        left_speed  <= BASE_SPEED - correction;
                        right_speed <= BASE_SPEED + correction;

                        // Saturation to PWM range
                        left_pwm <= (left_speed < 0)     ? 8'd0 :
                                    (left_speed > 255)   ? 8'd255 :
                                    left_speed[7:0];

                        right_pwm <= (right_speed < 0)   ? 8'd0 :
                                     (right_speed > 255) ? 8'd255 :
                                     right_speed[7:0];

                        enc_error_prev <= enc_error;
                    end
                end

                TURN_LEFT: begin
                    left_dir  <= 1'b0;
                    right_dir <= 1'b1;
                    left_pwm  <= 8'd100;
                    right_pwm <= 8'd100;
                end

                TURN_RIGHT: begin
                    left_dir  <= 1'b1;
                    right_dir <= 1'b0;
                    left_pwm  <= 8'd100;
                    right_pwm <= 8'd100;
                end

                U_TURN: begin
                    left_dir  <= 1'b0;
                    right_dir <= 1'b1;
                    left_pwm  <= 8'd120;
                    right_pwm <= 8'd120;
                end

                default: begin
                    left_pwm  <= 8'd0;
                    right_pwm <= 8'd0;
                end
            endcase
        end
    end
endmodule
