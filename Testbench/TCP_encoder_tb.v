module TCP_encoder_tb ();
  reg [31:0] src_ip, dest_ip;
  reg [15:0] src_port, dest_port;
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
  
  reg [31:0] data;
  reg [15:0] len_in;
  reg clk, reset, start, data_av;

  wire [31:0] pkg_data;
  wire [15:0] checksum_out;
  wire [15:0] len_out;
  wire wr_en, fin;
  
  
  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;
  
  
  initial begin
    clk = 0;
    load_new_package_data("Hello World");
    len_in = package_data_length;
    
    change_ip_info(0, 0);
    change_tcp_header_info('ha08f, 'h2694, 1, 2, 6'b11_1111, 3, 4);
    change_tcp_option_info(9'b0_0000_0101, 16'h1234, 2, 
                           1, 64'h1111_1111_1111_1111, 0, 0, 0,
                           64'h1234_1234_1234_1234);
    
    send_tcp_data();
    //@(posedge fin);
    #20;
    $finish;  
  end
  
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    package_data = value;
  endtask
  
  task change_ip_info;
    input [31:0] src_ip_value, dest_ip_value;
    src_ip = src_ip_value;
    dest_ip = dest_ip_value;
    
    // printing IP pseduo header field value
    $display("IP Pseudo Header Fields' Values:");
    $display("Source IP:\t\t%1d.%1d.%1d.%1d\t\t%1h", src_ip[31:24], 
                                                   src_ip[23:16], 
                                                   src_ip[15:8], 
                                                   src_ip[7:0], 
                                                   src_ip);
    $display("Destination IP:\t\t%1d.%1d.%1d.%1d\t\t%1h", dest_ip[31:24], 
                                                        dest_ip[23:16], 
                                                        dest_ip[15:8], 
                                                        dest_ip[7:0],
                                                        dest_ip);
    $display(); // create a blank line
  endtask
  
  task change_tcp_header_info;
    input [15:0] src_port_value, dest_port_value;
    input [31:0] seq_num_value, ack_num_value;
    input [5:0] flag_value;
    input [15:0] window_value, urg_ptr_value;
    
    src_port = src_port_value;
    dest_port = dest_port_value;
    seq_num = seq_num_value;
    ack_num = ack_num_value;
    {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin} = flag_value;
    window = window_value;
    urg_ptr = urg_ptr_value;
    
    // printing TCP header field value
    // source port, dest port, seq num, ack num, data offset, control bits, 
    // window, checksum, urgent pointer
    $display("TCP Header Fields' Values:");
    $display("Source Port:\t\t%1d\t\t%1h", src_port, src_port);
    $display("Destination Port:\t%1d\t\t%1h", dest_port, dest_port);
    $display("Seq Number:\t\t%1d\t\t%1h", seq_num, seq_num);
    $display("Ack Number:\t\t%1d\t\t%1h", ack_num, ack_num);
    $display("Data Offset:\t\t*\t\t*\t(Create by module)");
    $display("Control Bits:\t\t%1d\t\t%1h", flag_value, flag_value);
    $display("Window:\t\t\t%1d\t\t%1h", window, window);
    $display("Checksum:\t\t*\t\t*\t(Create by module)");
    $display("Urgent Pointer:\t\t%1d\t\t%1h", urg_ptr, urg_ptr);
    $display(); // create a blank line
    
  endtask
  
  task change_tcp_option_info;
    input [8:0] option_av_v;
    input [15:0] mss_v; // option 2
    input [7:0] scale_wnd_v; // option 3
    input [2:0] sack_nbr_v; // option 5
    input [63:0] sack_n0_v, sack_n1_v, sack_n2_v, sack_n3_v; // option 5
    input [63:0] time_stp_v; // option 8
    option_av = option_av_v;
    mss = mss_v; // option 2
    scale_wnd = scale_wnd_v; // option 3
    sack_nbr = sack_nbr_v; // option 5
    sack_n0 = sack_n0_v; 
    sack_n1 = sack_n1_v; 
    sack_n2 = sack_n2_v;
    sack_n3 = sack_n3_v; // option 5
    time_stp = time_stp_v; // option 8
    
    // printing TCP options value
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
    
  endtask
  
  task send_tcp_data;
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
    data_av = 1; 
    data = package_data[11*8-1:7*8];
    @(negedge clk);
    start = 0;
    data_av = 0;
    data = package_data[7*8-1:3*8];
    @(negedge clk);
    data_av = 1;
    @(negedge clk);
    data = {package_data[3*8-1:0], 8'h00};
    @(negedge clk);
    start = 0;
    data_av = 0;
  endtask
  
  always
    #1 clk = ~clk;
 
  
  wire [5:0] flag;
  assign flag = {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin};
  initial begin
    $display("  T\tdata\t\tl_in\tclk\trst\tstr\td_av\tpkg_d\t\tchks\twr_en\tfin\tl_out");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, len_in, clk, reset, start, data_av,
                    pkg_data, checksum_out, wr_en, fin, len_out);
   // $dumpvars(0, UDP_decoder_tb);
  end
  
  TCP_encoder dut (.src_ip(src_ip), .dest_ip(dest_ip),
                   .src_port(src_port), .dest_port(dest_port), 
                   .seq_num(seq_num), .ack_num(ack_num), 
                   .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
                   .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin),
                   .window(window), .urg_ptr(urg_ptr),
                   .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd), .sack_nbr(sack_nbr),
                   .sack_n0(sack_n0), .sack_n1(sack_n1), .sack_n2(sack_n2), .sack_n3(sack_n3), 
                   .time_stp(time_stp), .data(data), .len_in(len_in), .clk(clk), .reset(reset), 
                   .start(start), .data_av(data_av), .pkg_data(pkg_data), 
                   .checksum_out(checksum_out), .len_out(len_out), .wr_en(wr_en), .fin(fin));
  
endmodule
