module UDP_encoder (src_ip, dest_ip,
                    src_port, dest_port, len_in, data,
                    clk, reset, no_chksum, start, data_av,
                    pkg_data, wr_en, fin, checksum_out, len_out);

  input [31:0] src_ip, dest_ip;
  input [15:0] src_port, dest_port, len_in;
  input [31:0] data;
  input clk, reset, no_chksum, start, data_av;

  output [31:0] pkg_data;
  output [15:0] checksum_out;
  output [15:0] len_out;
  output wr_en, fin;


  wire [15:0] src_port, dest_port, len_in;
  wire [31:0] data;
  wire clk, reset, no_chksum, start, data_av;

  reg [31:0] pkg_data;
  reg [15:0] checksum_out;
  wire [15:0] len_out;
  assign len_out = len_in + 16'd8;
  reg wr_en, fin;

  parameter IDLE = 0;
  parameter WRITE_1 = 1;
  parameter WRITE_2 = 2;
  parameter WRITE_DATA = 3;
  parameter FIN = 4;
  
  
  wire data_av_dl;
  wire [31:0] data_dl;
  delay_reg #(.WIDTH(33), .DEPTH(2)) delay
  (.data_in({data_av, data}), .in_pos(8'd2), .data_out({data_av_dl, data_dl}), 
   .clk(clk), .reset(reset));
   
   
  wire [31:0] temp0;
  wire [15:0] temp1, temp2, ps_hdr_chks;
  one_complement_adder #(.LENGTH(32)) add0 (.a1(src_ip), .a2(dest_ip), .res(temp0));
  one_complement_adder #(.LENGTH(16)) add1 (.a1({8'b0, 8'd17}), .a2(len_out), .res(temp1));
  one_complement_adder #(.LENGTH(16)) add2 (.a1(temp0[31:16]), .a2(temp0[15:0]), .res(temp2));
  one_complement_adder #(.LENGTH(16)) add3 (.a1(temp1), .a2(temp2), .res(ps_hdr_chks));
  
  wire [15:0] temp3, hdr_chks;
  one_complement_adder #(.LENGTH(16)) add4 (.a1(src_port), .a2(dest_port), .res(temp3));
  one_complement_adder #(.LENGTH(16)) add5 (.a1(temp3), .a2(len_out), .res(hdr_chks));
  
  wire [31:0] data_checksum;
  wire enable_checksum;
  assign enable_checksum = (next_state == WRITE_DATA) && data_av_dl;
  checksum_calculator #(.LENGTH(32)) add6
  (.in(data_dl), .reset(reset), .enable(enable_checksum), 
   .clk(clk), .checksum(data_checksum));
  
  wire [15:0] accum_checksum, temp4, temp5;
  one_complement_adder #(.LENGTH(16)) add7 
  (.a1(data_checksum[31:16]), .a2(data_checksum[15:0]), .res(temp4));
  one_complement_adder #(.LENGTH(16)) add8 
  (.a1(ps_hdr_chks), .a2(hdr_chks), .res(temp5));
  one_complement_adder #(.LENGTH(16)) add9
  (.a1(temp4), .a2(temp5), .res(accum_checksum));
  
  
  reg [2:0] state, next_state;
  reg [15:0] bytes_left;
  
  always @(reset or start or state or bytes_left) begin
    if (reset) 
      next_state = IDLE;
    else if (start && state == IDLE)
      next_state = WRITE_1;
    else if (state == WRITE_1)
      next_state = WRITE_2;
    else if (state == WRITE_2)
      next_state = WRITE_DATA;
    else if (state == WRITE_DATA) begin
      if (bytes_left > 0) next_state = WRITE_DATA;
      else next_state = FIN;
    end else if (state == FIN) 
      next_state = FIN;
    else next_state = IDLE;
  end

  always @(posedge clk) begin
    state <= next_state;
    case (next_state)
      IDLE: bytes_left <= 0;
      WRITE_1: bytes_left <= len_in;
      WRITE_2: /* do nohting */;
      WRITE_DATA: 
        if (data_av_dl) 
          bytes_left <= (bytes_left < 4) ? 0 : (bytes_left - 4);
      FIN: /* do nothing */;
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
        pkg_data <= {src_port, dest_port};
        wr_en <= 1;
      end
      WRITE_2: begin
        pkg_data <= {len_out, 16'h0000};
      end
      WRITE_DATA: begin
        if (data_av_dl) begin
          wr_en <= 1;
          pkg_data <= data_dl;
        end else
          wr_en <= 0;
      end
      FIN: begin
        pkg_data <= 0;
        if (!no_chksum) checksum_out <= ~accum_checksum;
        else checksum_out <= 0;
        wr_en <= 0;
        fin <= 1;
      end
    endcase
  end

endmodule



























