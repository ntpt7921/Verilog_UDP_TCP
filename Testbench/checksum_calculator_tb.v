module checksum_calculator_tb ();
  parameter LENGTH = 16;
  
  reg [LENGTH-1:0] in;
  reg reset, enable, clk;
  wire [LENGTH-1:0] checksum;
  
  
  //0x9801 +' 0x331b +' 0x980e +' 0x5e4b +' 0x0011 +' 
  //0x000a +' 0xa08f +' 0x2694 +' 0x000a +' 0x6262 = 0xeb21
  initial begin
    reset = 0;
    clk = 0;
    #1;
    reset = 1;
    #5;
    reset = 0;
    enable = 1;
    change_input('h9801);
    change_input('h331b);
    change_input('h980e);
    change_input('h5e4b);
    change_input('h0011);
    change_input('h000a);
    change_input('ha08f);
    change_input('h2694);
    change_input('h000a);
    change_input('h6262);
    #1;
    $finish;
  end
  
  task change_input;
    input [LENGTH-1:0] input_value;
    begin
      @(negedge clk);
      in = input_value;
    end
  endtask
  
  always
    #1 clk = ~clk;
  
  initial begin
    $display("  T\tin\treset\tclk\tchksum");
    $monitor("%3d\t%h\t%b\t%b\t%h", $time, in, reset, clk, checksum);
  end
  
  checksum_calculator #(.LENGTH(LENGTH)) dut 
  (.in(in), .reset(reset), .enable(enable), .clk(clk), .checksum(checksum));
  
endmodule
