module parallel_reg_tb ();
  parameter WIDTH = 32;
  reg [WIDTH-1:0] data_in;
  reg clk, reset;
  wire [WIDTH-1:0] data_out;

  initial begin
    clk = 0;
    reset = 1;
    @(negedge clk)
    reset = 0;
    data_in = 1;
    @(negedge clk)
    data_in = 2;
    @(negedge clk)
    data_in = 3;
    @(negedge clk)
    data_in = 4;
    #6;
    $finish;
  end

  
  always
    #1 clk = ~clk;
  
  initial begin
    $display("  T\tdin\t\tclk\trst\tdout");
    $monitor("%3d\t%h\t%h\t%h\t%h", $time, data_in, clk, reset, data_out);
    //$dumpvars(0, delay_reg_tb);
  end
  
  parallel_reg #(.WIDTH(WIDTH)) dut 
  (.data_in(data_in), .data_out(data_out), .clk(clk), .reset(reset));

endmodule
