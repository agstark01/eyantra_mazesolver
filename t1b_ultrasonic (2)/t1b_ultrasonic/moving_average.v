module moving_average(
	input clk_50M,
	input reset,
	input [15:0]dis_in, 
	output [15:0]dis_out
);

reg [15:0] mv1, mv2,mv3;

always @(posedge clk_50M, negedge reset)begin
	if(!reset) begin
		mv1 <= 0;
		mv2 <= 0;
		mv3 <= 0;
	end else begin
		mv1 <= dis_in;
		mv2 <= mv1;
		mv3 <= mv2;
	end
end

assign dis_out = (dis_in + mv1+mv2+mv3)/4;
endmodule