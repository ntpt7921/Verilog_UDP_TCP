module parallel_reg (data_in, clk, reset, data_out);
  parameter WIDTH = 32;
  input [WIDTH-1:0] data_in;
  input clk, reset;
  output [WIDTH-1:0] data_out;
  
  wire [WIDTH-1:0] data_in;
  wire clk, reset;
  reg [WIDTH-1:0] data_out;

  always @(posedge clk) begin
    if (reset) data_out <= 0;
    else data_out <= data_in;
  end

endmodule
