module combine_encoder (data, udp0_tcp1, clk, reset, start, data_av,
                        src_port_udp, dest_port_udp, len_in_udp, no_chksum_udp,
                        src_port_tcp, dest_port_tcp, len_in_tcp,
                        seq_num, ack_num, f_urg, f_ack, f_psh, f_rst, f_syn, f_fin,
                        window, urg_ptr, option_av, mss, scale_wnd, sack_nbr,
                        sack_n0, sack_n1, sack_n2, sack_n3, time_stp,
                        version, IHL, type_of_ser, identification, flag, frag_offset,
                        time_to_live, src_ip, dest_ip, pkg_data, wr_en, fin);
  // Combine Input
  input [31:0] data;
  input udp0_tcp1;
  input clk, reset, start, data_av;
  
  // UDP Input
  input [15:0] src_port_udp, dest_port_udp, len_in_udp;
  input no_chksum_udp;
  
  // TCP Input
  input [15:0] src_port_tcp, dest_port_tcp, len_in_tcp;
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
  
  // IP Input
  input [3:0] version;
  input [3:0] IHL;
  input [7:0] type_of_ser;
  input [15:0] identification;
  input [2:0] flag;
  input [12:0] frag_offset;
  input [7:0] time_to_live;
  input [31:0] src_ip;
  input [31:0] dest_ip;
  
  // Combine output
  output [31:0] pkg_data;
  output wr_en;
  output fin;
  
  
  
  // Data type declaration - start
  wire [31:0] data;
  wire udp0_tcp1;
  wire clk, reset, start, data_av;
  
  wire [15:0] src_port_udp, dest_port_udp, len_in_udp;
  wire no_chksum_udp;
  
  wire [31:0] pkg_data_udp;
  wire [15:0] checksum_out_udp;
  wire [15:0] len_out_udp;
  wire wr_en_udp, fin_udp;
  
  wire [15:0] src_port_tcp, dest_port_tcp, len_in_tcp;
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
  
  wire [31:0] pkg_data_tcp;
  wire [15:0] checksum_out_tcp;
  wire [15:0] len_out_tcp;
  wire wr_en_tcp, fin_tcp;
  
  wire [15:0] len_in_ip;
  wire [15:0] checksum_in_ip;
  
  wire [3:0] version;
  wire [3:0] IHL;
  wire [7:0] type_of_ser;
  wire [15:0] identification;
  wire [2:0] flag;
  wire [12:0] frag_offset;
  wire [7:0] time_to_live;
  wire [7:0] protocol;
  wire [31:0] src_ip;
  wire [31:0] dest_ip;
  
  wire [31:0] pkg_data_ip;
  wire [15:0] len_out_ip;
  wire wr_en_ip;
  wire fin_ip;
  
  wire wr_en;
  wire fin;
  wire [31:0] pkg_data;
  // Data type declaration - start
  
  assign protocol = (udp0_tcp1 == 0) ? 17 :
                    (udp0_tcp1 == 1) ? 6 : 0;
  assign wr_en = wr_en_ip; // may change later
  assign fin = fin_ip; // may change later
  assign pkg_data = pkg_data_ip; // may change later
  
  
  // Start signal for for UDP and TCP module
  wire start_tcp, start_udp;
  assign start_udp = (udp0_tcp1 == 0) && start;
  assign start_tcp = (udp0_tcp1 == 1) && start;
  
  
  
  // UDP encoder
  UDP_encoder udp_e (.src_ip(src_ip), .dest_ip(dest_ip),
                     .src_port(src_port_udp), .dest_port(dest_port_udp), .len_in(len_in_udp), 
                     .data(data), .clk(clk), .reset(reset), .no_chksum(no_chksum_udp), 
                     .start(start_udp), .data_av(data_av), .pkg_data(pkg_data_udp), .wr_en(wr_en_udp), 
                     .fin(fin_udp), .checksum_out(checksum_out_udp), .len_out(len_out_udp));
  // UDP buffer mem
  wire [31:0] data_out_udp;
  wire rd_en_udp; // set within the Logic & Multiplex part
  wire data_av_udp;
  
  buffer_memory_auto_addr udp_buff_mem (.data_in(pkg_data_udp), .rd_en(rd_en_udp), 
                                        .wr_en(wr_en_udp), .clk(clk), .reset(reset), 
                                        .data_out(data_out_udp), .data_av(data_av_udp));
  
  
  // TCP encoder
  TCP_encoder tcp_e (.src_ip(src_ip), .dest_ip(dest_ip),
                     .src_port(src_port_tcp), .dest_port(dest_port_tcp), 
                     .seq_num(seq_num), .ack_num(ack_num), 
                     .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
                     .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin),
                     .window(window), .urg_ptr(urg_ptr),
                     .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd), .sack_nbr(sack_nbr),
                     .sack_n0(sack_n0), .sack_n1(sack_n1), .sack_n2(sack_n2), .sack_n3(sack_n3), 
                     .time_stp(time_stp), .data(data), .len_in(len_in_tcp), .clk(clk), .reset(reset), 
                     .start(start_tcp), .data_av(data_av), .pkg_data(pkg_data_tcp), 
                     .checksum_out(checksum_out_tcp), .len_out(len_out_tcp), 
                     .wr_en(wr_en_tcp), .fin(fin_tcp));
  // TCP buffer memory
  wire [31:0] data_out_tcp;
  wire rd_en_tcp; // set within the Logic & Multiplex part
  wire data_av_tcp;
  
  buffer_memory_auto_addr tcp_buff_mem (.data_in(pkg_data_tcp), .rd_en(rd_en_tcp), 
                                        .wr_en(wr_en_tcp), .clk(clk), .reset(reset), 
                                        .data_out(data_out_tcp), .data_av(data_av_tcp));
  
  
  // Logic & Multiplex part - start
  reg [31:0] mux_data;
  reg [15:0] mux_chks, mux_len;
  reg mux_data_av;
  
  always @(*) begin
    if (udp0_tcp1 == 0) begin
      mux_data = data_out_udp;
      mux_chks = checksum_out_udp;
      mux_len = len_out_udp;
      mux_data_av = data_av_udp;
    end else begin
      mux_data = data_out_tcp;
      mux_chks = checksum_out_tcp;
      mux_len = len_out_tcp;
      mux_data_av = data_av_tcp;
    end
  end
  
  assign rd_en_udp = fin_udp;
  assign rd_en_tcp = fin_tcp;
  
  parameter IDLE = 0;
  parameter READ_BUF_FIRST_WORD = 1;
  parameter READ_THE_REST = 2;
  reg [1:0] state, next_state;
  reg start_ip;
  
  always @(fin_udp or fin_tcp or reset) begin
    if (reset) next_state = IDLE;
    else if (state == IDLE && (fin_udp || fin_tcp)) next_state = READ_BUF_FIRST_WORD;
    else if (state == READ_BUF_FIRST_WORD) next_state = READ_THE_REST;
    else if (state == READ_THE_REST) next_state = READ_THE_REST;
    else next_state = IDLE; 
  end
  
  always @(posedge clk) begin
    state <= next_state;
    case (next_state)
      IDLE: start_ip <= 0;
      READ_BUF_FIRST_WORD: start_ip <= 1;
      READ_THE_REST: start_ip <= 1;
      default: start_ip <= 0;
    endcase
  end
  
  // Logic & Multiplex part - end
  
  
  // IP encoder
  IP_encoder dut (.data(mux_data), .len_in(mux_len), .checksum_in(mux_chks), .check(udp0_tcp1),
                  .clk(clk), .reset(reset), .start(start_ip), .data_av(mux_data_av),
                  .version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
                  .identification(identification), .flag(flag), .frag_offset(frag_offset), 
                  .time_to_live(time_to_live), .protocol(protocol), .src_ip(src_ip), 
                  .dest_ip(dest_ip), .pkg_data(pkg_data_ip), .wr_en(wr_en_ip), .fin(fin_ip),
                  .len_out(len_out_ip));
  
  
  
endmodule
