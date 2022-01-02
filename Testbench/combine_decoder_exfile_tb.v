module combine_decoder_exfile_tb ();
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
  
  
  initial begin
    clk = 0;
    // read_combine_file will take care of its timing
    read_combine_file();
    
    $finish;
  end
  
  
  task read_combine_file;
    integer i;
    reg [31:0] memory_input [0:65535]; // 8 bit memory with 2^16-1 entries
    begin
      // wipe memory
      for (i = 0; i < 65536; i = i + 1)
        memory_input[i] = 32'hxxxx_xxxx;
      
      // read into memory from file
      $readmemh("combine_in_TCP.txt", memory_input);
      //$readmemh("combine_in_UDP.txt", memory_input);
      
      // reset and start to decode
      @(negedge clk);
      reset = 1;
      @(negedge clk);
      reset = 0;
      start = 1;
      
      // loop through memory for data read from file
      i = 0;
      while (memory_input[i] !== 32'hxxxx_xxxx) begin
        data = memory_input[i];
        i = i + 1;
        @(negedge clk);
      end
      start = 0;
      @(posedge fin);
      force clk = 0;
      #1;
      
      // printing IP header field value
      // version, IHL, type of service, total length, id, flags, frag offset,
      // time to live, protocol, checksum, source ip, dest ip
      $display("IP Header Fields' Values:");
      $display("Version:\t\t%1d\t\t%1h", version, version);
      $display("IHL:\t\t\t%1d\t\t%1h", IHL, IHL);
      $display("Type of Service:\t%1d\t\t%1h", type_of_ser, type_of_ser);
      $display("Total Length:\t\t%1d\t\t%1h", total_length, total_length);
      $display("Identification:\t\t%1d\t\t%1h", identification, identification);
      $display("Flags:\t\t\t%1d\t\t%1h", flag, flag);
      $display("Fragment Offset:\t%1d\t\t%1h", frag_offset, frag_offset);
      $display("Time to Live:\t\t%1d\t\t%1h", time_to_live, time_to_live);
      $display("Protocol:\t\t%1d\t\t%1h", protocol, protocol);
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
      
      
      // printing TCP header field value
      // source port, dest port, seq num, ack num, control bits, 
      // window, checksum, urgent pointer
      $display("TCP Header Fields' Values:");
      $display("Source Port:\t\t%1d\t\t%1h", src_port_tcp, src_port_tcp);
      $display("Destination Port:\t%1d\t\t%1h", dest_port_tcp, dest_port_tcp);
      $display("Seq Number:\t\t%1d\t\t%1h", seq_num, seq_num);
      $display("Ack Number:\t\t%1d\t\t%1h", ack_num, ack_num);
      $display("Control Bits:\t\t%1d\t\t%1h", 
               {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin}, 
               {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin});
      $display("Window:\t\t\t%1d\t\t%1h", window, window);
      $display("Urgent Pointer:\t\t%1d\t\t%1h", urg_ptr, urg_ptr);
      $display(); // create a blank line
      
       // printing TCP options value
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
      
      
      // printing UDP header field value
      // source port, dest port, length
      $display("UDP Header Fields' Values:");
      $display("Source Port:\t\t%1d\t\t%1h", src_port_udp, src_port_udp);
      $display("Destination Port:\t%1d\t\t%1h", dest_port_udp, dest_port_udp);
      $display("Length:\t\t\t%1d\t\t%1h", len_udp_data + 16'd8, len_udp_data + 16'd8); 
      // len_udp_data is the length of the message, +8 to get total UDP length
      $display(); // create a blank line
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
  
  /*
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
  */
  
  
  // use this to see TCP output
  wire [5:0] flag_tcp;
  assign flag_tcp = {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin};
  initial begin
    $display("  T\tdata\t\tstr\tclk\trst\tsport\tdport\tsnum\t\tanum\t\tcbits\twnd\tu_ptr\tl_tcp\tdata_tcp\twre_tcp\tok_tcp\tfin_tcp");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
             src_port_tcp, dest_port_tcp, seq_num, ack_num, 
             flag_tcp, window, urg_ptr, len_tcp_data, 
             data_tcp_out, wr_en_tcp, ok_tcp, fin_tcp,
             dut.tcp_d.complete_checksum);
  end
  
  
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
