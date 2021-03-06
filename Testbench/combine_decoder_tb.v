module combine_decoder_tb ();
  // IP Input Interface
  reg [31:0] data;
  reg start;
  reg clk;
  reg reset;
  
  // IP Output Interface
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
  
  // TCP Output Interface
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
  
  // UDP Output Interface
  wire [15:0] dest_port_udp;
  wire [15:0] src_port_udp;
  wire [15:0] len_udp_data;
  wire [31:0] data_udp_out;
  wire wr_en_udp;
  wire ok_udp;
  wire fin_udp;
  
  // Combine Output Interface
  wire ok;
  wire fin;
  
  
  // testbench reg
  reg [3:0] version_r;
  reg [3:0] IHL_r;
  reg [7:0] type_of_ser_r;
  reg [15:0] total_length_r;
  reg [15:0] identification_r;
  reg [2:0] flag_r;
  reg [12:0] frag_offset_r;
  reg [7:0] time_to_live_r;
  reg [7:0] protocol_r;
  reg [15:0] chksum_r;
  reg [31:0] src_ip_r;
  reg [31:0] dest_ip_r;
  
  reg [15:0] src_port_reg; // used for udp and tcp
  reg [15:0] dest_port_reg; // used for udp and tcp
  reg [31:0] seq_num_reg;
  reg [31:0] ack_num_reg;
  reg [3:0] data_offset_reg;
  reg f_urg_reg, f_ack_reg, f_psh_reg, f_rst_reg, f_syn_reg, f_fin_reg;
  reg [15:0] window_reg;
  reg [15:0] checksum_reg; // used for udp and tcp
  reg [15:0] urg_ptr_reg;
  reg [15:0] length_reg; // used for udp
  
  
  parameter package_data_length = 11;
  reg [8*package_data_length-1:0] package_data;
  
  
  
  
  initial begin
    clk = 0;
    
    
    load_new_package_data("Hello World");
    change_ip_header_value(4'd4, 4'd5, 8'd0, package_data_length + 40, // 28 for udp, 40 for tcp 
                           16'h1234, 3'b000, 13'h123, 8'h10, 6, // 6 for tcp, 17 for udp
                           16'hd5f8,  // d5f9 for udp, d5f8 for tcp
                           32'h9801_331b, 32'h980e_5e4b); 
    change_tcp_header_value('ha08f, 'h2694, 1, 2, 5, 6'b11_1111, 3, 'hd528, 4); // uncomment for tcp
    //change_udp_header_value('ha08f, 'h2694, package_data_length + 8, 'h2560); // uncomment for udp
    
    send_ip_data();
    send_tcp_data(); // uncomment for tcp
    //send_udp_data(); // uncomment for udp
    
    
    @(posedge fin);
    $finish;
  end
  
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    begin
      package_data = value;
    end
  endtask
  
  task change_ip_header_value;
    input [3:0] version_v;
    input [3:0] IHL_v;
    input [7:0] type_of_ser_v;
    input [15:0] total_length_v;
    input [15:0] identification_v;
    input [2:0] flag_v;
    input [12:0] frag_offset_v;
    input [7:0] time_to_live_v;
    input [7:0] protocol_v;
    input [15:0] chksum_v;
    input [31:0] src_ip_v;
    input [31:0] dest_ip_v;
    
    begin
      version_r = version_v;
      IHL_r = IHL_v;
      type_of_ser_r = type_of_ser_v;
      total_length_r = total_length_v;
      identification_r = identification_v;
      flag_r = flag_v;
      frag_offset_r = frag_offset_v;
      time_to_live_r = time_to_live_v;
      protocol_r = protocol_v;
      chksum_r = chksum_v;
      src_ip_r = src_ip_v;
      dest_ip_r = dest_ip_v;
      
      // printing IP header field value
      // version, IHL, type of service, total length, id, flags, frag offset,
      // time to live, protocol, checksum, source ip, dest ip
      $display("IP Header Fields' Values:");
      $display("Version:\t\t%1d\t\t%1h", version_r, version_r);
      $display("IHL:\t\t\t%1d\t\t%1h", IHL_r, IHL_r);
      $display("Type of Service:\t%1d\t\t%1h", type_of_ser_r, type_of_ser_r);
      $display("Total Length:\t\t%1d\t\t%1h", total_length_r, total_length_r);
      $display("Identification:\t\t%1d\t\t%1h", identification_r, identification_r);
      $display("Flags:\t\t\t%1d\t\t%1h", flag_r, flag_r);
      $display("Fragment Offset:\t%1d\t\t%1h", frag_offset_r, frag_offset_r);
      $display("Time to Live:\t\t%1d\t\t%1h", time_to_live_r, time_to_live_r);
      $display("Protocol:\t\t%1d\t\t%1h", protocol_r, protocol_r);
      $display("Header Checksum:\t%1d\t\t%1h", chksum_r, chksum_r);
      $display("Source IP:\t\t%1d.%1d.%1d.%1d\t%1h", src_ip_r[31:24], 
                                                     src_ip_r[23:16], 
                                                     src_ip_r[15:8], 
                                                     src_ip_r[7:0], 
                                                     src_ip_r);
      $display("Destination IP:\t\t%1d.%1d.%1d.%1d\t%1h", dest_ip_r[31:24], 
                                                          dest_ip_r[23:16], 
                                                          dest_ip_r[15:8], 
                                                          dest_ip_r[7:0],
                                                          dest_ip_r);
      $display(); // create a blank line
    end
  endtask
  
  task send_ip_data;
    begin
      reset = 1;
      @(negedge clk);
      reset = 0;
      start = 1;
      data = {version_r, IHL_r, type_of_ser_r, total_length_r};
      @(negedge clk);
      data = {identification_r, flag_r, frag_offset_r};
      @(negedge clk);
      data = {time_to_live_r, protocol_r, chksum_r};
      @(negedge clk);
      data = src_ip_r;
      @(negedge clk);
      data = dest_ip_r;
      @(negedge clk);
      repeat(IHL_r - 5) begin // option part, module will ignore this
        data = 32'd0;
        @(negedge clk);
      end
    end
  endtask
  
  task change_tcp_header_value;
    input [15:0] src_port_value, dest_port_value;
    input [31:0] seq_num_value, ack_num_value;
    input [3:0] data_offset_value;
    input [5:0] flag_value;
    input [15:0] window_value, checksum_value, urg_ptr_value;
    
    begin
      src_port_reg = src_port_value;
      dest_port_reg = dest_port_value;
      seq_num_reg = seq_num_value;
      ack_num_reg = ack_num_value;
      data_offset_reg = data_offset_value;
      {f_urg_reg, f_ack_reg, f_psh_reg, f_rst_reg, f_syn_reg, f_fin_reg} = flag_value;
      window_reg = window_value;
      checksum_reg = checksum_value;
      urg_ptr_reg = urg_ptr_value;
      
      // printing TCP header field value
      // source port, dest port, seq num, ack num, data offset, control bits, 
      // window, checksum, urgent pointer
      $display("TCP Header Fields' Values:");
      $display("Source Port:\t\t%1d\t\t%1h", src_port_value, src_port_value);
      $display("Destination Port:\t%1d\t\t%1h", dest_port_value, dest_port_value);
      $display("Seq Number:\t\t%1d\t\t%1h", seq_num_value, seq_num_value);
      $display("Ack Number:\t\t%1d\t\t%1h", ack_num_value, ack_num_value);
      $display("Data Offset:\t\t%1d\t\t%1h", data_offset_value, data_offset_value);
      $display("Control Bits:\t\t%1d\t\t%1h", flag_value, flag_value);
      $display("Window:\t\t\t%1d\t\t%1h", window_value, window_value);
      $display("Checksum:\t\t%1d\t\t%1h", checksum_value, checksum_value);
      $display("Urgent Pointer:\t\t%1d\t\t%1h", urg_ptr_value, urg_ptr_value);
      $display(); // create a blank line
    end
  endtask
  
  task send_tcp_data;
    begin
      data = {src_port_reg, dest_port_reg};
      @(negedge clk);
      start = 0;
      data = seq_num_reg;
      @(negedge clk);
      data = ack_num_reg;
      @(negedge clk);
      data = {data_offset_reg, 6'd0, 
             {f_urg_reg, f_ack_reg, f_psh_reg, f_rst_reg, f_syn_reg, f_fin_reg},
             window_reg};
      @(negedge clk);
      data = {checksum_reg, urg_ptr_reg};
      @(negedge clk);
      data = package_data[11*8-1:7*8];
      @(negedge clk);
      data = package_data[7*8-1:3*8];
      @(negedge clk);
      data = {package_data[3*8-1:0], 8'h00};
      @(negedge clk);
      start = 0;
    end
  endtask
  
  task change_udp_header_value;
    input [15:0] src_port_value, dest_port_value;
    input [15:0] length_value, checksum_value;
    
    begin
      src_port_reg = src_port_value;
      dest_port_reg = dest_port_value;
      length_reg = length_value;
      checksum_reg = checksum_value;
      
      // printing UDP header field value
      // source port, dest port, length, checksum
      $display("UDP Header Fields' Values:");
      $display("Source Port:\t\t%1d\t\t%1h", src_port_value, src_port_value);
      $display("Destination Port:\t%1d\t\t%1h", dest_port_value, dest_port_value);
      $display("Length:\t\t\t%1d\t\t%1h", dest_port_value, dest_port_value);
      $display("Checksum:\t\t%1d\t\t%1h", checksum_value, checksum_value);
      $display(); // create a blank line
    end
  endtask
  
  task send_udp_data;
    begin
      data = {src_port_reg, dest_port_reg};
      @(negedge clk);
      start = 0;
      data = {length_reg, checksum_reg};
      @(negedge clk);
      data = package_data[11*8-1:7*8];
      @(negedge clk);
      data = package_data[7*8-1:3*8];
      @(negedge clk);
      data = {package_data[3*8-1:0], 8'h00};
      @(negedge clk);
      start = 0;
    end
  endtask
  
  
  
  always
    #1 clk = ~clk;
  
  /*
  // use this to see combine module's output
  initial begin
    $display("  T\tc_ok\tc_fin\tok_ip\tok_tcp\tok_udp\tfin_ip\tfin_tcp\tfin_udp\tprotcl");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, ok, fin, dut.ok_ip, dut.ok_tcp, dut.ok_udp,
             dut.fin_ip, dut.fin_ip, dut.fin_ip,
             dut.protocol);
  end
  */
  
  
  // use this to see IP output
  initial begin
    $display("  T\td\t\tstart\tclk\trst\tver\tIHL\tTofSe\tlen\tid\tflag\tfr_os\tTtoL\tprtcl\tsip\t\tdip\t\tl_out\tdout\t\twr_en\tok\tfin");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
                    version, IHL, type_of_ser, total_length, identification, flag,
                    frag_offset, time_to_live, protocol, src_ip, dest_ip,
                    len_ip_out, data_ip_out, wr_en_ip, ok_ip, fin_ip,
                    dut.enable_tcp_rd, dut.enable_udp_rd);
  end
  
  
  /*
  // use this to see TCP output
  wire [5:0] flag_tcp;
  assign flag_tcp = {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin};
  initial begin
    $display("  T\tdata\t\tstr\tclk\trst\tsport\tdport\tsnum\t\tanum\t\tcbits\twnd\tu_ptr\tlen_tcp\tdata_tcp\twre_tcp\tok_tcp\tfin_tcp");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
             src_port_tcp, dest_port_tcp, seq_num, ack_num, 
             flag_tcp, window, urg_ptr, len_tcp_data, 
             data_tcp_out, wr_en_tcp, ok_tcp, fin_tcp,
             dut.tcp_d.complete_checksum);
  end
  */
  
  /*
  // use this to see UDP output
  initial begin
    $display("  T\tdip\t\tstr\tclk\trst\tdp_udp\tsp_udp\tlen_udp\td_udp\t\twre_dup\tok_udp\tfin_udp");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
             dest_port_udp, src_port_udp, len_udp_data, data_udp_out,
             wr_en_udp, ok_udp, fin_udp, dut.udp_d.complete_checksum);
  end
  */
  
  combine_decoder dut (.data(data), .start(start), .clk(clk), .reset(reset), 
                       .version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
                       .total_length(total_length), .identification(identification), 
                       .flag(flag), .frag_offset(frag_offset),
                       .time_to_live(time_to_live), .protocol(protocol), .src_ip(src_ip), .dest_ip(dest_ip),
                       .len_ip_out(len_ip_out), .data_ip_out(data_ip_out), 
                       .wr_en_ip(wr_en_ip), .ok_ip(ok_ip), .fin_ip(fin_ip),
                       .src_port_tcp(src_port_tcp), .dest_port_tcp(dest_port_tcp), 
                       .seq_num(seq_num), .ack_num(ack_num),
                       .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
                       .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin), 
                       .window(window), .urg_ptr(urg_ptr), .option_av(option_av), 
                       .mss(mss), .scale_wnd(scale_wnd),
                       .sack_nbr(sack_nbr), .sack_n0(sack_n0), .sack_n1(sack_n1), 
                       .sack_n2(sack_n2), .sack_n3(sack_n3),
                       .time_stp(time_stp), .option_err(option_err), 
                       .len_tcp_data(len_tcp_data), .data_tcp_out(data_tcp_out),
                       .wr_en_tcp(wr_en_tcp), .ok_tcp(ok_tcp), .fin_tcp(fin_tcp),
                       .dest_port_udp(dest_port_udp), .src_port_udp(src_port_udp), 
                       .len_udp_data(len_udp_data), .data_udp_out(data_udp_out),
                       .wr_en_udp(wr_en_udp), .ok_udp(ok_udp), .fin_udp(fin_udp), .ok(ok), .fin(fin));
  
endmodule
