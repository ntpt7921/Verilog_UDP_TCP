module buffer_memory_auto_addr_tb ();
  reg [31:0] data_in;
  reg rd_en, wr_en, clk, reset;
  wire [31:0] data_out;
  wire data_av;

  
  initial begin
    clk = 0;
    
    reset_mem();
    write_mem('hAAAA_AAAA);
    write_mem('hBBBB_BBBB);
    read_write_mem('hCCCC_CCCC);
    read_write_mem('hDDDD_DDDD);
    read_mem();
    read_mem();
    read_mem();
    read_mem();
	
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
    input [31:0] data_in_value;
    
    begin
      @(negedge clk)
      wr_en = 1;
      data_in = data_in_value;
      @(negedge clk)
      wr_en = 0;
    end
  endtask
  
  task read_mem;
    begin
      @(negedge clk)
      rd_en = 1;
      @(negedge clk);
      rd_en = 0;
    end
  endtask
  
  task read_write_mem;
    input [31:0] data_in_value;
    
    begin
      @(negedge clk)
      rd_en = 1;
      wr_en = 1;
      data_in = data_in_value;
      @(negedge clk)
      wr_en = 0;
      rd_en = 0;
    end
  endtask
  
  always
    #1 clk = ~clk;
  
  initial begin
    $display("  T\tdin\t\trd_en\twr_en\tclk\treset\tdout\t\tdata_av\tcnt_in\tcnt_out");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data_in, rd_en, wr_en, clk, reset, 
             data_out, data_av, dut.count_in, dut.count_out);
  end
  
  
  buffer_memory_auto_addr dut 
  (.data_in(data_in), .rd_en(rd_en), .wr_en(wr_en), .clk(clk), 
   .reset(reset), .data_out(data_out), .data_av(data_av));
    
endmodule
