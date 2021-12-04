module TCP_option_decoder (data, clk, reset,
                           option_av, mss, scale_wnd,
                           sack_nbr, sack_n0, sack_n1, sack_n2, sack_n3,
                           time_stp, option_err);
  input [31:0] data;
  input clk, reset;
  
  output [8:0] option_av;
    output [15:0] mss; // option 2
    output [7:0] scale_wnd; // option 3
    output [2:0] sack_nbr; // option 5
      output [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    output [63:0] time_stp; // option 8
  output [8:0] option_err;
  
  wire [31:0] data;
  wire [7:0] bytes [0:3];
    assign bytes[0] = data[31:24];
    assign bytes[1] = data[23:16];
    assign bytes[2] = data[15:8];
    assign bytes[3] = data[7:0];
  wire clk, reset;
  
  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  wire [8:0] option_err;
  
  
  // Priority detector - start
  wire [3:0] option_str_detected;
  genvar i;
  for (i = 0; i < 4; i = i + 1)
    assign option_str_detected[i] = 
      bytes[i] == 0 || bytes[i] == 2 || bytes[i] == 3 || 
      bytes[i] == 4 || bytes[i] == 5 || bytes[i] == 8 ;
  
  reg [2:0] pos0, pos1;
  reg [2:0] start_at_0, start_at_1; // assigned in *Bytes skip logic
  always @(option_str_detected or start_at_0 or start_at_1) begin
    if (option_str_detected[0] && start_at_0 < 1) pos0 = 0;
    else if (option_str_detected[1] && start_at_0 < 2) pos0 = 1;
    else if (option_str_detected[2] && start_at_0 < 3) pos0 = 2;
    else if (option_str_detected[3] && start_at_0 < 4) pos0 = 3;
    else pos0 = 4;
    
    if (option_str_detected[0] && start_at_1 < 1) pos1 = 0;
    else if (option_str_detected[1] && start_at_1 < 2) pos1 = 1;
    else if (option_str_detected[2] && start_at_1 < 3) pos1 = 2;
    else if (option_str_detected[3] && start_at_1 < 4) pos1 = 3;
    else pos1 = 4;
  end
  // Priority detector - end
  
  
  // Bytes skip logic - start
  always @(b_left_0 or b_left_1 or bytes[0] or bytes[1] or bytes[2] or bytes[3] or pos0) begin
    if (b_left_0 == 0 && b_left_1 == 0) begin
      start_at_0 = 0;
      if (pos0 < 4) begin
        if (bytes[pos0] == 0) start_at_1 = 4;
        else if (bytes[pos0] == 2) start_at_1 = pos0 + 4;
        else if (bytes[pos0] == 3) start_at_1 = pos0 + 3;
        else if (bytes[pos0] == 4) start_at_1 = pos0 + 2;
      end 
      else start_at_1 = 4;
    end else if (b_left_0 != 0 && b_left_1 == 0) begin
      start_at_0 = 4;
      if (b_left_0 == 1 && bytes[1] == 8'd4) begin
        start_at_1 = 3;
        enable_fix = 1;
      end else begin 
        start_at_1 = b_left_0;
        enable_fix = 0;
      end
    end else if (b_left_0 == 0 && b_left_1 != 0) begin
      start_at_1 = 4;
      if (b_left_1 == 1 & bytes[1] == 8'd4) begin
        start_at_0 = 3;
        enable_fix = 1;
      end else begin
        start_at_0 = b_left_1;
        enable_fix = 0;
      end 
    end
  end
  // Bytes skip logic - end
  
  
  // OPT4_Fix - start
  reg enable_fix, opt4_av;
  always @(posedge clk)
    if (reset) opt4_av <= 0;
    else if (enable_fix) opt4_av <= 1;
  // OPT4_Fix - end
  
  
  // Output shift + byte counter - start 
  wire [8:0] option_av_0, option_av_1;
    wire [15:0] mss_0, mss_1; // option 2
    wire [7:0] scale_wnd_0, scale_wnd_1; // option 3
    wire [2:0] sack_nbr_0, sack_nbr_1; // option 5
      wire [63:0] sack_n0_0, sack_n1_0, sack_n2_0, sack_n3_0,
                  sack_n0_1, sack_n1_1, sack_n2_1, sack_n3_1; // option 5
    wire [63:0] time_stp_0, time_stp_1; // option 8
  wire [8:0] option_err_0, option_err_1;
  wire [5:0] b_left_0, b_left_1;
  
  output_shift_byte_counter decoder0 (.pos(pos0), .data(data), .clk(clk), .reset(reset),
                                      .option_av(option_av_0), .mss(mss_0), 
                                      .scale_wnd(scale_wnd_0), .sack_nbr(sack_nbr_0),
                                      .sack_n0(sack_n0_0), .sack_n1(sack_n1_0), 
                                      .sack_n2(sack_n2_0), .sack_n3(sack_n3_0),
                                      .time_stp(time_stp_0), .option_err(option_err_0), 
                                      .b_left(b_left_0));
                                  
  output_shift_byte_counter decoder1 (.pos(pos1), .data(data), .clk(clk), .reset(reset),
                                      .option_av(option_av_1), .mss(mss_1), 
                                      .scale_wnd(scale_wnd_1), .sack_nbr(sack_nbr_1),
                                      .sack_n0(sack_n0_1), .sack_n1(sack_n1_1), 
                                      .sack_n2(sack_n2_1), .sack_n3(sack_n3_1),
                                      .time_stp(time_stp_1), .option_err(option_err_1), 
                                      .b_left(b_left_1));
                                      
  assign option_av = option_av_0 | option_av_1 | {4'd0, opt4_av, 4'd0};
  assign mss = mss_0 | mss_1; // option 2
  assign scale_wnd = scale_wnd_0 | scale_wnd_1; // option 3
  assign sack_nbr = sack_nbr_0 | sack_nbr_1; // option 5
  assign sack_n0 = sack_n0_0 | sack_n0_1;
  assign sack_n1 = sack_n1_0 | sack_n1_1;
  assign sack_n2 = sack_n2_0 | sack_n2_1;
  assign sack_n3 = sack_n3_0 | sack_n3_1; // option 5
  assign time_stp = time_stp_0 | time_stp_1; // option 8
  assign option_err = option_err_0 | option_err_1;
  // Output shift + byte counter - end
  
endmodule
