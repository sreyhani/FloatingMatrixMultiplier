`timescale 1ns / 1ps



module test();

    reg [127:0] In1;
	reg	[127:0] In2;
	reg clk,rst,load,out_ack;
    wire [127:0] Out;
	wire out_ready;


    localparam period = 200;
    localparam clock_period = 50;  

    matrix_multiplier #(.NUM_FIRST_ROW(2), .NUM_FIRST_COL(2), .NUM_SECOND_COL(2)) 
            UUT (.In1(In1), .In2(In2), .clk(clk), .rst(rst), .load(load), .out_ack(out_ack), .Out(Out), .out_ready(out_ready));


initial 
begin
    clk = 1;
    forever #(clock_period/2) clk = ~ clk;
end


initial // initial block executes only once
	begin
	   rst = 0;
		// values for In1 and In2
		In1 = 0;
		In2 = 0;
		rst = 0;
		load = 0;
		out_ack = 0;
		#period; // wait for period 
		rst = 1;
		
		//   |1 2|
		//   |3 4|
		In1[127:96] = 32'b00111111100000000000000000000000; // = 1
		In1[95:64] = 32'b01000000000000000000000000000000; // = 2
		In1[63:32] = 32'b01000000010000000000000000000000; // = 3
		In1[31:0] = 32'b01000000100000000000000000000000; // = 4
		
		//   |1 3|
		//   |2 4|
		In2[127:96] = 32'b00111111100000000000000000000000; // = 1
		In2[95:64] = 32'b01000000000000000000000000000000; // = 2
		In2[63:32] = 32'b01000000010000000000000000000000; // = 3
		In2[31:0] = 32'b01000000100000000000000000000000; // = 4
		
		#(clock_period/2);
		load = 1;
		#(100*clock_period);
		
		$display("out 1 = %b",Out[127:96]);
		if(Out[127:96] == 32'b01000000101000000000000000000000) begin // = 5
			$display("test 1");
		end
		$display("out 2 = %b",Out[95:64]);
		if(Out[95:64] == 32'b01000001001100000000000000000000) begin // = 11
			$display("test 2");
		end
		$display("out 3 = %b",Out[63:32]);	
		if(Out[63:32] == 32'b01000001001100000000000000000000) begin // = 11
			$display("test 3");
		end
		$display("out 4 = %b",Out[31:0]);
		if(Out[31:0] == 32'b01000001110010000000000000000000) begin // = 25
			$display("test 4");
		end
		
		$finish;
	end
	
endmodule


