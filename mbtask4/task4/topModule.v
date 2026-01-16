module topModule(
	 input  wire clk,
    input  wire reset,

    // Encoders
    input  wire enc_left_a,
    input  wire enc_left_b,
    input  wire enc_right_a,
    input  wire enc_right_b,

    // Ultrasonic
    input  wire echo_front,
    input  wire echo_left,
    input  wire echo_right,
    output wire trig_front,
    output wire trig_left,
    output wire trig_right,

    // Motor driver
    output wire left_pwm_out,
    output wire right_pwm_out,
    output wire left_dir,
    output wire right_dir
);

    // -----------------------------
    // INTERNAL wires (FREE)
    // -----------------------------
    wire [31:0] left_enc_count;
    wire [31:0] right_enc_count;

    wire [15:0] front_dist;
    wire [15:0] left_dist;
    wire [15:0] right_dist;

    wire [7:0] left_pwm;
    wire [7:0] right_pwm;

    wire [2:0] motion_cmd;

    // -----------------------------
    // Your existing modules
    // -----------------------------

    encoder encoder_left (
        .clk(clk),
        .a(enc_left_a),
        .b(enc_left_b),
        .count(left_enc_count)
    );

    encoder encoder_right (
        .clk(clk),
        .a(enc_right_a),
        .b(enc_right_b),
        .count(right_enc_count)
    );

    t1b_ultrasonic us_front (
        .clk_50M(clk),
        .echo_rx(echo_front),
        .trig(trig_front),
        .distance_out(front_dist)
    );

    t1b_ultrasonic us_left (
        .clk_50M(clk),
        .echo_rx(echo_left),
        .trig(trig_left),
        .distance_out(left_dist)
    );

    t1b_ultrasonic us_right (
        .clk_50M(clk),
        .echo_rx(echo_right),
        .trig(trig_right),
        .distance_out(right_dist)
    );

    t2c_maze_explorer maze (
        .clk(clk),
        .rst_n(reset),
        .mid(front_dist),
        .left(left_dist),
        .right(right_dist),
        .move(motion_cmd)
    );

    mbMotionController ctrl (
        .clk(clk),
        .reset(reset),
        .motion_cmd(motion_cmd),
        .front_dist(front_dist),
        .left_dist(left_dist),
        .right_dist(right_dist),
        .left_enc(left_enc_count),
        .right_enc(right_enc_count),
        .left_pwm(left_pwm),
        .right_pwm(right_pwm),
        .left_dir(left_dir),
        .right_dir(right_dir)
    );

    pwm_generator pwm_l (
        .clk(clk_195KHz),
        .duty_cycle(left_pwm),
        .pwm_signal(left_pwm_out)
    );

    pwm_generator pwm_r (
        .clk(clk_195KHz),
        .duty_cycle(right_pwm),
        .pwm_signal(right_pwm_out)
);
endmodule