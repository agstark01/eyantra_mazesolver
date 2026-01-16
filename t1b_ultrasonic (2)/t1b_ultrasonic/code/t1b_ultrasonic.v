/*
Module HC_SR04 Ultrasonic Sensor

This module will detect objects present in front of the range, and give the distance in mm.

Input:  clk_50M - 50 MHz clock
        reset   - reset input signal (Use negative reset)
        echo_rx - receive echo from the sensor

Output: trig    - trigger sensor for the sensor
        op     -  output signal to indicate object is present.
        distance_out - distance in mm, if object is present.
*/

// module Declaration
module t1b_ultrasonic #(
	parameter MIN_DIST_MM = 70,
	parameter SCALE_DIV   = 294 
	)

(
    input clk_50M, reset, echo_rx,
    output reg trig,
    output op,
    output [1:0] curr,
    output wire [15:0] distance_out
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

//==================== Internal Registers ====================//

// FSM state
reg [1:0] curr_st = 2'b00;
reg [1:0] next_st = 2'b00;

// Trigger pulse counter (for 10 us pulse)
//reg [9:0] trig_count = 0;

// Wait/cooldown counter (~12 ms)
//reg [22:0] wait_count = 0;

// Echo pulse measurement counter
reg [31:0] echo_count = 0;
reg [31:0] echo_latched = 0;
reg [31:0] count = 32'd0;
// Distance storage
reg [15:0] distance_reg = 0;

// Object present flag register
reg object_reg = 0;


reg measuring = 0; // tracks if echo measurement has started

// Echo synchronizer registers
reg echo_sync1 = 0, echo_sync2 = 0;

// Output assignments (ports unchanged)
assign op = object_reg;
assign curr = curr_st;
assign distance_out = distance_reg;

//==================== FSM States ====================//
parameter rst    = 2'b00,
          trigg  = 2'b01,
          countt = 2'b10,
          wt     = 2'b11;

//parameter MIN_DIST_MM = 70; // detection threshold
//parameter SCALE_DIV   = 294; // converts echo cycles to mm

//==================== Synchronize Echo Input ====================//
always @(posedge clk_50M or negedge reset) begin
    if(!reset) begin
        echo_sync1 <= 0;
        echo_sync2 <= 0;
    end else begin
        echo_sync1 <= echo_rx;
        echo_sync2 <= echo_sync1;
    end
end

//==================== FSM Sequential Logic ====================//
always @(posedge clk_50M or negedge reset) begin
    if(!reset)
        curr_st <= rst;
    else
        curr_st <= next_st;
end

//==================== FSM Next State Logic ====================//
always @(*) begin
    next_st = rst;
    case(curr_st)

    rst: begin
        if(count > 50) // small initial delay after reset
            next_st = trigg;
        else
            next_st = rst;
    end

    trigg: begin
        if(count >= 500) // 10 us completed
            next_st = countt;
        else
            next_st = trigg;
    end

    countt: begin
        if(echo_sync2)
            next_st = countt;
        else if(measuring == 1'b0 && echo_latched != 0)
            next_st = wt;
        else
            next_st = countt;
    end

    wt: begin
        if(count >= 600000) // cooldown over
            next_st = rst;
        else
            next_st = wt;
    end

    default: next_st = rst;

    endcase
end

//==================== Trigger, Wait, and Echo Measurement ====================//


always @(posedge clk_50M or negedge reset) begin
    if(!reset) begin
        trig <= 0;
        //trig_count <= 0;
        //wait_count <= 0;
        //echo_count <= 0;
        echo_latched <= 0;
        distance_reg <= 0;
        object_reg <= 0;
        measuring <= 0;
    end
    else begin

        // Wait counter runs only in rst and wt
        if(curr_st != next_st)
            count <= 0;
        else
            count <= count + 1;

        // Generate exact 10 us trigger pulse using registered counter
        if(curr_st == trigg) begin
            if(count < 500) begin
                trig <= 1;
                //trig_count <= trig_count + 1;
            end else begin
                trig <= 0;
            end
			end
       // end else begin
           // trig <= 0;
           // trig_count <= 0;
        //end

        // Echo pulse measurement
        if(curr_st == countt) begin
				trig <= 0;
            if(!measuring && echo_sync2) begin
                measuring <= 1;
                echo_count <= 0;
            end

            if(measuring && echo_sync2)
                echo_count <= echo_count + 1;

            if(measuring && !echo_sync2) begin
                measuring <= 0;
                echo_latched <= echo_count;
            end
        end else begin
            measuring <= 0;
            echo_count <= 0;
        end

        // Convert to mm once echo ends and FSM moves to WAIT
        if(curr_st == countt && next_st == wt) begin
            distance_reg <= echo_latched / SCALE_DIV;
				echo_latched <= 0;
				trig <= 0;
            // Object detection logic
            if(distance_reg < MIN_DIST_MM)
                object_reg <= 1;
            else
                object_reg <= 0;
        end

    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
