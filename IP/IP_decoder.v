module IP_decoder (data, start, clk, reset,
                   version, IHL, type_of_ser, total_length, identification, flag,
                   frag_offset, time_to_live, protocol, src_ip, dest_ip,
                   len_out, data_out, wr_en, ok, fin);
  input [31:0] data;
  input start;
  input clk;
  input reset;
  
  output [3:0] version;
  output [3:0] IHL;
  output [7:0] type_of_ser;
  output [15:0] total_length;
  output [15:0] identification;
  output [2:0] flag;
  output [12:0] frag_offset;
  output [7:0] time_to_live;
  output [7:0] protocol;
  output [31:0] src_ip;
  output [31:0] dest_ip;
  
  output [15:0] len_out;
  output [31:0] data_out;
  output wr_en;
  output ok;
  output fin;
  
  
  wire [31:0] data;
  wire start;
  wire clk;
  wire reset;
  
  reg [3:0] version;
  reg [3:0] IHL;
  reg [7:0] type_of_ser;
  reg [15:0] total_length;
  reg [15:0] identification;
  reg [2:0] flag;
  reg [12:0] frag_offset;
  reg [7:0] time_to_live;
  reg [7:0] protocol;
  reg [31:0] src_ip;
  reg [31:0] dest_ip;
  
  reg [15:0] len_out;
  reg [31:0] data_out;
  reg wr_en;
  wire ok;
  reg fin;
  
  
  wire [31:0] head_chks32;
  wire [15:0] head_chks16;
  wire enable_checksum;
  assign enable_checksum = (next_state == READ_1 || next_state == READ_2 || 
                            next_state == READ_3 || next_state == READ_4 || 
                            next_state == READ_5 || next_state == OPTION );
  checksum_calculator #(.LENGTH(32)) add1
  (.in(data), .reset(reset), .enable(enable_checksum), 
   .clk(clk), .checksum(head_chks32));
  one_complement_adder #(.LENGTH(16)) add2   
  (.a1(head_chks32[31:16]), .a2(head_chks32[15:0]), .res(head_chks16));
  
  assign ok = fin && (head_chks16 == 16'hFFFF);
  
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
        option_word_left <= 0;
      end
      READ_1: begin
        bytes_left <= data[15:0] - 4 * data[27:24];
        option_word_left <= data[27:24] - 5;
      end
      READ_2: /* do nothing */;
      READ_3: /* do nothing */;
      READ_4: /* do nothing */;
      READ_5: /* do nothing */;
      OPTION: option_word_left <= option_word_left - 1;
      READ_DATA: bytes_left <= (bytes_left > 3) ? (bytes_left - 4) : 0;
      FIN: /* do nothing */;
      default: begin
        bytes_left <= 0;
        option_word_left <= 0;
      end
    endcase
  end
 
  always @(posedge clk) begin
    case (next_state)
      IDLE: begin
        version <= 0;
        IHL <= 0;
        type_of_ser <= 0;
        total_length <= 0;
        identification <= 0;
        flag <= 0;
        frag_offset <= 0;
        time_to_live <= 0;
        protocol <= 8'hFF;
        src_ip <= 0;
        dest_ip <= 0;
        len_out <= 0;
        wr_en <= 0;
        fin <= 0;
        data_out <= 0;
      end
      READ_1: begin
        version <= data[31:28];
        IHL <= data[27:24];
        type_of_ser <= data[23:16];
        total_length <= data[15:0];
        len_out <= data[15:0] - 4 * data[27:24];
      end
      READ_2: begin
        identification <= data[31:16];
        flag <= data[15:13];
        frag_offset <= data[12:0]; 
      end
      READ_3: begin
        time_to_live <= data[31:24];
        protocol <= data[23:16];
      end
      READ_4: begin
        src_ip <= data;
      end
      READ_5: begin
        dest_ip <= data;
      end
      OPTION: begin
        // do nothing to output, skip this part
      end
      READ_DATA: begin
        data_out <= data;
        wr_en <= 1;
      end
      FIN: begin
        data_out <= 0;
        wr_en <= 0;
        fin <= 1;
      end
      default: begin
        version <= 0;
        IHL <= 0;
        type_of_ser <= 0;
        total_length <= 0;
        identification <= 0;
        flag <= 0;
        frag_offset <= 0;
        time_to_live <= 0;
        protocol <= 8'hFF;
        src_ip <= 0;
        dest_ip <= 0;
        len_out <= 0;
        wr_en <= 0;
        fin <= 0;
        data_out <= 0;
      end
    endcase
  end

endmodule
