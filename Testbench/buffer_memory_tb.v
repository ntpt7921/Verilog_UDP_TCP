module buffer_memory_tb ();
  reg [13:0] addr_wr, addr_rd;
  reg [31:0] data_in;
  reg rd_en, wr_en, clk, reset;
  wire [31:0] data_out;
  
  initial begin
    clk = 0;
    reset_mem();
    write_mem(0, 'hABCD);
    write_mem(1, 'hEF01);
    write_mem(2, 'h2345);
    
    read_mem(0);
    read_mem(1);
    read_mem(2);
    
    read_write_mem(0, 'hAAAA_AAAA, 0);
    read_write_mem(1, 'hBBBB_BBBB, 2);
    
    $finish;
  end
  
  task reset_mem;
    begin
      @(negedge clk);
      reset = 1;
      @(negedge clk);
      reset = 0;
    end
  endtask
  
  task write_mem;
    input [13:0] addr_wr_value;
    input [31:0] data_in_value;
    
    begin
      @(negedge clk)
      wr_en = 1;
      addr_wr = addr_wr_value;
      data_in = data_in_value;
      @(negedge clk)
      wr_en = 0;
    end
  endtask
  
  task read_mem;
    input [13:0] addr_rd_value;
    
    begin
      @(negedge clk)
      rd_en = 1;
      addr_rd = addr_rd_value;
      @(negedge clk);
      rd_en = 0;
    end
  endtask
  
  task read_write_mem;
    input [13:0] addr_wr_value;
    input [31:0] data_in_value;
    input [13:0] addr_rd_value;
    
    begin
      @(negedge clk)
      rd_en = 1;
      wr_en = 1;
      addr_wr = addr_wr_value;
      data_in = data_in_value;
      addr_rd = addr_rd_value;
      @(negedge clk)
      wr_en = 0;
      rd_en = 0;
    end
  endtask
  
  always
    #1 clk = ~clk;
  
  initial begin
    $display("  T\taddrWr\tadddRd\tdin\t\trd_en\twr_en\tclk\treset\tdout");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h",
             $time, addr_wr, addr_rd, data_in, rd_en, wr_en, clk, reset, data_out);
  end
  
  buffer_memory dut 
  (.addr_wr(addr_wr), .addr_rd(addr_rd), .data_in(data_in),
                     .rd_en(rd_en), .wr_en(wr_en), .clk(clk), .reset(reset),
                     .data_out(data_out));
  
endmodule
