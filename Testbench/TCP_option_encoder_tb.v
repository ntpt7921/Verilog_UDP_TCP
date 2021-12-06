module TCP_option_encoder_tb ();
  reg enable, clk, reset;
  reg [8:0] option_av;
    reg [15:0] mss; // option 2
    reg [7:0] scale_wnd; // option 3
    reg [2:0] sack_nbr; // option 5
      reg [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    reg [63:0] time_stp; // option 8
  
  wire [31:0] data_option; // used by *Option output
  
  
  initial begin
    clk = 0;
    reset = 1;
    @(negedge clk);
    reset = 0;
    enable = 1;
    
    option_av = 9'b1_0011_1101;
    
    mss = 123;
    scale_wnd = 11;
    
    sack_nbr = 4;
    sack_n0 = 64'h1111_1111_1111_1111;
    sack_n1 = 64'h2222_2222_2222_2222;
    sack_n2 = 64'h3333_3333_3333_3333;
    sack_n3 = 64'h4444_4444_4444_4444;
    
    time_stp = 64'h1234_1234_1234_1234;
    
    #40;
    
    
    $finish;
  end
  
  
  always
    #1 clk = ~clk;
  
  
  initial begin
    $display("  T\ten\tclk\trst\topt_av\tmss\ts_wnd\tsack_n\ts0\t\t\ts1\t\t\ts2\t\t\ts3\t\t\tt_stp\t\t\td_opt\t\ts");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%d", 
             $time, enable, clk, reset, option_av, mss, scale_wnd,
             sack_nbr, sack_n0, sack_n1, sack_n2, sack_n3,
             time_stp, data_option, dut.next_state);
    // $dumpvars(0, UDP_decoder_tb);
  end
  
  TCP_option_encoder dut (.enable(enable), .clk(clk), .reset(reset), 
                          .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd),
                          .sack_nbr(sack_nbr), .sack_n0(sack_n0), .sack_n1(sack_n1), 
                          .sack_n2(sack_n2), .sack_n3(sack_n3), .time_stp(time_stp), 
                          .data_option(data_option));
  
endmodule
