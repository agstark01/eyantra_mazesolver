module translator(
	input clk, reset,
	input [2:0] move,
	input [31:0]enc_a,
	input [31:0]enc_b,
	input [15:0] dis_stable1,dis_stable2,dis_stable3,
	output executed,
	output motor_pwm1,
	output motor_pwm2,
	output in1,in2,in3,in4,
)