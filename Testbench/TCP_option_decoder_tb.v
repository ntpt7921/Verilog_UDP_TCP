module TCP_option_decoder_tb ();
  reg [31:0] data;
  reg clk, reset;
  
  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  wire [8:0] option_err;
  
  reg [1:0] cur_pos;
  
  initial begin
    clk = 0;
    reset = 1;
    @(negedge clk);
    reset = 0;
    data = 0;
    cur_pos = 0;
    
    //test_option_0();
    test_option_1();
    test_option_2(16'h1234);
    test_option_4();
    test_option_3(123);
    //test_option_1();
    //test_option_5(4);
    //test_option_1();
    //test_option_8(64'h12345678_12345678);
    
    @(negedge clk);
    $finish;
  end
  
  task test_option_0;
    reg [31:0] content;
    integer i;
    content = {8'd0, 24'd0};
    
    data = data | (content >> (8*cur_pos));
    
    if (cur_pos == 3) begin
      @(negedge clk);
      data = 32'd0;
    end
    
    cur_pos = (cur_pos + 1) % 4;
  endtask
  
  task test_option_1;
    reg [31:0] content;
    integer i;
    content = {8'd1, 24'd0};
    
    data = data | (content >> (8*cur_pos));
    
    if (cur_pos == 3) begin
      @(negedge clk);
      data = 32'd0;
    end
    
    cur_pos = (cur_pos + 1) % 4;
  endtask
  
  task test_option_2;
    input [15:0] mss;
    reg [31:0] content;
    integer i, bytes_left;
    content = {8'd2, 8'd4, mss};
    
    data = data | (content >> (8*cur_pos));
    bytes_left = cur_pos;
    
    if (bytes_left > 0) begin
      @(negedge clk);
      data = 32'd0 | (content << (8*(4-bytes_left)));
    end else if (cur_pos == 0) begin
      @(negedge clk);
      data = 32'd0;
    end
    
    cur_pos = (cur_pos + 4) % 4;
    
  endtask
  
  task test_option_3;
    input [7:0] scl_wnd;
    reg [31:0] content;
    integer i, bytes_left;
    content = {8'd3, 8'd3, scl_wnd, 8'd0};
    
    data = data | (content >> (8*cur_pos));
    bytes_left = (cur_pos < 2) ? 0 : (3 - (4 - cur_pos));
    
    if (bytes_left > 0) begin
      @(negedge clk);
      data = 32'd0 | (content << (8*(3-bytes_left)));
    end else if (cur_pos == 1) begin
      @(negedge clk);
      data = 32'd0;
    end
    
    cur_pos = (cur_pos + 3) % 4;
  endtask
  
  task test_option_4;
    reg [31:0] content;
    integer bytes_left;
    content = {8'd4, 8'd2, 16'd0};
    
    data = data | (content >> (8*cur_pos));
    bytes_left = (cur_pos == 3) ? 1 : 0;
    if (bytes_left == 1) begin
      @(negedge clk);
      data = 32'd0 | (content << 8);
    end else if (cur_pos == 2) begin
      @(negedge clk);
      data = 32'd0;
    end
    
    cur_pos = (cur_pos + 2) % 4;
  endtask
  
  task test_option_5;
    input [7:0] sack_nbr_value;
    reg [31:0] pattern;
    reg [63:0] sack_pack;
    reg [8*34-1:0] pkg;
    integer i, skip_byte, bytes_left;
    pattern = 31'h12345678;
    sack_pack = {pattern, pattern};
    pkg = {8'd5, (sack_nbr_value<<3) + 8'd2, {4{sack_pack}}};
    skip_byte = 34 - 8*sack_nbr_value - 2;
    
    
    data = data | (pkg >> (8*(cur_pos+30)));
    bytes_left = ((sack_nbr_value<<3) + 8'd2) - (4 - cur_pos);
    @(negedge clk);
    
    while (bytes_left > 0) begin
      if (bytes_left > 3) begin
        data = 32'd0 | ((pkg >> 8*skip_byte) >> 8*(bytes_left-4));
        bytes_left = bytes_left-4;
        @(negedge clk);
      end
      else begin
        data = 32'd0 | ((pkg >> 8*skip_byte) << 8*(4-bytes_left));
        bytes_left = 0;
      end
    end
    
    cur_pos = (cur_pos + 10) % 4;
  endtask
  
  task test_option_8;
    input [63:0] time_stp_value;
    reg [79:0] content;
    integer i, bytes_left;
    content = {8'd8, 8'd10, time_stp_value};
    
    data = data | (content >> (8*(cur_pos+6)));
    bytes_left = 10 - (4 - cur_pos);
    @(negedge clk);
    while (bytes_left > 0) begin
      if (bytes_left > 3) begin
        data = 32'd0 | (content >> (8*(bytes_left-4)));
        bytes_left = bytes_left-4;
        @(negedge clk);
      end
      else begin
        data = 32'd0 | (content << (8*(4-bytes_left)));
        bytes_left = 0;
      end
    end
    
    cur_pos = (cur_pos + 10) % 4;
  endtask
  
  always
    #1 clk = ~clk;
  
  
  initial begin
    $display("  T\tdata\t\tclk\treset\topt_av\tmss\ts_wnd\tsack_n\ts0\t\t\ts1\t\t\ts2\t\t\ts3\t\t\tt_stp\t\t\topt_err");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, clk, reset,
             option_av, mss, scale_wnd,
             sack_nbr, sack_n0, sack_n1, sack_n2, sack_n3,
             time_stp, option_err);
    // $dumpvars(0, UDP_decoder_tb);
  end
  /*
  initial begin
    $display("  T\tdata\t\tclk\treset\topt_av\tmss\ts_wnd\tsack_n\topt_err\tbl0\tbl1\tpos0\tpos1\tstart0\tstart1");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, clk, reset,
             option_av, mss, scale_wnd,
             sack_nbr, option_err,
             dut.b_left_0, dut.b_left_1, 
             dut.pos0, dut.pos1, 
             dut.start_at_0, dut.start_at_1);
    // $dumpvars(0, UDP_decoder_tb);
  end
  */
  
  
  TCP_option_decoder dut (.data(data), .clk(clk), .reset(reset),
                          .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd),
                          .sack_nbr(sack_nbr), .sack_n0(sack_n0), .sack_n1(sack_n1), 
                          .sack_n2(sack_n2), .sack_n3(sack_n3), 
                          .time_stp(time_stp), .option_err(option_err));
  
endmodule
