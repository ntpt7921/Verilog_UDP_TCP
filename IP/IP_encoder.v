
module IP_encoder(version,IHL,type_of_ser,total_length,identification,flag,frag_offset,
time_to_live,protocol,checksum_out,src_ip,dest_ip,check,len_in,data,checksum_in,clk,
reset,start,data_av,pkg_data,len_out,wr_en,fin);

input [3:0] version;
input [3:0] IHL;
input [7:0] type_of_ser;
input [15:0] total_length;
input [15:0] identification;
input [2:0] flag;
input [12:0] frag_offset;
input [7:0] time_to_live;
input [7:0] protocol;
input [31:0] src_ip;
input [31:0] dest_ip;
input check;
 
input [15:0] len_in;
input [31:0] data;
input [15:0] checksum_in;


input clk, reset, start, data_av;

output [31:0] pkg_data;
output [15:0] checksum_out;
output [15:0] len_out;
assign len_out = len_in + 16'd20;
output wr_en, fin;

wire [31:0] data_in;
wire [15:0] len_in;
wire no_chksum;
wire start;
wire clk;
wire reset;
  
wire [3:0] version;
wire [3:0] IHL;
wire [7:0] type_of_ser;
wire [15:0] total_length;
wire [15:0] identification;
wire [2:0] flag;
wire [12:0] frag_offset;
wire [7:0] time_to_live;
wire [7:0] protocol;
wire [31:0] src_ip;
wire [31:0] dest_ip;
wire check;

reg [2:0]count;

wire [15:0] checksum_in;

reg [31:0] pkg_data;
reg [15:0] checksum_out;
wire [15:0] len_out;
// assign len_out = 
reg wr_en, fin;

 parameter IDLE = 4'd0;
 parameter WRITE_1 = 4'd1;
 parameter WRITE_2 = 4'd2;
 parameter WRITE_3 = 4'd3;
 parameter WRITE_4 = 4'd4;
 parameter WRITE_5 = 4'd5;
 parameter OPTION = 4'd6;
 parameter WRITE_DATA = 4'd7;
 parameter FIN = 4'd8;

wire data_av_dl;
wire [31:0] data_dl;
  delay_reg #(.WIDTH(33), .DEPTH(5)) delay
  (.data_in({data_av, data}), .in_pos(8'd5), .data_out({data_av_dl, data_dl}), 
   .clk(clk), .reset(reset));

  wire [31:0] temp1, temp2, temp3,temp4;
  wire [31:0] data_checksum;
  wire [15:0] accum_checksum;
  
  one_complement_adder #(.LENGTH(32)) add1 
  (.a1({version,IHL,type_of_ser,total_length}), .a2({identification,flag,frag_offset}), .res(temp1));
  one_complement_adder #(.LENGTH(32)) add2 
  (.a1(temp1), .a2({time_to_live,protocol,16'd0}), .res(temp2));
  one_complement_adder #(.LENGTH(32)) add3 
  (.a1(temp2), .a2(src_ip), .res(temp3));
  one_complement_adder #(.LENGTH(32)) add4 
  (.a1(temp3), .a2(dest_ip), .res(temp4));
  one_complement_adder #(.LENGTH(16)) add6 (.a1(temp4[31:16]), .a2(temp4[15:0]), .res(accum_checksum));

 reg [3:0] state, next_state;
 reg [15:0] bytes_left;
 reg [3:0] option_word_left;
 reg [3:0] data_offset;

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
    else if (state == WRITE_5)
       next_state = WRITE_DATA;  
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
      end
      WRITE_1: begin
        bytes_left <= len_in;
        // option_word_left 
      end
      WRITE_2: /* do nothing */;
      WRITE_3: /* do nothing */;
      WRITE_4: /* do nothing */;
      WRITE_5: /* do nothing */;
      OPTION:; //option_word_left /
      WRITE_DATA: if (data_av_dl) 
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
        count<=3'd0;
      end
      WRITE_1:begin
        pkg_data <= {version,IHL,type_of_ser,total_length};
    end
      WRITE_2:begin 
        pkg_data <={identification,flag,frag_offset};
    end    
      WRITE_3: begin
        pkg_data <={time_to_live,protocol,~accum_checksum};        
      end
      WRITE_4: begin
          pkg_data <= src_ip;
      end
      WRITE_5:begin
          pkg_data <= dest_ip;
      end
      OPTION:;
      WRITE_DATA:
      begin
        if(check == 1'b0) begin //UDP 
          if (data_av_dl) begin
            wr_en <= 1;
            count <= count + 1'b1;
            if(count == 3'd1) 
              pkg_data <= {data_dl[31:16],checksum_in};
            else 
              pkg_data <= data_dl;
          end else
              wr_en <= 0;
        end    
         if(check == 1'b1) begin
           if (data_av_dl) begin
            wr_en <= 1;
            count <= count + 1'b1;
            if(count == 3'd4) 
              pkg_data <= {checksum_in,data_dl[15:0]};
            else 
              pkg_data <= data_dl;
          end else
              wr_en <= 0;
        end      
      end
      FIN:begin
          pkg_data <= 0;
          wr_en <= 0;
          fin <= 1;
      end
      default: begin
        pkg_data <= 0;
        checksum_out <= 0;
        wr_en <= 0;
        fin <= 1;
        checksum_out <= ~accum_checksum;
      end
    endcase
  end

 
endmodule