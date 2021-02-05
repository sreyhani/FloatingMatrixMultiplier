

// matrix_multiplier_tb.v
`timescale 1 ns/10 ps 

module matrix_multiplier_tb;

    reg [127:0] In1;
	reg	[127:0] In2;
	reg clk,rst,load,out_ack;
    wire [127:0] Out;
	wire out_ready;


    localparam period = 200;  

    matrix_multiplier #(.NUM_FIRST_ROW(2), .NUM_FIRST_COL(2), .NUM_SECOND_COL(2)) 
            UUT (.In1(In1), .In2(In2), .clk(clk), .rst(rst), .load(load), .out_ack(out_ack), .Out(Out), .out_ready(out_ready));


// note that sensitive list is omitted in always block
// therefore always-block run forever
// clock period = 2 ns
always 
begin
    clk = 1'b1; 
    #20; // high for 20 * timescale = 20 ns

    clk = 1'b0;
    #20; // low for 20 * timescale = 20 ns
end

initial // initial block executes only once
	begin
		// values for a and b
		In1 = 0;
		In2 = 0;
		rst = 0;
		load = 0;
		out_ack = 0;
		#period; // wait for period 
		rst = 1;
		
		In1[31:0] = 32'b00111111100000000000000000000000; // = 1
		In1[63:32] = 32'b01000000000000000000000000000000; // = 2
		In1[95:64] = 32'b01000000010000000000000000000000; // = 3
		In1[127:96] = 32'b01000000100000000000000000000000; // = 4
		
		In2[31:0] = 32'b00111111100000000000000000000000; // = 1
		In2[63:32] = 32'b01000000000000000000000000000000; // = 2
		In2[95:64] = 32'b01000000010000000000000000000000; // = 3
		In2[127:96] = 32'b01000000100000000000000000000000; // = 4
		
		#20;
		load = 1;
		#period;
		
		//if(Out[31:0] == 32'b01000000101000000000000000000000) begin // = 5
		//	$display("test ");
		//end
	end
	
endmodule
