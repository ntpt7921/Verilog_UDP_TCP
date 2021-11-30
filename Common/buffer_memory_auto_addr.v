module buffer_memory_auto_addr (data_in, rd_en, wr_en, clk, reset, data_out, data_av);
  input [31:0] data_in;
  input rd_en, wr_en, clk, reset;
  output [31:0] data_out;
  output data_av;
  
  wire [31:0] data_in;
  wire rd_en, wr_en, clk, reset;
  reg [31:0] data_out;
  wire data_av;
  
  reg [13:0] count_in, count_out;
  buffer_memory mem (.addr_wr(count_in), .addr_rd(count_out), .data_in(data_in), 
                     .rd_en(rd_en), .wr_en(wr_en), .clk(clk), .reset(reset), .data_out(data_out));
  
  assign data_av = count_in > count_out;

  always @(posedge clk) begin
    if (reset) begin
      count_in <= 0;
      count_out <= 0;
    end
    else begin
      if (rd_en && data_av) 
        count_out <= count_out + 1;
      if (wr_en)
        count_in <= count_in + 1;
    end
  end
  
endmodule
