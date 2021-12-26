module TCP_option_encoder (enable, clk, reset, option_av, mss, scale_wnd,
                           sack_nbr, sack_n0, sack_n1, sack_n2, sack_n3,
                           time_stp, data_option);
  input enable, clk, reset;
  input [8:0] option_av;
    input [15:0] mss; // option 2
    input [7:0] scale_wnd; // option 3
    input [2:0] sack_nbr; // option 5
      input [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    input [63:0] time_stp; // option 8
  
  output [31:0] data_option; // used by *Option output
  
  
  wire enable, clk, reset;
  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  
  reg [31:0] data_option; // used by *Option output
  
  
  // Priority option selector - start
  reg [3:0] option_done; // used by *Option output
  reg [3:0] option_num;
  always @(option_av or option_done) begin
    // order of choosing option is  2, 3, 4, 8, 5, 0
    // corresponding option_done 0, 1, 2, 3, 4, 5, 6
    if (option_av[2] && option_done < 1) option_num = 2;
    else if (option_av[3] && option_done < 2) option_num = 3;
    else if (option_av[4] && option_done < 3) option_num = 4;
    else if (option_av[8] && option_done < 4) option_num = 8;
    else if (option_av[5] && option_done < 5) option_num = 5;
    else if (option_av[0] && option_done < 6) option_num = 0;
    else option_num = 1;
  end
  // Priority option selector - end 
  
  
  // Option output - start
  parameter IDLE = 0;
  parameter OPT2 = 1;
  parameter OPT3 = 2;
  parameter OPT4 = 3;
  parameter OPT8_1 = 4;
    parameter OPT8_2 = 5;
    parameter OPT8_3 = 6;
  parameter OPT5_L1_1 = 7;
    parameter OPT5_L1_2 = 8;
    parameter OPT5_L1_3 = 9;
  parameter OPT5_L2_1 = 10;
    parameter OPT5_L2_2 = 11;
    parameter OPT5_L2_3 = 12;
    parameter OPT5_L2_4 = 13;
    parameter OPT5_L2_5 = 14;
  parameter OPT5_L3_1 = 15;
    parameter OPT5_L3_2 = 16;
    parameter OPT5_L3_3 = 17;
    parameter OPT5_L3_4 = 18;
    parameter OPT5_L3_5 = 19;
    parameter OPT5_L3_6 = 20;
    parameter OPT5_L3_7 = 21;
  parameter OPT5_L4_1 = 22;
    parameter OPT5_L4_2 = 23;
    parameter OPT5_L4_3 = 24;
    parameter OPT5_L4_4 = 25;
    parameter OPT5_L4_5 = 26;
    parameter OPT5_L4_6 = 27;
    parameter OPT5_L4_7 = 28;
    parameter OPT5_L4_8 = 29;
    parameter OPT5_L4_9 = 30;
  parameter OPT0 = 31;
  
  reg [4:0] state, next_state;
  reg busy;
  always @(*) begin
    if (reset) next_state = IDLE;
    else if (option_num == 2 && !busy) next_state = OPT2;
    else if (option_num == 3 && !busy) next_state = OPT3;
    else if (option_num == 4 && !busy) next_state = OPT4;
    else if (option_num == 8 && !busy) next_state = OPT8_1;
    else if (option_num == 5 && !busy) begin
      case (sack_nbr) 
        1: next_state = OPT5_L1_1;
        2: next_state = OPT5_L2_1;
        3: next_state = OPT5_L3_1;
        4: next_state = OPT5_L4_1;
      endcase
    end else if (option_num == 0 && !busy) next_state = OPT0;
    else begin
      case (state)
        OPT8_1: next_state = OPT8_2;
        OPT8_2: next_state = OPT8_3;
        OPT8_3: next_state = OPT8_3;
        
        OPT5_L1_1: next_state = OPT5_L1_2;
        OPT5_L1_2: next_state = OPT5_L1_3;
        OPT5_L1_3: next_state = OPT5_L1_3;
        
        OPT5_L2_1: next_state = OPT5_L2_2;
        OPT5_L2_2: next_state = OPT5_L2_3;
        OPT5_L2_3: next_state = OPT5_L2_4;
        OPT5_L2_4: next_state = OPT5_L2_5;
        OPT5_L2_5: next_state = OPT5_L2_5;
        
        OPT5_L3_1: next_state = OPT5_L3_2;
        OPT5_L3_2: next_state = OPT5_L3_3;
        OPT5_L3_3: next_state = OPT5_L3_4;
        OPT5_L3_4: next_state = OPT5_L3_5;
        OPT5_L3_5: next_state = OPT5_L3_6;
        OPT5_L3_6: next_state = OPT5_L3_7;
        OPT5_L3_7: next_state = OPT5_L3_7;
        
        OPT5_L4_1: next_state = OPT5_L4_2;
        OPT5_L4_2: next_state = OPT5_L4_3;
        OPT5_L4_3: next_state = OPT5_L4_4;
        OPT5_L4_4: next_state = OPT5_L4_5;
        OPT5_L4_5: next_state = OPT5_L4_6;
        OPT5_L4_6: next_state = OPT5_L4_7;
        OPT5_L4_7: next_state = OPT5_L4_8;
        OPT5_L4_8: next_state = OPT5_L4_9;
        OPT5_L4_9: next_state = OPT5_L4_9;
        
        default: next_state = IDLE;
      endcase
    end
  end
  
  always @(posedge clk) begin
    if (next_state == IDLE) begin
      data_option <= {4{8'h01}};
      option_done <= 0;
      busy <= 0;
    end else if (enable) begin
      state <= next_state;
      case (next_state)
        OPT2: begin
          data_option <= {8'd2, 8'd4, mss};
          option_done <= 1;
        end
        OPT3: begin
          data_option <= {8'd3, 8'd3, scale_wnd, 8'h01};
          option_done <= 2;
        end
        OPT4: begin
          data_option <= {8'd4, 8'd2, 8'h01, 8'h01};
          option_done <= 3;
        end
        OPT0: begin
          data_option <= 32'd0;
          option_done <= 6;
        end
        
        OPT8_1: begin
          data_option <= {8'd8, 8'd10, time_stp[63:48]};
          busy <= 1;
        end
        OPT8_2: data_option <= time_stp[47:16];
        OPT8_3: begin
          data_option <= {time_stp[15:0], 16'h0101};
          option_done <= 4;
          busy <= 0;
        end
        
        OPT5_L1_1: begin
          data_option <= {8'd5, 8'd10, sack_n0[63:48]};
          busy <= 1;
        end
        OPT5_L1_2: data_option <= sack_n0[47:16];
        OPT5_L1_3: begin
          data_option <= {sack_n0[15:0], 16'h0101};
          option_done <= 5;
          busy <= 0;
        end
        
        OPT5_L2_1: begin
          data_option <= {8'd5, 8'd10, sack_n0[63:48]};
          busy <= 1;
        end
        OPT5_L2_2: data_option <= sack_n0[47:16];
        OPT5_L2_3: data_option <= {sack_n0[15:0], sack_n1[63:48]};
        OPT5_L2_4: data_option <= sack_n1[47:16];
        OPT5_L2_4: begin
          data_option <= {sack_n1[15:0], 16'h0101};
          option_done <= 5;
          busy <= 0;
        end
        
        OPT5_L3_1: begin
          data_option <= {8'd5, 8'd10, sack_n0[63:48]};
          busy <= 1;
        end
        OPT5_L3_2: data_option <= sack_n0[47:16];
        OPT5_L3_3: data_option <= {sack_n0[15:0], sack_n1[63:48]};
        OPT5_L3_4: data_option <= sack_n1[47:16];
        OPT5_L3_5: data_option <= {sack_n1[15:0], sack_n2[63:48]};
        OPT5_L3_6: data_option <= sack_n2[47:16];
        OPT5_L3_7: begin
          data_option <= {sack_n2[15:0], 16'h0101};
          option_done <= 5;
          busy <= 0;
        end
        
        OPT5_L4_1: begin
          data_option <= {8'd5, 8'd10, sack_n0[63:48]};
          busy <= 1;
        end
        OPT5_L4_2: data_option <= sack_n0[47:16];
        OPT5_L4_3: data_option <= {sack_n0[15:0], sack_n1[63:48]};
        OPT5_L4_4: data_option <= sack_n1[47:16];
        OPT5_L4_5: data_option <= {sack_n1[15:0], sack_n2[63:48]};
        OPT5_L4_6: data_option <= sack_n2[47:16];
        OPT5_L4_7: data_option <= {sack_n2[15:0], sack_n3[63:48]};
        OPT5_L4_8: data_option <= sack_n3[47:16];
        OPT5_L4_9: begin
          data_option <= {sack_n3[15:0], 16'h0101};
          option_done <= 5;
          busy <= 0;
        end
        
        default: begin
          data_option <= {4{8'h01}};
          option_done <= 0;
          busy <= 0;
        end
      endcase
    end
  end
  
  // Option output - end
  
endmodule
