module TCP_encoder (src_ip, dest_ip,
                    src_port, dest_port, seq_num, ack_num, 
                    f_urg, f_ack, f_psh, f_rst, f_syn, f_fin,
                    window, urg_ptr,
                    option_av, mss, scale_wnd, sack_nbr,
                    sack_n0, sack_n1, sack_n2, sack_n3, time_stp,
                    data, len_in, clk, reset, start, data_av,
                    pkg_data, checksum_out, len_out, wr_en, fin);
  input [31:0] src_ip, dest_ip;
  input [15:0] src_port, dest_port;
  input [31:0] seq_num, ack_num;
  input f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  input [15:0] window;
  input [15:0] urg_ptr;
  
  input [8:0] option_av;
    input [15:0] mss; // option 2
    input [7:0] scale_wnd; // option 3
    input [2:0] sack_nbr; // option 5
      input [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    input [63:0] time_stp; // option 8
  
  input [31:0] data;
  input [15:0] len_in;
  input clk, reset, start, data_av;

  output [31:0] pkg_data;
  output [15:0] checksum_out;
  output [15:0] len_out;
  output wr_en, fin;
  
  wire [15:0] src_port, dest_port;
  wire [31:0] seq_num, ack_num;
  wire f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  wire [15:0] window;
  wire [15:0] urg_ptr;  
  
  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  
  wire [31:0] data;
  wire [15:0] len_in;
  wire clk, reset, start, data_av;

  reg [31:0] pkg_data;
  reg [15:0] checksum_out;
  wire [15:0] len_out;
  assign len_out = len_in + 16'd20 + ((opt_word <= 10) ? opt_word : 10) * 4;
  reg wr_en, fin;
  
  
  reg enable_opt_dc; // is set to true 2 clock cycle before entering state OPTION
  reg [4:0] opt_word;
  always @(option_av) begin
    opt_word = 0;
    if (option_av[2]) opt_word = opt_word + 1;
    if (option_av[3]) opt_word = opt_word + 1;
    if (option_av[4]) opt_word = opt_word + 1;
    if (option_av[8]) opt_word = opt_word + 3;
    if (option_av[5] && sack_nbr == 1) opt_word = opt_word + 3;
    if (option_av[5] && sack_nbr == 2) opt_word = opt_word + 5;
    if (option_av[5] && sack_nbr == 3) opt_word = opt_word + 7;
    if (option_av[5] && sack_nbr == 4) opt_word = opt_word + 9;
    if (option_av[0]) opt_word = opt_word + 1;
  end
  wire [31:0] data_option;
  TCP_option_encoder opt_dc (.enable(enable_opt_dc), .clk(clk), .reset(reset), 
                             .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd),
                             .sack_nbr(sack_nbr), .sack_n0(sack_n0), .sack_n1(sack_n1), 
                             .sack_n2(sack_n2), .sack_n3(sack_n3), .time_stp(time_stp), 
                             .data_option(data_option));
  
  wire [7:0] data_offset_value;
  assign data_offset_value = ((opt_word <= 10) ? opt_word : 10) + 5;
  wire data_av_dl;
  wire [31:0] data_dl;
  delay_reg #(.WIDTH(33), .DEPTH(15)) delay
  (.data_in({data_av, data}), .in_pos(data_offset_value), .data_out({data_av_dl, data_dl}), 
   .clk(clk), .reset(reset));
  
  
  
  parameter IDLE = 0;
  parameter WRITE_1 = 1;
  parameter WRITE_2 = 2;
  parameter WRITE_3 = 3;
  parameter WRITE_4 = 4;
  parameter WRITE_5 = 5;
  parameter OPTION = 6;
  parameter WRITE_DATA = 7;
  parameter FIN = 8;
  
  reg [3:0] state, next_state;
  reg [15:0] bytes_left;
  reg [3:0] data_offset;
  reg [3:0] option_word_left;
  
  always @(reset or start or state or bytes_left or option_word_left) begin
    if (reset)
      next_state = IDLE;
    else if (start && state == IDLE)
      next_state = WRITE_1;
    else if (state == WRITE_1)
      next_state = WRITE_2;
    else if (state == WRITE_2)
      next_state = WRITE_3;
    else if (state == WRITE_3)
      next_state = WRITE_4;
    else if (state == WRITE_4)
      next_state = WRITE_5;
    else if (state == WRITE_5 || state == OPTION)
      if (option_word_left == 0) next_state = WRITE_DATA;
      else next_state = OPTION;
    else if (state == WRITE_DATA)
      if (bytes_left == 0) next_state = FIN;
      else next_state = WRITE_DATA;
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
        enable_opt_dc <= 0;
      end
      WRITE_1: begin
        option_word_left <= (opt_word <= 10) ? opt_word : 10;
        bytes_left <= len_in;
        data_offset <= data_offset_value;
      end
      WRITE_2: /* do nothing */;
      WRITE_3: /* do nothing */;
      WRITE_4: enable_opt_dc <= 1;
      WRITE_5: /* do nothing */;
      OPTION: option_word_left <= option_word_left - 1;
      WRITE_DATA: 
        if (data_av_dl)  
          bytes_left <= (bytes_left > 3) ? (bytes_left - 4) : 0;
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
        pkg_data <= 0;
        checksum_out <= 0;
        wr_en <= 0;
        fin <= 0;
      end
      WRITE_1: begin
        wr_en <= 1;
        pkg_data <= {src_port, dest_port};
      end
      WRITE_2: begin
        pkg_data <= seq_num;
      end
      WRITE_3: begin
        pkg_data <= ack_num;
      end
      WRITE_4: begin
        pkg_data <= {data_offset, 6'd0, {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin}, window};
      end
      WRITE_5: begin
        pkg_data <= {16'd0, urg_ptr};
      end
      OPTION: begin
        if (option_word_left == 1)
          pkg_data <= {data_option[31:8], 8'd0};
        else pkg_data <= data_option;
      end
      WRITE_DATA: begin
        if (data_av_dl) begin
          pkg_data <= data_dl;
          wr_en <= 1;
        end else wr_en <= 0;
      end
      FIN: begin
        pkg_data <= 0;
        wr_en <= 0;
        fin <= 1;
        checksum_out <= ~accum_checksum;
      end
      default: begin
        pkg_data <= 0;
        checksum_out <= 0;
        wr_en <= 0;
        fin <= 0;
      end
    endcase
  end
  
  wire [31:0] temp1, temp2, temp3, temp4, temp9, temp10;
  wire [31:0] data_checksum, opt_checksum;
  wire [15:0] accum_checksum, hdr_chks, ps_hdr_chks, temp6, temp7, temp8, temp11;
  
  one_complement_adder #(.LENGTH(32)) add12
  (.a1(src_ip), .a2(dest_ip), .res(temp9));
  one_complement_adder #(.LENGTH(32)) add13
  (.a1(temp9), .a2({8'b0, 8'd6, len_out}), .res(temp10));
  one_complement_adder #(.LENGTH(16)) add14
  (.a1(temp10[31:16]), .a2(temp10[15:0]), .res(ps_hdr_chks));
  
  one_complement_adder #(.LENGTH(32)) add1 
  (.a1({src_port, dest_port}), .a2(seq_num), .res(temp1));
  one_complement_adder #(.LENGTH(32)) add2 
  (.a1(temp1), .a2(ack_num), .res(temp2));
  one_complement_adder #(.LENGTH(32)) add3 
  (.a1(temp2), .a2({data_offset, 6'd0, {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin}, window}), .res(temp3));
  one_complement_adder #(.LENGTH(32)) add4 
  (.a1(temp3), .a2({16'd0, urg_ptr}), .res(temp4));
  one_complement_adder #(.LENGTH(16)) add5 
  (.a1(temp4[31:16]), .a2(temp4[15:0]), .res(hdr_chks));
  
  wire enable_checksum_data;
  assign enable_checksum_data = (next_state == WRITE_DATA) && data_av_dl;
  checksum_calculator #(.LENGTH(32)) add6
  (.in(data_dl), .reset(reset), .enable(enable_checksum_data), 
   .clk(clk), .checksum(data_checksum));
   
  wire enable_checksum_option;
  assign enable_checksum_option = (next_state == OPTION);
  checksum_calculator #(.LENGTH(32)) add7
  (.in(data_option), .reset(reset), .enable(enable_checksum_option), 
   .clk(clk), .checksum(opt_checksum));
  
  one_complement_adder #(.LENGTH(16)) add8
  (.a1(data_checksum[31:16]), .a2(data_checksum[15:0]), .res(temp6));
  one_complement_adder #(.LENGTH(16)) add9
  (.a1(opt_checksum[31:16]), .a2(opt_checksum[15:0]), .res(temp7));
  one_complement_adder #(.LENGTH(16)) add10
  (.a1(temp6), .a2(temp7), .res(temp8));
  one_complement_adder #(.LENGTH(16)) add11
  (.a1(ps_hdr_chks), .a2(hdr_chks), .res(temp11));
  one_complement_adder #(.LENGTH(16)) add15
  (.a1(temp8), .a2(temp11), .res(accum_checksum));
  
endmodule
