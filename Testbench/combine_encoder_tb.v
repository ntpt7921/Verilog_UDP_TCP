module combine_encoder_tb ();
  // Combine Input
  reg [31:0] data;
  reg udp0_tcp1;
  reg clk, reset, start, data_av;
  
  // UDP Input
  reg [15:0] src_port_udp, dest_port_udp, len_in_udp;
  reg no_chksum_udp;
  
  // TCP Input
  reg [15:0] src_port_tcp, dest_port_tcp, len_in_tcp;
  reg [31:0] seq_num, ack_num;
  reg f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  reg [15:0] window;
  reg [15:0] urg_ptr;
  
  reg [8:0] option_av;
    reg [15:0] mss; // option 2
    reg [7:0] scale_wnd; // option 3
    reg [2:0] sack_nbr; // option 5
      reg [63:0] sack_n0, sack_n1, sack_n2, sack_n3; // option 5
    reg [63:0] time_stp; // option 8
  
  // IP Input
  reg [3:0] version;
  reg [3:0] IHL;
  reg [7:0] type_of_ser;
  reg [15:0] identification;
  reg [2:0] flag;
  reg [12:0] frag_offset;
  reg [7:0] time_to_live;
  reg [31:0] src_ip;
  reg [31:0] dest_ip;
  
  // Combine Output
  wire [31:0] pkg_data;
  wire wr_en;
  wire fin;
  
  
  parameter package_data_length = 11;
  reg [8*package_data_length-1:0] package_data;
  
  
  
  initial begin
    clk = 0;
    load_new_package_data("Hello World");
    change_ip_header_value(4'd4, 4'd5, 8'd0, 
                           16'h1234, 3'b010, 13'h0, 
                           8'h10, 
                           32'h9801_331b, 32'h980e_5e4b); 
                           
    change_tcp_header_value('ha08f, 'h2694, 
                            1, 2, 6'b11_0011, 3, 4,
                            9'b0_0000_0000, 5, 6, 7, 0, 8, 9, 10, 11,
                            package_data_length);
                            
    change_udp_header_value('ha08f, 'h2694, package_data_length, 0);
    
    
    // UDP checksum is 0x2560
    // TCP checksum without any option is 0xd528
    udp0_tcp1 = 1;
    start_test();
    
    @(posedge fin);
    $finish;
  end
  
  integer fout; // for file output
  initial begin
    fout = $fopen("combine_out.dump", "wb");
    @(posedge fin);
    $fclose(fout);
  end
  
  always @(posedge clk) begin
    if (wr_en == 1) begin
      $fwriteh(fout, "%u", {pkg_data[7:0], pkg_data[15:8], 
                            pkg_data[23:16], pkg_data[31:24]});
    end
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
    input [15:0] identification_v;
    input [2:0] flag_v;
    input [12:0] frag_offset_v;
    input [7:0] time_to_live_v;
    input [31:0] src_ip_v;
    input [31:0] dest_ip_v;
    
    begin
      version = version_v;
      IHL = IHL_v;
      type_of_ser = type_of_ser_v;
      identification = identification_v;
      flag = flag_v;
      frag_offset = frag_offset_v;
      time_to_live = time_to_live_v;
      src_ip = src_ip_v;
      dest_ip = dest_ip_v;
      
      // printing IP header field value
      // version, IHL, type of service, total length, id, flags, frag offset,
      // time to live, protocol, checksum, source ip, dest ip
      $display("IP Header Fields' Values:");
      $display("Version:\t\t%1d\t\t%1h", version, version);
      $display("IHL:\t\t\t%1d\t\t%1h", IHL, IHL);
      $display("Type of Service:\t%1d\t\t%1h", type_of_ser, type_of_ser);
      $display("Total Length:\t\t*\t\t*\t(Create by module)");
      $display("Identification:\t\t%1d\t\t%1h", identification, identification);
      $display("Flags:\t\t\t%1d\t\t%1h", flag, flag);
      $display("Fragment Offset:\t%1d\t\t%1h", frag_offset, frag_offset);
      $display("Time to Live:\t\t%1d\t\t%1h", time_to_live, time_to_live);
      $display("Protocol:\t\t*\t\t*\t(Create by module)");
      $display("Header Checksum:\t*\t\t*\t(Create by module)");
      $display("Source IP:\t\t%1d.%1d.%1d.%1d\t%1h", src_ip[31:24], 
                                                     src_ip[23:16], 
                                                     src_ip[15:8], 
                                                     src_ip[7:0], 
                                                     src_ip);
      $display("Destination IP:\t\t%1d.%1d.%1d.%1d\t%1h", dest_ip[31:24], 
                                                          dest_ip[23:16], 
                                                          dest_ip[15:8], 
                                                          dest_ip[7:0],
                                                          dest_ip);
      $display(); // create a blank line
    end
  endtask
  
  task change_tcp_header_value;
    input [15:0] src_port_value, dest_port_value;
    input [31:0] seq_num_value, ack_num_value;
    input [5:0] flag_value;
    input [15:0] window_value, urg_ptr_value;
    
    input [8:0] option_av_value;
      input [15:0] mss_value; // option 2
      input [7:0] scale_wnd_value; // option 3
      input [2:0] sack_nbr_value; // option 5
        input [63:0] sack_n0_value, sack_n1_value, sack_n2_value, sack_n3_value; // option 5
      input [63:0] time_stp_value; // option 8
    
    input [15:0] len_in_value;
    
    begin
      src_port_tcp = src_port_value;
      dest_port_tcp = dest_port_value;
      len_in_tcp = len_in_value;
      seq_num = seq_num_value;
      ack_num = ack_num_value;
      {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin} = flag_value;
      window = window_value;
      urg_ptr = urg_ptr_value;
      
      option_av = option_av_value;
      mss = mss_value; 
      scale_wnd = scale_wnd_value;
      sack_nbr = sack_nbr_value;
      sack_n0 = sack_n0_value;
      sack_n1 = sack_n1_value;
      sack_n2 = sack_n2_value;
      sack_n3 = sack_n3_value;
      time_stp = time_stp_value;
      
      // printing TCP header field value
      // source port, dest port, seq num, ack num, data offset, control bits, 
      // window, checksum, urgent pointer
      $display("TCP Header Fields' Values:");
      $display("Source Port:\t\t%1d\t\t%1h", src_port_tcp, src_port_tcp);
      $display("Destination Port:\t%1d\t\t%1h", dest_port_tcp, dest_port_tcp);
      $display("Seq Number:\t\t%1d\t\t%1h", seq_num, seq_num);
      $display("Ack Number:\t\t%1d\t\t%1h", ack_num, ack_num);
      $display("Data Offset:\t\t*\t\t*\t(Create by module)");
      $display("Control Bits:\t\t%1d\t\t%1h", flag_value, flag_value);
      $display("Window:\t\t\t%1d\t\t%1h", window, window);
      $display("Checksum:\t\t*\t\t*\t(Create by module)");
      $display("Urgent Pointer:\t\t%1d\t\t%1h", urg_ptr, urg_ptr);
      
      $display("Option 0:\t\t%1b", option_av[0]);
      $display("Option 1:\t\t%1b", option_av[1]);
      $display("Option 2:\t\t%1b\t\t%1h", option_av[2], mss);
      $display("Option 3:\t\t%1b\t\t%1h", option_av[3], scale_wnd);
      $display("Option 4:\t\t%1b", option_av[4]);
      $display("Option 8:\t\t%1b\t\t%1h", option_av[8], time_stp);
      $display("Option 5:\t\t%1b\t\t%1d", option_av[5], sack_nbr);
        $display("  SACK0:\t%1h", sack_n0);
        $display("  SACK1:\t%1h", sack_n1);
        $display("  SACK2:\t%1h", sack_n2);
        $display("  SACK3:\t%1h", sack_n3);

      $display(); // create a blank line
    end
  endtask
  
  task change_udp_header_value;
    input [15:0] sport_value, dport_value, len_udp_value, no_chks_value;
    
    begin
      src_port_udp = sport_value;
      dest_port_udp = dport_value;
      len_in_udp = len_udp_value;
      no_chksum_udp = no_chks_value;
      
      // printing UDP header field value
      // source port, dest port, length, checksum
      $display("UDP Header Fields' Values:");
      $display("Source Port:\t\t%1d\t\t%1h", src_port_udp, src_port_udp);
      $display("Destination Port:\t%1d\t\t%1h", dest_port_udp, dest_port_udp);
      $display("Length:\t\t\t*\t\t*\t(Create by module)");
      $display("Checksum:\t\t*\t\t*\t(Create by module)");
      $display(); // create a blank line
    end
  endtask
  
  task start_test;
    begin
      reset = 1;
      @(negedge clk);
      reset = 0;
      start = 1;
      data_av = 1;
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
    
  initial begin
    $display("  T\tdata\t\tclk\trst\tstr\td_av\tncs_udp\tu0_t1\tl_udp\tl_tcp\tpdata\t\twr_en\tfin");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, clk, reset, start, data_av, no_chksum_udp, udp0_tcp1,
                    len_in_udp, len_in_tcp, pkg_data, wr_en, fin,
                    dut.mux_data, dut.start_ip, dut.mux_data_av, dut.mux_chks);
  end
  
  
  combine_encoder dut (.data(data), .udp0_tcp1(udp0_tcp1), .clk(clk), 
                       .reset(reset), .start(start), .data_av(data_av),
                       .src_port_udp(src_port_udp), .dest_port_udp(dest_port_udp), 
                       .len_in_udp(len_in_udp), .no_chksum_udp(no_chksum_udp),
                       .src_port_tcp(src_port_tcp), .dest_port_tcp(dest_port_tcp), 
                       .len_in_tcp(len_in_tcp), .seq_num(seq_num), .ack_num(ack_num), 
                       .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
                       .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin),
                       .window(window), .urg_ptr(urg_ptr), .option_av(option_av), .mss(mss), 
                       .scale_wnd(scale_wnd), .sack_nbr(sack_nbr),
                       .sack_n0(sack_n0), .sack_n1(sack_n1), .sack_n2(sack_n2), 
                       .sack_n3(sack_n3), .time_stp(time_stp),
                       .version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
                       .identification(identification), .flag(flag), .frag_offset(frag_offset),
                       .time_to_live(time_to_live),
                       .src_ip(src_ip), .dest_ip(dest_ip), .pkg_data(pkg_data), 
                       .wr_en(wr_en), .fin(fin));
  
endmodule

