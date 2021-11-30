module buffer_memory (addr_wr, addr_rd, data_in, rd_en, wr_en, clk, reset, data_out);
  input [13:0] addr_wr, addr_rd;
  input [31:0] data_in;
  input rd_en, wr_en, clk, reset;
  output [31:0] data_out;
  
  wire [13:0] addr_wr, addr_rd;
  wire [31:0] data_in;
  wire rd_en, wr_en, clk, reset;
  reg [31:0] data_out;
  
  reg [31:0] mem [0:13];
  
  integer i;
  always @(posedge clk) begin
    if (reset)
      for (i = 0; i < 16383; i = i + 1)
        mem[i] <= 0;
    else begin
      if (rd_en)
        data_out <= mem[addr_rd];
      if (wr_en)
        mem[addr_wr] <= data_in;
    end
  end
  
endmodule
