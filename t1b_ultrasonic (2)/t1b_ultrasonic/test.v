module test (
    input  wire        clk_50M,
    input  wire        reset,

    // Encoder inputs
    input  wire        ena1, enb1,   // left encoder A/B
    input  wire        ena2, enb2,   // right encoder A/B

    // Motor outputs
    output wire        motor_pwm1,
    output wire        motor_pwm2,
    output reg         IN1, IN2, IN3, IN4
);

    // =====================================================
    // Encoder counts
    // =====================================================
    wire signed [31:0] enc_left;
    wire signed [31:0] enc_right;

    wire [3:0] dt1;
    wire [3:0] dt2;

    reg reset_to_enc;

    quadrature_encoder encoder_left (
        .clk            (clk_50M),
        .a              (ena1),
        .b              (enb1),
        .position       (enc_left),
        .reset_from_exe (reset_to_enc)
    );

    quadrature_encoder encoder_right (
        .clk            (clk_50M),
        .a              (ena2),
        .b              (enb2),
        .position       (enc_right),
        .reset_from_exe (reset_to_enc)
    );

    t1a_fs_pwm_bdf pwm1 (
        .clk_50M    (clk_50M),
        .duty_cycle (dt1),
        .pwm_signal (motor_pwm1)
    );

    t1a_fs_pwm_bdf pwm2 (
        .clk_50M    (clk_50M),
        .duty_cycle (dt2),
        .pwm_signal (motor_pwm2)
    );

    // =====================================================
    // Parameters
    // =====================================================
    parameter signed [31:0] FORWARD_25CM_CNT = 800;

    // =====================================================
    // Counter
    // =====================================================
    reg [36:0] counter;

    always @(posedge clk_50M or negedge reset) begin
        if (!reset)
            counter <= 0;
        else if (counter >= 32'd101_000_000)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // =====================================================
    // FSM states
    // =====================================================
    localparam FORWARD = 2'd0;
    localparam TURN    = 2'd1;
    localparam STOP    = 2'd2;

    reg [1:0] curr_state;
    reg [1:0] next_state;

    // =====================================================
    // FSM state register
    // =====================================================
    always @(posedge clk_50M or negedge reset) begin
        if (!reset)
            curr_state <= FORWARD;
        else
            curr_state <= next_state;
    end

    // =====================================================
    // FSM next-state logic
    // =====================================================
    always @(*) begin
        next_state = curr_state;

        case (curr_state)
            STOP: begin
                if (counter >= 32'd100_000_000)
                    next_state = FORWARD;
            end

            FORWARD: begin
                if ((enc_left >= 32'sd5308) && (enc_right >= 32'sd5308))
                    next_state = TURN;
            end

            TURN: begin
                if ((enc_left >= 32'sd1667) && (enc_right <= -32'sd1667))
                    next_state = STOP;
            end
        endcase
    end

    // =====================================================
    // Output logic
    // =====================================================
    always @(*) begin
        reset_to_enc = 1'b0;
        {IN1, IN2, IN3, IN4} = 4'b1111;

        case (curr_state)

            STOP: begin
                reset_to_enc = 1'b0;
                {IN1, IN2, IN3, IN4} = 4'b1111;
            end

            FORWARD: begin
                if (next_state == TURN)
                    reset_to_enc = 1'b1;

                if ((enc_left <= 32'sd5308) && (enc_right <= 32'sd5308))
                    {IN1, IN2, IN3, IN4} = 4'b0110;
                else
                    {IN1, IN2, IN3, IN4} = 4'b1111;
            end

            TURN: begin
                if (next_state == STOP)
                    reset_to_enc = 1'b1;

                if ((enc_left <= 32'sd1667) && (enc_right >= -32'sd1667))
                    {IN1, IN2, IN3, IN4} = 4'b0101;
                else
                    {IN1, IN2, IN3, IN4} = 4'b1111;
            end
        endcase
    end

    // =====================================================
    // PWM duty
    // =====================================================
    assign dt1 = 4'd8;
    assign dt2 = 4'd8;

endmodule
