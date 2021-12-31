module output_shift_byte_counter_tb ();
  reg [2:0] pos;
  reg [31:0] data;
  reg clk, reset;

  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  wire [8:0] option_err;
  wire [5:0] b_left;
  
  initial begin
    clk = 0;
    //test_option_0();
    //test_option_2(16'h1234);
    //test_option_3(123);
    //test_option_4();
    test_option_5(4);
    //test_option_8(64'h12345678_12345678);
    
    $finish;
  end
  
  task test_option_0;
    begin
      reg [31:0] content;
      reg [2:0] i;
      content = 32'hff00_0000;
      
      for (i = 0; i < 4; i = i + 1) begin
        reset = 1;
        @(negedge clk);
        reset = 0;
        pos = i;
        data = 32'hffff_ffff ^ (content >> (8*pos));
        @(negedge clk);
      end
    end
  endtask
  
  task test_option_2;
    input [15:0] mss_value;
    
    begin
      reg [31:0] content;
      integer i;
      content = {8'd2, 8'd4, mss_value};
      
      for (i = 0; i < 4; i = i + 1) begin
        reset = 1;
        @(negedge clk);
        reset = 0;
        pos = i;
        data = 32'd0 | (content >> (8*pos));
        @(negedge clk);
        if (i > 0) begin
          data = 32'd0 | (content << (8*(4-i)));
          @(negedge clk);
        end
      end
    end
  endtask
  
  task test_option_3;
    input [7:0] scale_value;
    
    begin
      reg [31:0] content;
      integer i;
      content = {8'd3, 8'd3, scale_value, 8'd0};
      
      for (i = 0; i < 4; i = i + 1) begin
        reset = 1;
        @(negedge clk);
        reset = 0;
        pos = i;
        data = 32'd0 | (content >> (8*pos));
        @(negedge clk);
        if (i > 1) begin
          data = 32'd0 | (content << (8*(4-i)));
          @(negedge clk);
        end
      end
    end
  endtask
  
  task test_option_4;
    begin
      reg [31:0] content;
      integer i;
      content = {8'd4, 8'd2, 16'hffff};
      
      for (i = 0; i < 4; i = i + 1) begin
        reset = 1;
        @(negedge clk);
        reset = 0;
        pos = i;
        data = 32'd0 | (content >> (8*pos));
        @(negedge clk);
        if (i > 2) begin
          data = 32'd0 | (content << (8*(4-i)));
          @(negedge clk);
        end
      end
    end
  endtask
  
  task test_option_5;
    input [7:0] sack_nbr_value;
    
    begin
      reg [31:0] pattern;
      reg [63:0] sack_pack;
      reg [8*34-1:0] pkg;
      integer i, skip_byte, bytes_left;
      pattern = 31'h12345678;
      sack_pack = {pattern, pattern};
      pkg = {8'd5, (sack_nbr_value<<3) + 8'd2, {4{sack_pack}}};
      skip_byte = 34 - 8*sack_nbr_value - 2;
      
      // outside reset, skip reset for each case
      reset = 1;
      @(negedge clk);
      reset = 0;
      
      for (i = 0; i < 4; i = i + 1) begin
        // skip resetting
        pos = i;
        data = 32'd0 | (pkg >> (8*(pos+30)));
        bytes_left = ((sack_nbr_value<<3) + 8'd2) - (4 - i);
        @(negedge clk);
        
        while (bytes_left > 0) begin
          if (bytes_left > 3) 
            data = 32'd0 | ((pkg >> 8*skip_byte) >> 8*(bytes_left-4));
          else data = 32'd0 | ((pkg >> 8*skip_byte) << 8*(4-bytes_left));
          bytes_left = (bytes_left > 3) ? (bytes_left-4) : 0;
          @(negedge clk);
        end
        
      end
    end
  endtask
  
  task test_option_8;
    input [63:0] time_stp_value;
    
    begin
      reg [79:0] content;
      integer i, bytes_left;
      content = {8'd8, 8'd10, time_stp_value};
      
      for (i = 0; i < 4; i = i + 1) begin
        reset = 1;
        @(negedge clk);
        reset = 0;
        pos = i;
        data = 32'd0 | (content >> (8*(pos+6)));
        bytes_left = 10 - (4 - i);
        @(negedge clk);
        while (bytes_left > 0) begin
          if (bytes_left > 3) 
            data = 32'd0 | (content >> (8*(bytes_left-4)));
          else data = 32'd0 | (content << (8*(4-bytes_left)));
          bytes_left = (bytes_left > 3) ? (bytes_left-4) : 0;
          @(negedge clk);
        end
      end
    end
  endtask
  
  always
    #1 clk = ~clk;
  
  // used to test option 5
  initial begin
    $display("  T\tpos\tdata\t\tclk\treset\topt_av\tsack_n\ts0\t\t\ts1\t\t\ts2\t\t\ts3\t\t\topt_err\tbleft\tnst");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%d", 
             $time, pos, data, clk, reset,
             option_av, sack_nbr,
             sack_n0, sack_n1, sack_n2, sack_n3,
             option_err, b_left, dut.next_state);
    // $dumpvars(0, UDP_decoder_tb);
  end
  
  
  /*
  // used to test option != 5
  initial begin
    $display("  T\tpos\tdata\t\tclk\trst\topt_av\tmss\ts_wnd\tsack_n\tt_stp\t\t\topt_err\tbleft\tdut_ns");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%d", 
             $time, pos, data, clk, reset,
             option_av, mss, scale_wnd, sack_nbr,
             time_stp, option_err, b_left, dut.next_state);
    // $dumpvars(0, UDP_decoder_tb);
  end
  */
  
  output_shift_byte_counter dut (.pos(pos), .data(data), .clk(clk), .reset(reset),
                                 .option_av(option_av), .mss(mss), 
                                 .scale_wnd(scale_wnd), .sack_nbr(sack_nbr),
                                 .sack_n0(sack_n0), .sack_n1(sack_n1), 
                                 .sack_n2(sack_n2), .sack_n3(sack_n3),
                                 .time_stp(time_stp), .option_err(option_err), .b_left(b_left));
  
endmodule
