module TCP_encoder (src_port, dest_port, seq_num, ack_num, 
                    f_urg, f_ack, f_psh, f_rst, f_syn, f_fin,
                    window, urg_ptr, opt_word,
                    data, len, clk, reset, start, data_av,
                    pkg_data, checksum_out, wr_en, fin);
  input [15:0] src_port, dest_port;
  input [31:0] seq_num, ack_num;
  input f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  input [15:0] window;
  input [15:0] urg_ptr;
  input [3:0] opt_word;
  
  input [31:0] data;
  input [15:0] len;
  input clk, reset, start, data_av;

  output [31:0] pkg_data;
  output [15:0] checksum_out;
  output wr_en, fin;
  
  wire [15:0] src_port, dest_port;
  wire [31:0] seq_num, ack_num;
  wire f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  wire [15:0] window;
  wire [15:0] urg_ptr;
  wire [3:0] opt_word;
  
  wire [31:0] data;
  wire [15:0] len;
  wire clk, reset, start, data_av;

  reg [31:0] pkg_data;
  reg [15:0] checksum_out;
  reg wr_en, fin;
  
  
  wire data_av_dl;
  wire [31:0] data_dl;
  delay_reg #(.WIDTH(33), .DEPTH(5)) delay
  (.data_in({data_av, data}), .in_pos(8'd5), .data_out({data_av_dl, data_dl}), 
   .clk(clk), .reset(reset));
  
  
  
  wire [31:0] temp1, temp2, temp3, temp4;
  wire [31:0] data_opt_checksum;
  wire [15:0] accum_checksum, temp5, temp6;
  one_complement_adder #(.LENGTH(32)) add1 
  (.a1({src_port, dest_port}), .a2(seq_num), .res(temp1));
  one_complement_adder #(.LENGTH(32)) add2 
  (.a1(temp1), .a2(ack_num), .res(temp2));
  one_complement_adder #(.LENGTH(32)) add3 
  (.a1(temp2), .a2({data_offset, 6'd0, {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin}, window}), .res(temp3));
  one_complement_adder #(.LENGTH(32)) add4 
  (.a1(temp3), .a2({16'd0, urg_ptr}), .res(temp4));
  one_complement_adder #(.LENGTH(16)) add5 
  (.a1(temp4[31:16]), .a2(temp4[15:0]), .res(temp5));
  
  wire enable_checksum;
  assign enable_checksum = (next_state == WRITE_DATA || next_state == OPTION) && data_av_dl;
  checksum_calculator #(.LENGTH(32)) add6
  (.in(data_dl), .reset(reset), .enable(enable_checksum), 
   .clk(clk), .checksum(data_opt_checksum));
  
  one_complement_adder #(.LENGTH(16)) add7
  (.a1(data_opt_checksum[31:16]), .a2(data_opt_checksum[15:0]), .res(temp6));
  one_complement_adder #(.LENGTH(16)) add8
  (.a1(temp5), .a2(temp6), .res(accum_checksum));
  
  
  
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
      end
      WRITE_1: begin
        option_word_left <= opt_word;
        bytes_left <= len;
        data_offset <= opt_word + 5;
      end
      WRITE_2: /* do nothing */;
      WRITE_3: /* do nothing */;
      WRITE_4: /* do nothing */;
      WRITE_5: /* do nothing */;
      OPTION: 
        if (data_av_dl) 
          option_word_left <= option_word_left - 1;
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
        if (data_av_dl) begin
          pkg_data <= data_dl;
          wr_en <= 1;
        end else wr_en <= 0;
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
  
  
endmodule
