module checksum_calculator (in, reset, enable, clk, checksum);
  parameter LENGTH = 32;
  
  input [LENGTH-1:0] in;
  input reset, enable, clk;
  output [LENGTH-1:0] checksum;
  
  wire [LENGTH-1:0] in;
  wire reset, clk;
  reg [LENGTH-1:0] checksum;
  
  
  wire [LENGTH-1:0] next_checksum;
  one_complement_adder #(.LENGTH(LENGTH)) adder (.a1(checksum), .a2(in), .res(next_checksum));
  
  always @(posedge clk) begin
    if (reset) checksum <= 0;
    else if (enable) checksum <= next_checksum;
  end
  
endmodule
