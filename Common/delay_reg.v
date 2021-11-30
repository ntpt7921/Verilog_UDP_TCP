module delay_reg(data_in, in_pos, data_out, clk, reset);
  parameter DEPTH=1;
  parameter WIDTH=32;
  
  input [WIDTH-1:0] data_in;
  input [7:0] in_pos;
  input clk, reset;
  output [WIDTH-1:0] data_out;
  
  wire [WIDTH-1:0] data_in;
  wire [7:0] in_pos;
  wire clk, reset;
  wire [WIDTH-1:0] data_out;
  
  
  
  genvar i;
  if (DEPTH == 1) begin
    parallel_reg #(.WIDTH(WIDTH)) r
    (.data_in(data_in), .data_out(data_out), .clk(clk), .reset(reset));
  end else begin
    wire [DEPTH-1:0] decoder;
    assign decoder = 1 << (in_pos-1);
    
    wire [WIDTH-1:0] btw [0:DEPTH];
    wire [WIDTH-1:0] mux [0:DEPTH-1];
    for (i = 0; i < DEPTH; i = i + 1) begin
      assign mux[i] = (decoder[DEPTH-1-i]) ? btw[0] : btw[i];
      parallel_reg #(.WIDTH(WIDTH)) r
      (.data_in(mux[i]), .data_out(btw[i+1]), .clk(clk), .reset(reset));
    end
    
    assign btw[0] = data_in;
    assign data_out = btw[DEPTH];
  end
  
endmodule
