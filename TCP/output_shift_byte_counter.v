module output_shift_byte_counter (pos, data, clk, reset,
                                  option_av, mss, scale_wnd, sack_nbr,
                                  sack_n0, sack_n1, sack_n2, sack_n3,
                                  time_stp, option_err, b_left);
  input [2:0] pos;
  input [31:0] data;
  input clk, reset;

  output [8:0] option_av;
    output [15:0] mss; // option 2
    output [7:0] scale_wnd; // option 3
    output [2:0] sack_nbr; // option 5
      output [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    output [63:0] time_stp; // option 8
  output [8:0] option_err;
  output [5:0] b_left;
  
  wire [2:0] pos;
  wire [31:0] data;
    wire [7:0] bytes [0:3];
    assign bytes[0] = data[31:24];
    assign bytes[1] = data[23:16];
    assign bytes[2] = data[15:8];
    assign bytes[3] = data[7:0];
  wire clk, reset;

  reg [8:0] option_av;
    reg [15:0] mss; // option 2
    reg [7:0] scale_wnd; // option 3
    reg [2:0] sack_nbr; // option 5
      reg [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    reg [63:0] time_stp; // option 8
  reg [8:0] option_err;
  reg [5:0] b_left;
  
  
  parameter OPT0 = 8'd0;
  //parameter OPT1 = 1;
  parameter OPT2 = 8'd2;
  parameter OPT3 = 8'd3;
  parameter OPT4 = 8'd4;
  parameter OPT5 = 8'd5;
  parameter OPT8 = 8'd8;
  
  
  parameter IDLE = 0;
  parameter UNKNOWN_OPT = 1;
  
  parameter OPT0_SN = 2;
  
  parameter OPT2_S0 = 3;
  parameter OPT2_S1 = 4;
    parameter OPT2_S1_R1 = 5;
  parameter OPT2_S2 = 6;
    parameter OPT2_S2_R2 = 7;
  parameter OPT2_S3 = 8;
    parameter OPT2_S3_R3 = 9;
    
  parameter OPT3_S0 = 10;
  parameter OPT3_S1 = 11;
  parameter OPT3_S2 = 12;
    parameter OPT3_S2_R1 = 13;
  parameter OPT3_S3 = 14;
    parameter OPT3_S3_R2 = 15;
    
  parameter OPT4_S0 = 16;
  parameter OPT4_S1 = 17;
  parameter OPT4_S2 = 18;
  parameter OPT4_S3 = 19;
    parameter OPT4_S3_R1 = 20;
    
  parameter OPT5_S0 = 21;
    parameter OPT5_S0_L10_R6 = 22;
      parameter OPT5_S0_L10_R2 = 23;
    parameter OPT5_S0_L18_R14 = 24;
      parameter OPT5_S0_L18_R10 = 25;
      parameter OPT5_S0_L18_R6 = 26;
      parameter OPT5_S0_L18_R2 = 27;
    parameter OPT5_S0_L26_R22 = 28;
      parameter OPT5_S0_L26_R18 = 29;
      parameter OPT5_S0_L26_R14 = 30;
      parameter OPT5_S0_L26_R10 = 31;
      parameter OPT5_S0_L26_R6 = 32;
      parameter OPT5_S0_L26_R2 = 33;
    parameter OPT5_S0_L34_R30 = 34;
      parameter OPT5_S0_L34_R26 = 35;
      parameter OPT5_S0_L34_R22 = 36;
      parameter OPT5_S0_L34_R18 = 37;
      parameter OPT5_S0_L34_R14 = 38;
      parameter OPT5_S0_L34_R10 = 39;
      parameter OPT5_S0_L34_R6 = 40;
      parameter OPT5_S0_L34_R2 = 41;
  parameter OPT5_S1 = 42;
    parameter OPT5_S1_L10_R7 = 43;
      parameter OPT5_S1_L10_R3 = 44;
    parameter OPT5_S1_L18_R15 = 45;
      parameter OPT5_S1_L18_R11 = 46;
      parameter OPT5_S1_L18_R7 = 47;
      parameter OPT5_S1_L18_R3 = 48;
    parameter OPT5_S1_L26_R23 = 49;
      parameter OPT5_S1_L26_R19 = 50;
      parameter OPT5_S1_L26_R15 = 51;
      parameter OPT5_S1_L26_R11 = 52;
      parameter OPT5_S1_L26_R7 = 53;
      parameter OPT5_S1_L26_R3 = 54;
    parameter OPT5_S1_L34_R31 = 55;
      parameter OPT5_S1_L34_R27 = 56;
      parameter OPT5_S1_L34_R23 = 57;
      parameter OPT5_S1_L34_R19 = 58;
      parameter OPT5_S1_L34_R15 = 59;
      parameter OPT5_S1_L34_R11 = 60;
      parameter OPT5_S1_L34_R7 = 61;
      parameter OPT5_S1_L34_R3 = 62;
  parameter OPT5_S2 = 63;
    parameter OPT5_S2_L10_R8 = 64;
      parameter OPT5_S2_L10_R4 = 65;
    parameter OPT5_S2_L18_R16 = 66;
      parameter OPT5_S2_L18_R12 = 68;
      parameter OPT5_S2_L18_R8 = 69;
      parameter OPT5_S2_L18_R4 = 70;
    parameter OPT5_S2_L26_R24 = 71;
      parameter OPT5_S2_L26_R20 = 73;
      parameter OPT5_S2_L26_R16 = 74;
      parameter OPT5_S2_L26_R12 = 75;
      parameter OPT5_S2_L26_R8 = 76;
      parameter OPT5_S2_L26_R4 = 77;
    parameter OPT5_S2_L34_R32 = 78;
      parameter OPT5_S2_L34_R28 = 80;
      parameter OPT5_S2_L34_R24 = 81;
      parameter OPT5_S2_L34_R20 = 82;
      parameter OPT5_S2_L34_R16 = 83;
      parameter OPT5_S2_L34_R12 = 84;
      parameter OPT5_S2_L34_R8 = 85;
      parameter OPT5_S2_L34_R4 = 86;
  parameter OPT5_S3 = 87;
    parameter OPT5_S3_LN_RN = 88;
      parameter OPT5_S3_L10_R5 = 89;
        parameter OPT5_S3_L10_R1 = 90;
      parameter OPT5_S3_L18_R13 = 91;
        parameter OPT5_S3_L18_R9 = 92;
        parameter OPT5_S3_L18_R5 = 93;
        parameter OPT5_S3_L18_R1 = 94;
      parameter OPT5_S3_L26_R21 = 95;
        parameter OPT5_S3_L26_R17 = 96;
        parameter OPT5_S3_L26_R13 = 97;
        parameter OPT5_S3_L26_R9 = 98;
        parameter OPT5_S3_L26_R5 = 99;
        parameter OPT5_S3_L26_R1 = 100;
      parameter OPT5_S3_L34_R29 = 101;
        parameter OPT5_S3_L34_R25 = 102;
        parameter OPT5_S3_L34_R21 = 103;
        parameter OPT5_S3_L34_R17 = 104;
        parameter OPT5_S3_L34_R13 = 105;
        parameter OPT5_S3_L34_R9 = 106;
        parameter OPT5_S3_L34_R5 = 107;
        parameter OPT5_S3_L34_R1 = 108;
    
  parameter OPT8_S0 = 109;
    parameter OPT8_S0_R6 = 110;
    parameter OPT8_S0_R2 = 111;
  parameter OPT8_S1 = 112;
    parameter OPT8_S1_R7 = 113;
    parameter OPT8_S1_R3 = 114;
  parameter OPT8_S2 = 115;
    parameter OPT8_S2_R8 = 116;
    parameter OPT8_S2_R4 = 117;
  parameter OPT8_S3 = 118;
    parameter OPT8_S3_R9 = 119;
    parameter OPT8_S3_R5 = 120;
    parameter OPT8_S3_R1 = 121;
  
  reg [6:0] state, next_state;
  
  always @(reset or state or pos or b_left or bytes[0] or bytes[1] or bytes[2] or bytes[3]) begin
    if (reset) next_state = IDLE;
    else if (state == UNKNOWN_OPT) next_state = UNKNOWN_OPT;
    else if ((state == IDLE || b_left == 0) && pos > 3) next_state = IDLE;
    else if ((state == IDLE || b_left == 0) && pos == 0) begin
      case (bytes[0]) 
        OPT0: next_state = OPT0_SN;
        OPT2: next_state = OPT2_S0;
        OPT3: next_state = OPT3_S0;
        OPT4: next_state = OPT4_S0;
        OPT5: next_state = OPT5_S0;
        OPT8: next_state = OPT8_S0;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if ((state == IDLE || b_left == 0) && pos == 1) begin
      case (bytes[1]) 
        OPT0: next_state = OPT0_SN;
        OPT2: next_state = OPT2_S1;
        OPT3: next_state = OPT3_S1;
        OPT4: next_state = OPT4_S1;
        OPT5: next_state = OPT5_S1;
        OPT8: next_state = OPT8_S1;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if ((state == IDLE || b_left == 0) && pos == 2) begin
      case (bytes[2]) 
        OPT0: next_state = OPT0_SN;
        OPT2: next_state = OPT2_S2;
        OPT3: next_state = OPT3_S2;
        OPT4: next_state = OPT4_S2;
        OPT5: next_state = OPT5_S2;
        OPT8: next_state = OPT8_S2;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if ((state == IDLE || b_left == 0) && pos == 3) begin
      case (bytes[3]) 
        OPT0: next_state = OPT0_SN;
        OPT2: next_state = OPT2_S3;
        OPT3: next_state = OPT3_S3;
        OPT4: next_state = OPT4_S3;
        OPT5: next_state = OPT5_S3;
        OPT8: next_state = OPT8_S3;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if (state == OPT5_S0) begin
      case (sack_nbr) 
        1: next_state = OPT5_S0_L10_R6;
        2: next_state = OPT5_S0_L18_R14;
        3: next_state = OPT5_S0_L26_R22;
        4: next_state = OPT5_S0_L34_R30;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if (state == OPT5_S1) begin 
      case (sack_nbr) 
        1: next_state = OPT5_S1_L10_R7;
        2: next_state = OPT5_S1_L18_R15;
        3: next_state = OPT5_S1_L26_R23;
        4: next_state = OPT5_S1_L34_R31;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if (state == OPT5_S2) begin
      case (sack_nbr) 
        1: next_state = OPT5_S2_L10_R8;
        2: next_state = OPT5_S2_L18_R16;
        3: next_state = OPT5_S2_L26_R24;
        4: next_state = OPT5_S2_L34_R32;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else if (state == OPT5_S3) next_state = OPT5_S3_LN_RN;
    else if (state == OPT5_S3_LN_RN) begin
      case (sack_nbr) 
        1: next_state = OPT5_S3_L10_R5;
        2: next_state = OPT5_S3_L18_R13;
        3: next_state = OPT5_S3_L26_R21;
        4: next_state = OPT5_S3_L34_R29;
        default: next_state = UNKNOWN_OPT;
      endcase
    end else case (state)
      //OPT2_S0: next_state = IDLE;
      OPT2_S1: next_state = OPT2_S1_R1;
        //OPT2_S1_R1: next_state = IDLE;
      OPT2_S2: next_state = OPT2_S2_R2;
        //OPT2_S2_R2: next_state = IDLE;
      OPT2_S3: next_state = OPT2_S3_R3;
        //OPT2_S3_R3: next_state = IDLE;
        
      OPT3_S0: next_state = IDLE;
      OPT3_S1: next_state = IDLE;
      OPT3_S2: next_state = OPT3_S2_R1;
        //OPT3_S2_R1: next_state = IDLE;
      OPT3_S3: next_state = OPT3_S3_R2;
        //OPT3_S3_R2: next_state = IDLE;
        
      //OPT4_S0: next_state = IDLE;
      //OPT4_S1: next_state = IDLE;
      //OPT4_S2: next_state = IDLE;
      OPT4_S3: next_state = OPT4_S3_R1;
        //OPT4_S3_R1: next_state = IDLE;
      
      OPT8_S0: next_state = OPT8_S0_R6;
        OPT8_S0_R6: next_state = OPT8_S0_R2;
        //OPT8_S0_R2: next_state = IDLE;
      OPT8_S1: next_state = OPT8_S1_R7;
        OPT8_S1_R7: next_state = OPT8_S1_R3;
        //OPT8_S1_R3: next_state = IDLE;
      OPT8_S2: next_state = OPT8_S2_R8;
        OPT8_S2_R8: next_state = OPT8_S2_R4;
        //OPT8_S2_R4: next_state = IDLE;
      OPT8_S3: next_state = OPT8_S3_R9;
        OPT8_S3_R9: next_state = OPT8_S3_R5;
        OPT8_S3_R5: next_state = OPT8_S3_R1;
        //OPT8_S3_R1: next_state = IDLE;
        
      OPT5_S0_L10_R6: next_state = OPT5_S0_L10_R2;
        //OPT5_S0_L10_R2: next_state = IDLE;
      OPT5_S0_L18_R14: next_state = OPT5_S0_L18_R10;
        OPT5_S0_L18_R10: next_state = OPT5_S0_L18_R6;
        OPT5_S0_L18_R6: next_state = OPT5_S0_L18_R2;
        //OPT5_S0_L18_R2: next_state = IDLE;
      OPT5_S0_L26_R22: next_state = OPT5_S0_L26_R18;
        OPT5_S0_L26_R18: next_state = OPT5_S0_L26_R14;
        OPT5_S0_L26_R14: next_state = OPT5_S0_L26_R10;
        OPT5_S0_L26_R10: next_state = OPT5_S0_L26_R6;
        OPT5_S0_L26_R6: next_state = OPT5_S0_L26_R2;
        //OPT5_S0_L26_R2: next_state = IDLE;
      OPT5_S0_L34_R30: next_state = OPT5_S0_L34_R26;
        OPT5_S0_L34_R26: next_state = OPT5_S0_L34_R22;
        OPT5_S0_L34_R22: next_state = OPT5_S0_L34_R18;
        OPT5_S0_L34_R18: next_state = OPT5_S0_L34_R14;
        OPT5_S0_L34_R14: next_state = OPT5_S0_L34_R10;
        OPT5_S0_L34_R10: next_state = OPT5_S0_L34_R6;
        OPT5_S0_L34_R6: next_state = OPT5_S0_L34_R2;
        //OPT5_S0_L34_R2: next_state = IDLE;
      
      OPT5_S1_L10_R7: next_state = OPT5_S1_L10_R3;
        //OPT5_S1_L10_R3: next_state = IDLE;
      OPT5_S1_L18_R15: next_state = OPT5_S1_L18_R11;
        OPT5_S1_L18_R11: next_state = OPT5_S1_L18_R7;
        OPT5_S1_L18_R7: next_state = OPT5_S1_L18_R3;
        //OPT5_S1_L18_R3: next_state = IDLE;
      OPT5_S1_L26_R23: next_state = OPT5_S1_L26_R19;
        OPT5_S1_L26_R19: next_state = OPT5_S1_L26_R15;
        OPT5_S1_L26_R15: next_state = OPT5_S1_L26_R11;
        OPT5_S1_L26_R11: next_state = OPT5_S1_L26_R7;
        OPT5_S1_L26_R7: next_state = OPT5_S1_L26_R3;
        //OPT5_S1_L26_R3: next_state = IDLE;
      OPT5_S1_L34_R31: next_state = OPT5_S1_L34_R27;
        OPT5_S1_L34_R27: next_state = OPT5_S1_L34_R23;
        OPT5_S1_L34_R23: next_state = OPT5_S1_L34_R19;
        OPT5_S1_L34_R19: next_state = OPT5_S1_L34_R15;
        OPT5_S1_L34_R15: next_state = OPT5_S1_L34_R11;
        OPT5_S1_L34_R11: next_state = OPT5_S1_L34_R7;
        OPT5_S1_L34_R7: next_state = OPT5_S1_L34_R3;
        //OPT5_S1_L34_R3: next_state = IDLE;
      
      OPT5_S2_L10_R8: next_state = OPT5_S2_L10_R4;
        //OPT5_S2_L10_R4: next_state = IDLE;
      OPT5_S2_L18_R16: next_state = OPT5_S2_L18_R12;
        OPT5_S2_L18_R12: next_state = OPT5_S2_L18_R8;
        OPT5_S2_L18_R8: next_state = OPT5_S2_L18_R4;
        //OPT5_S2_L18_R4: next_state = IDLE;
      OPT5_S2_L26_R24: next_state = OPT5_S2_L26_R20;
        OPT5_S2_L26_R20: next_state = OPT5_S2_L26_R16;
        OPT5_S2_L26_R16: next_state = OPT5_S2_L26_R12;
        OPT5_S2_L26_R12: next_state = OPT5_S2_L26_R8;
        OPT5_S2_L26_R8: next_state = OPT5_S2_L26_R4;
        //OPT5_S2_L26_R4: next_state = IDLE;
      OPT5_S2_L34_R32: next_state = OPT5_S2_L34_R28;
        OPT5_S2_L34_R28: next_state = OPT5_S2_L34_R24;
        OPT5_S2_L34_R24: next_state = OPT5_S2_L34_R20;
        OPT5_S2_L34_R20: next_state = OPT5_S2_L34_R16;
        OPT5_S2_L34_R16: next_state = OPT5_S2_L34_R12;
        OPT5_S2_L34_R12: next_state = OPT5_S2_L34_R8;
        OPT5_S2_L34_R8: next_state = OPT5_S2_L34_R4;
        //OPT5_S2_L34_R4: next_state = IDLE;
        
      OPT5_S3_L10_R5: next_state = OPT5_S3_L10_R1;
        //OPT5_S3_L10_R1: next_state = IDLE;
      OPT5_S3_L18_R13: next_state = OPT5_S3_L18_R9;
        OPT5_S3_L18_R9: next_state = OPT5_S3_L18_R5;
        OPT5_S3_L18_R5: next_state = OPT5_S3_L18_R1;
        //OPT5_S3_L18_R1: next_state = IDLE;
      OPT5_S3_L26_R21: next_state = OPT5_S3_L26_R17;
        OPT5_S3_L26_R17: next_state = OPT5_S3_L26_R13;
        OPT5_S3_L26_R13: next_state = OPT5_S3_L26_R9;
        OPT5_S3_L26_R9: next_state = OPT5_S3_L26_R5;
        OPT5_S3_L26_R5: next_state = OPT5_S3_L26_R1;
        //OPT5_S3_L26_R1: next_state = IDLE;
      OPT5_S3_L34_R29: next_state = OPT5_S3_L34_R25;
        OPT5_S3_L34_R25: next_state = OPT5_S3_L34_R21;
        OPT5_S3_L34_R21: next_state = OPT5_S3_L34_R17;
        OPT5_S3_L34_R17: next_state = OPT5_S3_L34_R13;
        OPT5_S3_L34_R13: next_state = OPT5_S3_L34_R9;
        OPT5_S3_L34_R9: next_state = OPT5_S3_L34_R5;
        OPT5_S3_L34_R5: next_state = OPT5_S3_L34_R1;
        //OPT5_S3_L34_R1: next_state = IDLE;
        
      default: next_state = UNKNOWN_OPT;
    endcase
  end
  
  always @(posedge clk) begin
    state <= next_state;
  end
  
  //reg [5:0] b_left;
  //reg [2:0] sack_nbr;
  always @(posedge clk) begin
    if (reset) begin
      option_av <= 0;
      mss <= 0;
      scale_wnd <= 0; 
      sack_nbr <= 0;
      sack_n0 <= 0;
      sack_n1 <= 0;
      sack_n2 <= 0;
      sack_n3 <= 0;
      time_stp <= 0;
      option_err <= 0;
      b_left <= 0;
    end case (next_state)
      IDLE: b_left <= 0;
      UNKNOWN_OPT: option_err <= 9'b1_1111_1111;
      
      OPT0_SN: begin
        option_av[0] <= 1;
        b_left <= 0;
      end
      
      OPT2_S0: begin 
        option_av[2] <= 1;
        b_left <= 0;
        if (bytes[1] != 4) option_err[2] <= 1;
        mss <= {bytes[2], bytes[3]};
      end
      OPT2_S1: begin
        option_av[2] <= 1;
        b_left <= 1;
        if (bytes[2] != 4) option_err[2] <= 1;
        mss[15:8] <= bytes[3];
      end
        OPT2_S1_R1: begin
          b_left <= 0;
          mss[7:0] <= bytes[0];
        end
      OPT2_S2: begin
        option_av[2] <= 1;
        b_left <= 2;
        if (bytes[3] != 4) option_err[2] <= 1;
      end
        OPT2_S2_R2: begin
          b_left <= 0;
          mss <= {bytes[0], bytes[1]};
        end
      OPT2_S3: begin
        option_av[2] <= 1;
        b_left <= 3;
      end
        OPT2_S3_R3: begin
          b_left <= 0;
          if (bytes[0] != 4) option_err[2] <= 1;
          mss <= {bytes[1], bytes[2]};
        end
        
      OPT3_S0: begin
        option_av[3] <= 1;
        b_left <= 0;
        if (bytes[1] != 3) option_err[3] <= 1;
        scale_wnd <= bytes[2];
      end
      OPT3_S1: begin
        option_av[3] <= 1;
        b_left <= 0;
        if (bytes[2] != 3) option_err[3] <= 1;
        scale_wnd <= bytes[3];
      end
      OPT3_S2: begin
        option_av[3] <= 1;
        b_left <= 1;
        if (bytes[3] != 3) option_err[3] <= 1;
      end
        OPT3_S2_R1: begin
          b_left <= 0;
          scale_wnd <= bytes[0];
        end
      OPT3_S3: begin
        option_av[3] <= 1;
        b_left <= 2;
      end
        OPT3_S3_R2: begin
          b_left <= 0;
          if (bytes[0] != 3) option_err[3] <= 1;
          scale_wnd <= bytes[1];
        end
        
      OPT4_S0: begin
        option_av[4] <= 1;
        b_left <= 0;
        if (bytes[1] != 2) option_err[4] <= 1;
      end
      OPT4_S1: begin
        option_av[4] <= 1;
        b_left <= 0;
        if (bytes[2] != 2) option_err[4] <= 1;
      end
      OPT4_S2: begin
        option_av[4] <= 1;
        b_left <= 0;
        if (bytes[3] != 2) option_err[4] <= 1;
      end
      OPT4_S3: begin
        option_av[4] <= 1;
        b_left <= 1;
      end
        OPT4_S3_R1:  begin
          if (bytes[0] != 2) option_err[4] <= 1;
          b_left <= 0;
        end
        
      OPT8_S0: begin
        option_av[8] <= 1;
        b_left <= 6;
        if (bytes[1] != 10) option_err[8] <= 1;
        time_stp[63:48] <= {bytes[2], bytes[3]};
      end
        OPT8_S0_R6: begin
          b_left <= 2;
          time_stp[47:16] <= data;
        end
        OPT8_S0_R2: begin
          b_left <= 0;
          time_stp[15:0] <= {bytes[0], bytes[1]};
        end
      OPT8_S1: begin
        option_av[8] <= 1;
        b_left <= 7;
        if (bytes[2] != 10) option_err[8] <= 1;
        time_stp[63:56] <= bytes[3];
      end
        OPT8_S1_R7: begin
          b_left <= 3;
          time_stp[55:24] <= data;
        end
        OPT8_S1_R3: begin
          b_left <= 0;
          time_stp[23:0] <= {bytes[0], bytes[1], bytes[2]};
        end
      OPT8_S2: begin
        option_av[8] <= 1;
        b_left <= 8;
        if (bytes[3] != 10) option_err[8] <= 1;
      end
        OPT8_S2_R8: begin
          b_left <= 4;
          time_stp[63:32] <= data;
        end
        OPT8_S2_R4: begin
          b_left <= 0;
          time_stp[31:0] <= data;
        end
      OPT8_S3: begin
        option_av[8] <= 1; 
        b_left <= 9;
      end
        OPT8_S3_R9: begin
          b_left <= 5;
          if (bytes[0] != 10) option_err[8] <= 1;
          time_stp[63:40] <= data;
        end
        OPT8_S3_R5: begin
          b_left <= 1;
          time_stp[39:8] <= data;
        end
        OPT8_S3_R1: begin
          b_left <= 0;
          time_stp[7:0] <= bytes[0];
        end
        
      OPT5_S0: begin
        option_av[5] <= 1;
        if (bytes[1] != 10 && bytes[1] != 18 && bytes[1] != 26 && bytes[1] != 34)
          option_err[5] <= 1;
        b_left <= bytes[1] - 4;
        sack_nbr <= (bytes[1] - 2) >> 3; // (n-2)/8 take integer result
        sack_n0[63:48] <= {bytes[2], bytes[3]};
      end
      
        OPT5_S0_L10_R6: begin
          b_left <= 2;
          sack_n0[47:16] <= data;
        end
          OPT5_S0_L10_R2: begin
            b_left <= 0;
            sack_n0[15:0] <= {bytes[0], bytes[1]};
          end
        
        OPT5_S0_L18_R14: begin
          b_left <= 10;
          sack_n0[47:16] <= data;
        end
          OPT5_S0_L18_R10: begin
            b_left <= 6;
            sack_n0[15:0] <= {bytes[0], bytes[1]};
            sack_n1[63:48] <= {bytes[2], bytes[3]};
          end
          OPT5_S0_L18_R6: begin
            b_left <= 2;
            sack_n1[47:16] <= data;
          end
          OPT5_S0_L18_R2: begin
            b_left <= 0;
            sack_n1[15:0] <= {bytes[0], bytes[1]};
          end
        
        OPT5_S0_L26_R22: begin
          b_left <= 18;
          sack_n0[47:16] <= data;
        end
          OPT5_S0_L26_R18: begin
            b_left <= 14;
            sack_n0[15:0] <= {bytes[0], bytes[1]};
            sack_n1[63:48] <= {bytes[2], bytes[3]};
          end
          OPT5_S0_L26_R14: begin
            b_left <= 10;
            sack_n1[47:16] <= data;
          end
          OPT5_S0_L26_R10: begin
            b_left <= 6;
            sack_n1[15:0] <= {bytes[0], bytes[1]};
            sack_n2[63:48] <= {bytes[2], bytes[3]};
          end
          OPT5_S0_L26_R6: begin
            b_left <= 2;
            sack_n2[47:16] <= data;
          end
          OPT5_S0_L26_R2: begin
            b_left <= 0;
            sack_n2[15:0] <= {bytes[0], bytes[1]};
          end
          
        OPT5_S0_L34_R30: begin 
          b_left <= 26;
          sack_n0[47:16] <= data;
        end
          OPT5_S0_L34_R26: begin
            b_left <= 22;
            sack_n0[15:0] <= {bytes[0], bytes[1]};
            sack_n1[63:48] <= {bytes[2], bytes[3]};
          end
          OPT5_S0_L34_R22: begin
            b_left <= 18;
            sack_n1[47:16] <= data;
          end
          OPT5_S0_L34_R18: begin
            b_left <= 14;
            sack_n1[15:0] <= {bytes[0], bytes[1]};
            sack_n2[63:48] <= {bytes[2], bytes[3]};
          end
          OPT5_S0_L34_R14: begin
            b_left <= 10;
            sack_n2[47:16] <= data;
          end
          OPT5_S0_L34_R10: begin
            b_left <= 6;
            sack_n2[15:0] <= {bytes[0], bytes[1]};
            sack_n3[63:48] <= {bytes[2], bytes[3]};
          end
          OPT5_S0_L34_R6: begin
            b_left <= 2;
            sack_n3[47:16] <= data;
          end
          OPT5_S0_L34_R2: begin
            b_left <= 0;
            sack_n3[15:0] <= {bytes[0], bytes[1]};
          end
          
      OPT5_S1: begin
        option_av[5] <= 1;
        if (bytes[2] != 10 && bytes[2] != 18 && bytes[2] != 26 && bytes[2] != 34)
          option_err[5] <= 1;
        b_left <= bytes[2] - 4;
        sack_nbr <= (bytes[2] - 2) >> 3; // (n-2)/8 take integer result
        sack_n0[63:56] <= bytes[3];
      end
      
        OPT5_S1_L10_R7: begin
          b_left <= 3;
          sack_n0[55:24] <= data;
        end
          OPT5_S1_L10_R3: begin
            b_left <= 0;
            sack_n0[23:0] <= {bytes[0], bytes[1], bytes[2]};
          end
        
        OPT5_S1_L18_R15: begin
          b_left <= 11;
          sack_n0[55:24] <= data;
        end
          OPT5_S1_L18_R11: begin
            b_left <= 7;
            sack_n0[23:0] <= {bytes[0], bytes[1], bytes[2]};
            sack_n1[63:56] <= bytes[3];
          end
          OPT5_S1_L18_R7: begin
            b_left <= 3;
            sack_n1[55:24] <= data;
          end
          OPT5_S1_L18_R3: begin
            b_left <= 0;
            sack_n1[23:0] <= {bytes[0], bytes[1], bytes[2]};
          end
        
        OPT5_S1_L26_R23: begin
          b_left <= 19;
          sack_n0[55:24] <= data;
        end
          OPT5_S1_L26_R19: begin
            b_left <= 15;
            sack_n0[23:0] <= {bytes[0], bytes[1], bytes[2]};
            sack_n1[63:56] <= bytes[3];
          end
          OPT5_S1_L26_R15: begin
            b_left <= 11;
            sack_n1[55:24] <= data;
          end
          OPT5_S1_L26_R11: begin
            b_left <= 7;
            sack_n1[23:0] <= {bytes[0], bytes[1], bytes[2]};
            sack_n2[63:56] <= bytes[3];
          end
          OPT5_S1_L26_R7: begin
            b_left <= 3;
            sack_n2[55:24] <= data;
          end
          OPT5_S1_L26_R3: begin
            b_left <= 0;
            sack_n2[23:0] <= {bytes[0], bytes[1], bytes[2]};
          end
          
        OPT5_S1_L34_R31: begin 
          b_left <= 27;
          sack_n0[55:24] <= data;
        end
          OPT5_S1_L34_R27: begin
            b_left <= 23;
            sack_n0[23:0] <= {bytes[0], bytes[1], bytes[2]};
            sack_n1[63:56] <= bytes[3];
          end
          OPT5_S1_L34_R23: begin
            b_left <= 19;
            sack_n1[55:24] <= data;
          end
          OPT5_S1_L34_R19: begin
            b_left <= 15;
            sack_n1[23:0] <= {bytes[0], bytes[1], bytes[2]};
            sack_n2[63:56] <= bytes[3];
          end
          OPT5_S1_L34_R15: begin
            b_left <= 11;
            sack_n2[55:24] <= data;
          end
          OPT5_S1_L34_R11: begin
            b_left <= 7;
            sack_n2[23:0] <= {bytes[0], bytes[1], bytes[2]};
            sack_n3[63:56] <= bytes[3];
          end
          OPT5_S1_L34_R7: begin
            b_left <= 3;
            sack_n3[55:24] <= data;
          end
          OPT5_S1_L34_R3: begin
            b_left <= 0;
            sack_n3[23:0] <= {bytes[0], bytes[1], bytes[2]};
          end
      
      OPT5_S2: begin
        option_av[5] <= 1;
        if (bytes[3] != 10 && bytes[3] != 18 && bytes[3] != 26 && bytes[3] != 34)
          option_err[5] <= 1;
        b_left <= bytes[3] - 4;
        sack_nbr <= (bytes[3] - 2) >> 3; // (n-2)/8 take integer result
      end
        OPT5_S2_L10_R8: begin
          b_left <= 4;
          sack_n0[63:32] <= data;
        end
          OPT5_S2_L10_R4: begin
            b_left <= 0;
            sack_n0[31:0] <= data;
          end
          
        OPT5_S2_L18_R16: begin
          b_left <= 12;
          sack_n0[63:32] <= data;
        end
          OPT5_S2_L18_R12: begin
            b_left <= 8;
            sack_n0[31:0] <= data;
          end
          OPT5_S2_L18_R8: begin
            b_left <= 4;
            sack_n1[63:32] <= data;
          end
          OPT5_S2_L18_R4: begin
            b_left <= 0;
            sack_n1[31:0] <= data;
          end
          
        OPT5_S2_L26_R24: begin
          b_left <= 20;
          sack_n0[63:32] <= data;
        end
          OPT5_S2_L26_R20: begin
            b_left <= 16;
            sack_n0[31:0] <= data;
          end
          OPT5_S2_L26_R16: begin
            b_left <= 12;
            sack_n1[63:32] <= data;
          end
          OPT5_S2_L26_R12: begin
            b_left <= 8;
            sack_n1[31:0] <= data;
          end
          OPT5_S2_L26_R8: begin
            b_left <= 4;
            sack_n2[63:32] <= data;
          end
          OPT5_S2_L26_R4: begin
            b_left <= 0;
            sack_n2[31:0] <= data;
          end
          
        OPT5_S2_L34_R32: begin
          b_left <= 28;
          sack_n0[63:32] <= data;
        end
          OPT5_S2_L34_R28: begin
            b_left <= 24;
            sack_n0[31:0] <= data;
          end
          OPT5_S2_L34_R24: begin
            b_left <= 20;
            sack_n1[63:32] <= data;
          end
          OPT5_S2_L34_R20: begin
            b_left <= 16;
            sack_n1[31:0] <= data;
          end
          OPT5_S2_L34_R16: begin
            b_left <= 12;
            sack_n2[63:32] <= data;
          end
          OPT5_S2_L34_R12: begin
            b_left <= 8;
            sack_n2[31:0] <= data;
          end
          OPT5_S2_L34_R8: begin
            b_left <= 4;
            sack_n3[63:32] <= data;
          end
          OPT5_S2_L34_R4: begin
            b_left <= 0;
            sack_n2[31:0] <= data;
          end
      
      OPT5_S3: begin
        option_av[5] <= 1;
        b_left <= 1; // do this to prevent jumping out of OPT5* state
      end
      OPT5_S3_LN_RN: begin 
        if (bytes[0] != 10 && bytes[0] != 18 && bytes[0] != 26 && bytes[0] != 34)
          option_err[5] <= 1;
        b_left <= bytes[0] - 4;
        sack_nbr <= (bytes[0] - 2) >> 3; // (n-2)/8 take integer result
        sack_n0[63:40] <= {bytes[1], bytes[2], bytes[3]};
      end
      
        OPT5_S3_L10_R5: begin
          b_left <= 1;
          sack_n0[39:8] <= data;
        end
          OPT5_S3_L10_R1: begin
            b_left <= 0;
            sack_n0[7:0] <= bytes[0];
          end
        
        OPT5_S3_L18_R13: begin
          b_left <= 9;
          sack_n0[39:8] <= data;
        end
          OPT5_S3_L18_R9: begin
            b_left <= 5;
            sack_n0[7:0] <= bytes[0];
            sack_n1[63:40] <= {bytes[1], bytes[2], bytes[3]};
          end
          OPT5_S3_L18_R5: begin
            b_left <= 1;
            sack_n1[39:8] <= data;
          end
          OPT5_S3_L18_R1: begin
            b_left <= 0;
            sack_n1[7:0] <= bytes[0];
          end
          
        OPT5_S3_L26_R21: begin
          b_left <= 17;
          sack_n0[39:8] <= data;
        end
          OPT5_S3_L26_R17: begin
            b_left <= 13;
            sack_n0[7:0] <= bytes[0];
            sack_n1[63:40] <= {bytes[1], bytes[2], bytes[3]};
          end
          OPT5_S3_L26_R13: begin
            b_left <= 9;
            sack_n1[39:8] <= data;
          end
          OPT5_S3_L26_R9: begin
            b_left <= 5;
            sack_n1[7:0] <= bytes[0];
            sack_n2[63:40] <= {bytes[1], bytes[2], bytes[3]};
          end
          OPT5_S3_L26_R5: begin
            b_left <= 1;
            sack_n2[39:8] <= data;
          end
          OPT5_S3_L26_R1: begin
            b_left <= 0;
            sack_n2[7:0] <= bytes[0];
          end
        
        OPT5_S3_L34_R29: begin
          b_left <= 25;
          sack_n0[39:8] <= data;
        end
          OPT5_S3_L34_R25: begin
            b_left <= 21;
            sack_n0[7:0] <= bytes[0];
            sack_n1[63:40] <= {bytes[1], bytes[2], bytes[3]};
          end
          OPT5_S3_L34_R21: begin
            b_left <= 17;
            sack_n1[39:8] <= data;
          end
          OPT5_S3_L34_R17: begin
            b_left <= 13;
            sack_n1[7:0] <= bytes[0];
            sack_n2[63:40] <= {bytes[1], bytes[2], bytes[3]};
          end
          OPT5_S3_L34_R13: begin
            b_left <= 9;
            sack_n2[39:8] <= data;
          end
          OPT5_S3_L34_R9: begin
            b_left <= 5;
            sack_n2[7:0] <= bytes[0];
            sack_n3[63:40] <= {bytes[1], bytes[2], bytes[3]};
          end
          OPT5_S3_L34_R5: begin
            b_left <= 1;
            sack_n3[39:8] <= data;
          end
          OPT5_S3_L34_R1: begin
            b_left <= 0;
            sack_n3[7:0] <= {bytes[1], bytes[2], bytes[3]};
          end
    endcase
  end
  
endmodule


