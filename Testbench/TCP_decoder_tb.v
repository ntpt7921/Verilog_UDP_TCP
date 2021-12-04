module TCP_decoder_tb ();
  reg [31:0] dest_ip;
  reg [31:0] src_ip;
  reg [15:0] len_tcp;
  reg [31:0] data;
  reg start;
  reg clk;
  reg reset;
  
  wire [15:0] src_port;
  wire [15:0] dest_port;
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
    
  wire [15:0] len_data;
  wire [31:0] data_tcp;
  wire wr_en;
  wire ok;
  wire fin;
  
  
  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;
  
  reg [15:0] src_port_reg;
  reg [15:0] dest_port_reg;
  reg [31:0] seq_num_reg;
  reg [31:0] ack_num_reg;
  reg [3:0] data_offset_reg;
  reg f_urg_reg, f_ack_reg, f_psh_reg, f_rst_reg, f_syn_reg, f_fin_reg;
  reg [15:0] window_reg;
  reg [15:0] checksum_reg;
  reg [15:0] urg_ptr_reg;
  
  initial begin
    clk = 0;
    change_ip_info('h9801_331b, 'h980e_5e4b, package_data_length + 6*4);
    change_tcp_header_info('ha08f, 'h2694, 1, 2, 6, 6'b11_1111, 3, 'hb0ec, 4);
    load_new_package_data("Hello World");
    send_tcp_data();
    #4;
    $finish;  
  end
  
  
  task send_tcp_data;
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
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
    data = 32'h02041234;
    @(negedge clk);
    data = package_data[11*8-1:7*8];
    @(negedge clk);
    data = package_data[7*8-1:3*8];
    @(negedge clk);
    data = {package_data[3*8-1:0], 8'h00};
    @(negedge clk);
    start = 0;
  endtask
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    package_data = value;
  endtask
  
  task change_ip_info;
    input [31:0] src_ip_value, dest_ip_value;
    input [15:0] len_udp_value;
    dest_ip = dest_ip_value;
    src_ip = src_ip_value;
    len_tcp = len_udp_value;
  endtask
  
  task change_tcp_header_info;
    input [15:0] src_port_value, dest_port_value;
    input [31:0] seq_num_value, ack_num_value;
    input [3:0] data_offset_value;
    input [5:0] flag_value;
    input [15:0] window_value, checksum_value, urg_ptr_value;
    
    src_port_reg = src_port_value;
    dest_port_reg = dest_port_value;
    seq_num_reg = seq_num_value;
    ack_num_reg = ack_num_value;
    data_offset_reg = data_offset_value;
    {f_urg_reg, f_ack_reg, f_psh_reg, f_rst_reg, f_syn_reg, f_fin_reg} = flag_value;
    window_reg = window_value;
    checksum_reg = checksum_value;
    urg_ptr_reg = urg_ptr_value;
  endtask
  
  
  always
    #1 clk = ~clk;
 
  
  wire [5:0] flag;
  assign flag = {f_urg, f_ack, f_psh, f_rst, f_syn, f_fin};
  initial begin
    $display("  T\tdata\t\tstr\tclk\trst\tsport\tdport\tsnum\t\tanum\t\tflag\tlen\tdata\t\twr_en\tok\tfin\tdut.chks\tdut.oe");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%b\t%h\t%h\t%h\t%h\t%h\t%h\t\t%b", 
             $time, data, start, clk, reset, src_port, dest_port, seq_num, ack_num, 
             flag, len_data, data_tcp, wr_en, ok, fin, dut.complete_checksum, dut.option_err);
   // $dumpvars(0, UDP_decoder_tb);
  end
  
  
  TCP_decoder dut (.dest_ip(dest_ip), .src_ip(src_ip), .len_tcp(len_tcp), .data(data),
                   .start(start), .clk(clk), .reset(reset),
                   .src_port(src_port), .dest_port(dest_port), .seq_num(seq_num), .ack_num(ack_num),
                   .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
                   .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin), 
                   .window(window), .urg_ptr(urg_ptr),
                   .option_av(option_av), .mss(mss), .scale_wnd(scale_wnd), .sack_nbr(sack_nbr),
                   .sack_n0(sack_n0), .sack_n1(sack_n1), .sack_n2(sack_n2), .sack_n3(sack_n3), 
                   .time_stp(time_stp), .option_err(option_err),
                   .len_data(len_data), .data_tcp(data_tcp), .wr_en(wr_en), .ok(ok), .fin(fin));
  
endmodule
