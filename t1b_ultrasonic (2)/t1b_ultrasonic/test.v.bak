module test (
    input  wire        clk_50M,
    input  wire        reset,

    // Encoder inputs
    input  wire        ena1, enb1,   // left encoder A/B
    input  wire        ena2, enb2,   // right encoder A/B

    // Motor outputs
    output wire       motor_pwm1,
    output wire        motor_pwm2,
    output wire        IN1, IN2, IN3, IN4
);

    // =====================================================
    // Encoder counts
    // =====================================================
    wire signed [31:0] enc_left;
    wire signed [31:0] enc_right;
	 wire [3:0]dt1;
	 wire [3:0]dt2;

    encoder encoder_left (
        .clk      (clk_50M),
        .a        (ena1),
        .b        (enb1),
        .position (enc_left)
    );

    encoder encoder_right (
        .clk      (clk_50M),
        .a        (ena2),
        .b        (enb2),
        .position (enc_right)
    );
	 t1a_fs_pwm_bdf pwm1(.clk_50M(clk_50M),.duty_cycle(dt1),.pwm_signal(motor_pwm1));
	 t1a_fs_pwm_bdf pwm2(.clk_50M(clk_50M),.duty_cycle(dt2),.pwm_signal(motor_pwm2));

    // =====================================================
    // Parameters (tune these)
    // =====================================================
    parameter signed [31:0] FORWARD_25CM_CNT = 800;
   // parameter signed [31:0] TURN_90_CNT      = 100;

    // =====================================================
    // FSM states
    // =====================================================
    localparam FORWARD = 2'd0;
    //localparam TURN    = 2'd1;
    localparam STOP    = 2'd2;

    reg [1:0] curr_state;
	 reg [1:0]next_state;

    // =====================================================
    // Encoder reference and delta
    // =====================================================
    reg  signed [31:0] enc_start;
    wire signed [31:0] enc_avg;
    wire signed [31:0] enc_delta;

   assign enc_avg   = (enc_left + enc_right) >>> 1;
   assign enc_delta = enc_avg - enc_start;

    // =====================================================
    // FSM
    // =====================================================
	 always @(posedge clk_50M or negedge reset) begin
		if(!reset)begin
			curr_state <= FORWARD;
			enc_start <= enc_avg;
		end

		else
			curr_state <= next_state;
	 end
    always @(posedge clk_50M or negedge reset) begin
			if(reset)begin
				if(enc_delta >= FORWARD_25CM_CNT)
					next_state <= STOP;
				//else if(enc_avg )		  end
	 end
//            state     <= FORWARD;
//            enc_start <= enc_avg;
//        end else begin
//            case (state)
//
//                FORWARD: begin
//                    if (enc_delta >= FORWARD_25CM_CNT) begin
//                        state     <= TURN;
//                        enc_start <= enc_avg;   // reset reference
//                    end
//                end
//
//                TURN: begin
//                    if (enc_delta >= TURN_90_CNT) begin
//                        state     <= STOP;
//                        enc_start <= enc_avg;
//                    end
//                end
//
//                STOP: begin
//                    state <= STOP;
//                end
//
//                default: begin
//                    state     <= FORWARD;
//                    enc_start <= enc_avg;
//                end
//            endcase
//        end
//    end
//
//    // =====================================================
//    // Motor PWM (always ON unless STOP)
//    // =====================================================
    assign dt1 = 4'd8;
    assign dt2 = 4'd8;
//
//    // =====================================================
//    // Motor direction
//    // =====================================================
//    // FORWARD: both motors forward
//    // TURN   : left forward, right reverse
//    // STOP   : brake
//
    assign {IN1, IN2, IN3, IN4} =
        (curr_state == FORWARD) ? 4'b1010 : 4'b1111;
       //(curr_state == STOP)    ? 4'b1111 ;
//                             4'b1111;

endmodule
