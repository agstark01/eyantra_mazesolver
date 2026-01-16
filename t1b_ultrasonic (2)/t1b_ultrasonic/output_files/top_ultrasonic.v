module top_ultrasonic(
	 input clk_50M, reset, echo_rx1, echo_rx2, echo_rx3,
	 input en1A,en1B,en2A,en2B,
    output [2:0] move,
    output trig1,
	 output trig2,
	 output trig3,
    output mid,
	 output right,
	 output left,
    //output [1:0] curr,
    output wire [15:0] dis_stable1, 
	 output wire [15:0]dis_stable2,
	 output wire [15:0]dis_stable3,
	 output motor_pwm1,
	 output motor_pwm2,
	 output reg IN1,IN2,IN3,IN4
	 //output [3:0] posa,posb
);

    wire [15:0] distance_out1; 
	 wire [15:0]distance_out2;
	 wire [15:0]distance_out3;
	 
//	 wire [2:0] move;
	wire [31:0] positionA, positionB;

	
t1b_ultrasonic #(.MIN_DIST_MM(150)) sensor1 (
		.clk_50M(clk_50M),
		.echo_rx(echo_rx1),
		.reset(reset),
		.trig(trig1),
		.op(mid),
		.distance_out(distance_out1)
);

t1b_ultrasonic  #(.MIN_DIST_MM(100)) sensor2(
		.clk_50M(clk_50M),
		.echo_rx(echo_rx2),
		.reset(reset),
		.trig(trig2),
		.op(right),
		.distance_out(distance_out2)
);

t1b_ultrasonic #(.MIN_DIST_MM(100)) sensor3 (
		.clk_50M(clk_50M),
		.echo_rx(echo_rx3),
		.reset(reset),
		.trig(trig3),
		.op(left),
		.distance_out(distance_out3)
);


	moving_average m1(.clk_50M(clk_50M),.reset(reset),.dis_in(distance_out1), .dis_out(dis_stable1));
	moving_average m2(.clk_50M(clk_50M),.reset(reset),.dis_in(distance_out2), .dis_out(dis_stable2));
	moving_average m3(.clk_50M(clk_50M),.reset(reset),.dis_in(distance_out3), .dis_out(dis_stable3));
	
	
//	lk_50M,
//	duty_cycle,
//	pwm_signal,
//	clk_195KHz,
//	clk_3125KHz
//	
//	parameter expected = 70;
	reg [7:0] error_val1;
	//assign error_val1 = dis_stable2 - expected;
	
	reg [7:0] error_val2;
	//reg [26:0] count = 0;
	//assign error_val2 =  dis_stable3 - expected;
	
//	assign motor_pwm1 = 0;
//	assign motor_pwm2 = 0;
	
	always @(posedge clk_50M, negedge reset) begin
//	{IN1,IN2,IN3,IN4} = 4'b0110;
		if(!reset)begin
			error_val1 <= 0;
			error_val2 <= 0;
//			count <= 0;
		end else begin
//			if(dis_stable2 <= 100 && dis_stable3 <= 100) begin
//				if(dis_stable2 > dis_stable3)begin
//					error_val1 <= 10 + (2*(dis_stable2[7:4] - dis_stable3[7:4])/3);
//					error_val2 <= 10 - 2*((dis_stable2[7:4] - dis_stable3[7:4])/3) ;
//				end else if( dis_stable2 < dis_stable3) begin
//					error_val1 <= 10 - 2*((dis_stable3[7:4] - dis_stable2[7:4])/3);
//					error_val2 <= 10 + 2*((dis_stable3[7:4] - dis_stable2[7:4])/3);
//				end else begin
//					error_val1 <= 10 ;
//					error_val2 <= 10;
//				end
//			end else begin
//				if( dis_stable2 > dis_stable3)begin
//					error_val1 <= 9;
//					error_val2 <= 3;
//				end else begin
//					error_val1 <= 3;
//					error_val2 <= 9;
//				end
//			end
			
			case(move)
				3'b000: begin
						{IN1,IN2,IN3,IN4} = 4'b0000;
						error_val1 <= 0;
						error_val2 <= 0;
				end
				3'b001: begin
//					left <= (dis_stable3 >= 100);
//					mid <= (dis_stable1 >= 70);
//					left <= (dis_stable2 >= 100);
//					if(dis_stable2 <= 100 && dis_stable3 <= 100) begin
				if(dis_stable2 > dis_stable3)begin
					error_val1 <= 8 + (dis_stable2[7:4] - dis_stable3[7:4])/2;
					error_val2 <= 8 - (dis_stable2[7:4] - dis_stable3[7:4])/2 ;
				end else if( dis_stable2 < dis_stable3) begin
					error_val1 <= 8 - (dis_stable3[7:4] - dis_stable2[7:4])/2;
					error_val2 <= 8 + (dis_stable3[7:4] - dis_stable2[7:4])/2;
				end else begin
					error_val1 <= 8;
					error_val2 <= 8;
				end
				{IN1,IN2,IN3,IN4} = 4'b0110;
				end
//				end
				3'b010:begin
//					if(count <= 50_000_000_000)begin
//						count <= count + 1'b1;
//					end else begin
//						error_val1 <= 10;
//						error_val2 <= 3;
//						count <= 0;
//					end
					error_val1 <= 5;
					error_val2 <= 15;
					{IN1,IN2,IN3,IN4} = 4'b0110;
				end
				3'b011:begin
//					if(count <= 50_000_000_000)begin
//						count <= count + 1'b1;
//					end else begin
//						error_val1 <= 3;
//						error_val2 <= 10;
//						count <= 0;
//					end
					error_val1 <= 15;
					error_val2 <= 5;
					{IN1,IN2,IN3,IN4} = 4'b0110;
				end
				3'b100:begin
					error_val1 <= 10;
					error_val2 <= 10;
					{IN1,IN2,IN3,IN4} = 4'b1010;
				end
				default: begin
					error_val1 <= 0;
					error_val2 <= 0;
					{IN1,IN2,IN3,IN4} = 4'b1111;
				end
			endcase
			
		end	
	end
//	assign error_val1 = 3*dis_stable2[7:4];
//	assign error_val2 = 3*dis_stable3[7:4];
//	assign error_val1 = 0;
//	assign error_val2 = 0;
	
	
	t1a_fs_pwm_bdf pwm1(.clk_50M(clk_50M),.duty_cycle(error_val1),.pwm_signal(motor_pwm1));
	t1a_fs_pwm_bdf pwm2(.clk_50M(clk_50M),.duty_cycle(error_val2),.pwm_signal(motor_pwm2));
	
//	nput clk,
//    input rst_n,
//    input left, mid, right, // 0 - no wall, 1 - wall
//    output reg [2:0] move
	
	
	
	//assign {IN1,IN2,IN3,IN4} = 4'b0110;
	
	
//	input  wire        clk,
//    input  wire        reset,
//
//    input  wire        a,
//    input  wire        b,
//
//    output reg  signed [31:0] position,   // 4× decoded position
//    output reg  signed [31:0] velocity    // counts per VEL period
////);
	quadrature_encoder qe1(.clk(clk_50M),.reset(reset),.a(en1A),.b(en1B),.position(positionA));
	quadrature_encoder qe2(.clk(clk_50M),.reset(reset),.a(en2A),.b(en2B),.position(positionB));
	
	wire [31:0] dis_average;
	assign dis_average = (positionA + positionB)/2;
	t2c_maze_explorer mze(.clk(clk_50M),.rst_n(reset),.left(left),.right(right),.mid(mid),.move(move),.distance(dis_average));
//	assign posa = positionA[7:4];
//	assign posb = positionB[7:4];
	
	
endmodule