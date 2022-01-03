module UDP_decoder (dest_ip, src_ip, len_udp, data, 
                    start, clk, reset,
                    dest_port, src_port, len_data, data_udp, wr_en, ok, fin);
  input [31:0] dest_ip;
  input [31:0] src_ip;
  input [15:0] len_udp;
  input [31:0] data;
  input start;
  input clk;
  input reset;
  
  output [15:0] dest_port;
  output [15:0] src_port;
  output [15:0] len_data;
  output [31:0] data_udp;
  output wr_en;
  output ok;
  output fin;
  
  wire [31:0] dest_ip;
  wire [31:0] src_ip;
  wire [15:0] len_udp;
  wire [31:0] data;
  wire start;
  wire clk;
  wire reset;
  
  reg [15:0] dest_port;
  reg [15:0] src_port;
  reg [15:0] len_data;
  reg [31:0] data_udp;
  reg wr_en;
  wire ok;
  reg fin;
  
  
  
  wire [31:0] temp, pseudo_header_checksum, datagram_checksum, temp2;
  wire [15:0] complete_checksum;
  one_complement_adder #(.LENGTH(32)) add1 (.a1(dest_ip), .a2(src_ip), .res(temp));
  one_complement_adder #(.LENGTH(32)) add2 
  (.a1(temp), .a2({8'd0, 8'h11, len_udp}), .res(pseudo_header_checksum));
  
  wire enable_checksum;
  assign enable_checksum = !(next_state == IDLE || next_state == FIN);
  checksum_calculator #(.LENGTH(32)) add3
  (.in(data), .reset(reset), .enable(enable_checksum), 
   .clk(clk), .checksum(datagram_checksum));
  
  one_complement_adder #(.LENGTH(32)) add4 (.a1(pseudo_header_checksum), .a2(datagram_checksum), .res(temp2));
  one_complement_adder #(.LENGTH(16)) add5 (.a1(temp2[15:0]), .a2(temp2[31:16]), .res(complete_checksum));
  
  assign ok = fin && (no_checksum || complete_checksum == 16'hFFFF);
  
  
  
  parameter IDLE = 4'd0;
  parameter READ_1 = 4'd1;
  parameter READ_2 = 4'd2;
  parameter READ_3 = 4'd3;
  parameter FIN = 4'd4;
  
  reg [2:0] state, next_state;
  reg [15:0] bytes_left;
  reg no_checksum;
  
  always @(reset or start or state or bytes_left) begin
    if (reset)
      next_state = IDLE;
    else if (start && state == IDLE)
      next_state = READ_1;
    else if (state == READ_1)
      next_state = READ_2;
    else if (state == READ_2)
      next_state = READ_3;
    else if (state == READ_3)
      if (bytes_left == 0) next_state = FIN;
      else next_state = READ_3;
    else if (state == FIN) 
      next_state = FIN;
    else next_state = IDLE;
  end
  
  always @(posedge clk) begin
    state <= next_state;
    case (next_state)
      IDLE: begin
        bytes_left <= 0;
        no_checksum <= 0;
      end
      READ_1: bytes_left <= len_udp - 4;
      READ_2: begin
        bytes_left <= (bytes_left > 4) ? (bytes_left - 4) : 0;
        if (data[15:0] == 16'h0000) no_checksum <= 1;
      end
      READ_3: bytes_left <= (bytes_left > 4) ? (bytes_left - 4) : 0;
      FIN: /* do nothing */;
      default: bytes_left <= 0;
    endcase
  end
 
  always @(posedge clk) begin
    case (next_state)
      IDLE: begin
        dest_port <= 0;
        src_port <= 0;
        len_data <= 0;
        data_udp <= 0;
        wr_en <= 0;
        fin <= 0;
      end
      READ_1: begin
        src_port <= data[31:16];
        dest_port <= data[15:0];
      end
      READ_2: begin
        len_data <= data[31:16] - 8;
      end
      READ_3: begin
        data_udp <= data;
        wr_en <= 1;
      end
      FIN: begin
        data_udp <= 0;
        wr_en <= 0;
        fin <= 1;
      end
      default: begin
        dest_port <= 0;
        src_port <= 0;
        len_data <= 0;
        data_udp <= 0;
        wr_en <= 0;
        fin <= 0;
      end
    endcase
  end
endmodule


