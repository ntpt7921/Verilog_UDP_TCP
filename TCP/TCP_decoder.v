module TCP_decoder (dest_ip, src_ip, len_tcp, data, start, clk, reset,
                    src_port, dest_port, seq_num, ack_num,
                    f_urg, f_ack, f_psh, f_rst, f_syn, f_fin, window, urg_ptr,
                    option_av, mss, scale_wnd, sack_nbr,
                    sack_n0, sack_n1, sack_n2, sack_n3, 
                    time_stp, option_err, len_data, data_tcp, wr_en, ok, fin);
  input [31:0] dest_ip;
  input [31:0] src_ip;
  input [15:0] len_tcp;
  input [31:0] data;
  input start;
  input clk;
  input reset;
  
  output [15:0] src_port;
  output [15:0] dest_port;
  output [31:0] seq_num;
  output [31:0] ack_num;
  output f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  output [15:0] window;
  output [15:0] urg_ptr;
  
  output [8:0] option_av;
    output [15:0] mss; // option 2
    output [7:0] scale_wnd; // option 3
    output [2:0] sack_nbr; // option 5
      output [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    output [63:0] time_stp; // option 8
  output [8:0] option_err;
    
  output [15:0] len_data;
  output [31:0] data_tcp;
  output wr_en;
  output ok;
  output fin;
  
  
  
  wire [31:0] dest_ip;
  wire [31:0] src_ip;
  wire [15:0] len_tcp;
  wire [31:0] data;
  wire start;
  wire clk;
  wire reset;
  
  reg [15:0] src_port;
  reg [15:0] dest_port;
  reg [31:0] seq_num;
  reg [31:0] ack_num;
  reg f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  reg [15:0] window;
  reg [15:0] urg_ptr;
  
  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  wire [8:0] option_err;
    
  reg [15:0] len_data;
  reg [31:0] data_tcp;
  reg wr_en;
  wire ok;
  reg fin;
  
  
  wire [31:0] pseudo_header_checksum, segment_checksum, temp, temp2;
  wire [15:0] complete_checksum;
  one_complement_adder #(.LENGTH(32)) add1 (.a1(dest_ip), .a2(src_ip), .res(temp));
  one_complement_adder #(.LENGTH(32)) add2 
  (.a1(temp), .a2({8'd0, 8'd6, len_tcp}), .res(pseudo_header_checksum));
  
  wire enable_checksum;
  assign enable_checksum = !(next_state == IDLE || next_state == FIN);
  checksum_calculator #(.LENGTH(32)) add3
  (.in(data), .reset(reset), .enable(enable_checksum), 
   .clk(clk), .checksum(segment_checksum));
  
  one_complement_adder #(.LENGTH(32)) add4 (.a1(pseudo_header_checksum), .a2(segment_checksum), .res(temp2));
  one_complement_adder #(.LENGTH(16)) add5 (.a1(temp2[15:0]), .a2(temp2[31:16]), .res(complete_checksum));
  
  
  wire opt_decoder_clk;
  assign opt_decoder_clk = ((next_state == OPTION && !option_av[0]) || reset) ? clk : 0;
  TCP_option_decoder dut (.data(data), .clk(opt_decoder_clk), .reset(reset),
                          .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd),
                          .sack_nbr(sack_nbr), .sack_n0(sack_n0), .sack_n1(sack_n1), 
                          .sack_n2(sack_n2), .sack_n3(sack_n3), 
                          .time_stp(time_stp), .option_err(option_err));
  
  
  assign ok = fin && (complete_checksum == 16'hFFFF) && (~| option_err);
  
  
  parameter IDLE = 4'd0;
  parameter READ_1 = 4'd1;
  parameter READ_2 = 4'd2;
  parameter READ_3 = 4'd3;
  parameter READ_4 = 4'd4;
  parameter READ_5 = 4'd5;
  parameter OPTION = 4'd6;
  parameter READ_DATA = 4'd7;
  parameter FIN = 4'd8;
  
  reg [3:0] state, next_state;
  reg [15:0] bytes_left;
  reg [3:0] data_offset;
  reg [3:0] option_word_left;
  
  always @(reset or start or state or bytes_left or option_word_left) begin
    if (reset)
      next_state = IDLE;
    else if (start && state == IDLE)
      next_state = READ_1;
    else if (state == READ_1)
      next_state = READ_2;
    else if (state == READ_2)
      next_state = READ_3;
    else if (state == READ_3)
      next_state = READ_4;
    else if (state == READ_4)
      next_state = READ_5;
    else if (state == READ_5 || state == OPTION)
      if (option_word_left == 0) next_state = READ_DATA;
      else next_state = OPTION;
    else if (state == READ_DATA)
      if (bytes_left == 0) next_state = FIN;
      else next_state = READ_DATA;
    else if (state == FIN) 
      next_state = FIN;
    else next_state = IDLE;
  end
  
  always @(posedge clk) begin
    state <= next_state;
    case (next_state)
      IDLE: begin
        bytes_left <= 0;
        data_offset <= 0;
        option_word_left <= 0;
      end
      READ_1: /* do nothing */;
      READ_2: /* do nothing */;
      READ_3: /* do nothing */;
      READ_4: begin
        data_offset <= data[31:28];
        option_word_left <= data[31:28] - 5;
        bytes_left <= len_tcp - 4 * data[31:28];
      end
      READ_5: /* do nothing */;
      OPTION: option_word_left <= option_word_left - 1;
      READ_DATA: bytes_left <= (bytes_left > 3) ? (bytes_left - 4) : 0;
      FIN: /* do nothing */;
      default: begin
        bytes_left <= 0;
        data_offset <= 0;
        option_word_left <= 0;
      end
    endcase
  end
 
  always @(posedge clk) begin
    case (next_state)
      IDLE: begin
        src_port <= 0;
        dest_port <= 0;
        seq_num <= 0;
        ack_num <= 0;
        f_urg <= 0;
        f_ack <= 0; 
        f_psh <= 0;
        f_rst <= 0;
        f_syn <= 0;
        f_fin <= 0;
        window <= 0;
        urg_ptr <= 0;
        len_data <= 0;
        data_tcp <= 0;
        wr_en <= 0;
        fin <= 0;
      end
      READ_1: begin
        src_port <= data[31:16];
        dest_port <= data[15:0];
      end
      READ_2: begin
        seq_num <= data;
      end
      READ_3: begin
        ack_num <= data;
      end
      READ_4: begin
        {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin} <= data[21:16];
        window <= data[15:0];
      end
      READ_5: begin
        urg_ptr <= data[15:0];
      end
      OPTION: begin
        // do nothing to output
      end
      READ_DATA: begin
        data_tcp <= data;
        wr_en <= 1;
      end
      FIN: begin
        len_data <= len_tcp - 4*data_offset;
        data_tcp <= 0;
        wr_en <= 0;
        fin <= 1;
      end
      default: begin
        src_port <= 0;
        dest_port <= 0;
        seq_num <= 0;
        ack_num <= 0;
        f_urg <= 0;
        f_ack <= 0; 
        f_psh <= 0;
        f_rst <= 0;
        f_syn <= 0;
        f_fin <= 0;
        window <= 0;
        urg_ptr <= 0;
        len_data <= 0;
        data_tcp <= 0;
        wr_en <= 0;
        fin <= 0;
      end
    endcase
  end
endmodule
