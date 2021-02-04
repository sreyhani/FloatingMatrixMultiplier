`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2021 12:34:20 PM
// Design Name: 
// Module Name: mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux
#(
parameter WIDTH = 32, 
parameter NUM_INPUTS  = 2
)
(
In,select,Out
);
localparam IN_LENGTH = NUM_INPUTS * WIDTH;
localparam SELECT_LENGTH = $clog2( NUM_INPUTS );
input [IN_LENGTH-1 : 0 ] In;
input [SELECT_LENGTH - 1 : 0 ] select;
output [WIDTH -1 : 0 ] Out;

assign Out = In >> ( NUM_INPUTS-select) * WIDTH;
endmodule
