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
  
  
  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;
  
  
  initial begin
    clk = 0;
    load_new_package_data("Hello World");
    change_ip_header_value(4'd4, 4'd5, 8'd0, 16'h1234, 
                           3'b000, 13'h123, 8'h10, 
                           32'h9801_331b, 32'h980e_5e4b); 
                           
    change_tcp_header_value('ha08f, 'h2694, package_data_length, 
                            1, 2, 6'b11_1111, 3, 4,
                            0, 0, 0, 0, 0, 0, 0, 0, 0);
                            
    change_udp_header_value('ha08f, 'h2694, package_data_length, 0);
    
    
    // UDP checksum is 0xe6fa
    // TCP checksum is 0xd528
    start_test();
    
    #44;
    $finish;
  end
  
  
   task load_new_package_data;
    input [8*package_data_length-1:0] value;
    package_data = value;
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
    
    version = version_v;
    IHL = IHL_v;
    type_of_ser = type_of_ser_v;
    identification = identification_v;
    flag = flag_v;
    frag_offset = frag_offset_v;
    time_to_live = time_to_live_v;
    src_ip = src_ip_v;
    dest_ip = dest_ip_v;
  endtask
  
  task change_tcp_header_value;
    input [15:0] src_port_value, dest_port_value, len_in_value;
    input [31:0] seq_num_value, ack_num_value;
    input [5:0] flag_value;
    input [15:0] window_value, urg_ptr_value;
    
    input [8:0] option_av_value;
      input [15:0] mss_value; // option 2
      input [7:0] scale_wnd_value; // option 3
      input [2:0] sack_nbr_value; // option 5
        input [63:0] sack_n0_value, sack_n1_value, sack_n2_value, sack_n3_value; // option 5
      input [63:0] time_stp_value; // option 8
    
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
    
  endtask
  
  task change_udp_header_value;
    input [15:0] sport_value, dport_value, len_udp_value, no_chks_value;
    src_port_udp = sport_value;
    dest_port_udp = dport_value;
    len_in_udp = len_udp_value;
    no_chksum_udp = no_chks_value;
  endtask
  
  task start_test;
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
    data_av = 1;
    udp0_tcp1 = 1;
    data = package_data[11*8-1:7*8];
    @(negedge clk);
    data = package_data[7*8-1:3*8];
    @(negedge clk);
    data = {package_data[3*8-1:0], 8'h00};
    @(negedge clk);
    start = 0;
  endtask
  
  
  always
    #1 clk = ~clk;
    
  initial begin
    $display("  T\tdata\t\tu0_t1\tclk\trst\tstr\td_av\tl_udp\tl_tcp\tpdata\t\twr_en\tfin");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h \t%h\t%h\t%h", 
             $time, data, udp0_tcp1, clk, reset, start, data_av,
                    len_in_udp, len_in_tcp, pkg_data, wr_en, fin,
                    dut.mux_data, dut.start_ip, dut.mux_data_av);
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

