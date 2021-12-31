module combine_decoder (data, start, clk, reset, 
                        version, IHL, type_of_ser, 
                        total_length, identification, flag, frag_offset,
                        time_to_live, protocol, src_ip, dest_ip,
                        len_ip_out, data_ip_out, wr_en_ip, ok_ip, fin_ip,
                        src_port_tcp, dest_port_tcp, seq_num, ack_num,
                        f_urg, f_ack, f_psh, f_rst, f_syn, f_fin, 
                        window, urg_ptr, option_av, mss, scale_wnd,
                        sack_nbr, sack_n0, sack_n1, sack_n2, sack_n3,
                        time_stp, option_err, len_tcp_data, data_tcp_out,
                        wr_en_tcp, ok_tcp, fin_tcp,
                        dest_port_udp, src_port_udp, len_udp_data, data_udp_out,
                        wr_en_udp, ok_udp, fin_udp, ok, fin);
  // IP Input Interface
  input [31:0] data;
  input start;
  input clk;
  input reset;
  
  // IP Output Interface
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
  
  output [15:0] len_ip_out;
  output [31:0] data_ip_out;
  output wr_en_ip;
  output ok_ip;
  output fin_ip;
  
  // TCP Output Interface
  output [15:0] src_port_tcp;
  output [15:0] dest_port_tcp;
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
    
  output [15:0] len_tcp_data;
  output [31:0] data_tcp_out;
  output wr_en_tcp;
  output ok_tcp;
  output fin_tcp;
  
  // UDP Output Interface
  output [15:0] dest_port_udp;
  output [15:0] src_port_udp;
  output [15:0] len_udp_data;
  output [31:0] data_udp_out;
  output wr_en_udp;
  output ok_udp;
  output fin_udp;
  
  // Combine Output Interface
  output ok;
  output fin;
  
  
  
  // Data type declaration - start
  wire [31:0] data;
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
  
  wire [15:0] len_ip_out;
  wire [31:0] data_ip_out;
  wire wr_en_ip;
  wire ok_ip;
  wire fin_ip;
  
  wire [15:0] src_port_tcp;
  wire [15:0] dest_port_tcp;
  wire [31:0] seq_num;
  wire [31:0] ack_num;
  wire f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  wire [15:0] window;
  wire [15:0] urg_ptr;
  
  wire [8:0] option_av;
    wire [15:0] mss; // option 2
    wire [7:0] scale_wnd; // option 3
    wire [2:0] sack_nbr; // option 5
      wire [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    wire [63:0] time_stp; // option 8
  wire [8:0] option_err;
    
  wire [15:0] len_tcp_data;
  wire [31:0] data_tcp_out;
  wire wr_en_tcp;
  wire ok_tcp;
  wire fin_tcp;

  wire [15:0] dest_port_udp;
  wire [15:0] src_port_udp;
  wire [15:0] len_udp_data;
  wire [31:0] data_udp_out;
  wire wr_en_udp;
  wire ok_udp;
  wire fin_udp;
  
  wire ok;
  wire fin;
  // Data type declaration - end
  
  
  // Combine output logic
  assign ok = ok_ip &&
              ((protocol == 8'd6) ? ok_tcp : 1) &&
              ((protocol == 8'd17) ? ok_udp : 1);
  assign fin = fin_ip &&
               ((protocol == 8'd6) ? fin_tcp : 1) &&
               ((protocol == 8'd17) ? fin_udp : 1);
  
  
  // Enable logic
  reg enable_tcp_rd, enable_udp_rd;
  always @(protocol or wr_en_ip) begin
    enable_udp_rd = 0;
    enable_tcp_rd = 0;
    if (wr_en_ip == 1) begin
      if (protocol == 8'd17) enable_udp_rd = 1;
      if (protocol == 8'd6) enable_tcp_rd = 1;
    end
  end
  
  
  IP_decoder ip_d 
  (.data(data), .start(start), .clk(clk), .reset(reset),
   .version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
   .total_length(total_length), .identification(identification), .flag(flag),
   .frag_offset(frag_offset), .time_to_live(time_to_live), 
   .protocol(protocol), .src_ip(src_ip), .dest_ip(dest_ip),
   .len_out(len_ip_out), .data_out(data_ip_out), 
   .wr_en(wr_en_ip), .ok(ok_ip), .fin(fin_ip));
                   
  TCP_decoder tcp_d 
  (.dest_ip(dest_ip), .src_ip(src_ip), .len_tcp(len_ip_out), .data(data_ip_out),
  .start(enable_tcp_rd), .clk(clk), .reset(reset),
  .src_port(src_port_tcp), .dest_port(dest_port_tcp), .seq_num(seq_num), .ack_num(ack_num),
  .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
  .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin), 
  .window(window), .urg_ptr(urg_ptr),
  .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd), .sack_nbr(sack_nbr),
  .sack_n0(sack_n0), .sack_n1(sack_n1), .sack_n2(sack_n2), .sack_n3(sack_n3), 
  .time_stp(time_stp), .option_err(option_err),
  .len_data(len_tcp_data), .data_tcp(data_tcp_out), .wr_en(wr_en_tcp), 
  .ok(ok_tcp), .fin(fin_tcp));
                    
  UDP_decoder udp_d 
  (.dest_ip(dest_ip), .src_ip(src_ip), .len_udp(len_ip_out), .data(data_ip_out), 
   .start(enable_udp_rd), .clk(clk), .reset(reset), 
   .dest_port(dest_port_udp), .src_port(src_port_udp), 
   .len_data(len_udp_data), .data_udp(data_udp_out),
   .wr_en(wr_en_udp), .ok(ok_udp), .fin(fin_udp));
  
endmodule
