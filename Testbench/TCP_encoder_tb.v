module TCP_encoder_tb ();
  reg [15:0] src_port, dest_port;
  reg [31:0] seq_num, ack_num;
  reg f_urg, f_ack, f_psh, f_rst, f_syn, f_fin;
  reg [15:0] window;
  reg [15:0] urg_ptr;
  reg [3:0] opt_word;
  
  reg [31:0] data;
  reg [15:0] len;
  reg clk, reset, start, data_av;

  wire [31:0] pkg_data;
  wire [15:0] checksum_out;
  wire wr_en, fin;
  
  
  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;
  
  
  initial begin
    clk = 0;
    change_tcp_header_info('ha08f, 'h2694, 1, 2, 6'b11_1111, 3, 4);
    opt_word = 1;
    len = package_data_length;
    load_new_package_data("Hello World");
    send_tcp_data();
    #12;
    $finish;  
  end
  
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    package_data = value;
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
  endtask
  
  task send_tcp_data;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
    data_av = 1;
    data = {8'd2, 8'd4, 16'h1234}; // 1 word option
    @(negedge clk);
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
    $display("  T\tsport\tdport\tseqn\t\tackn\t\tf\twindow\tu_pt\topt_w\tdata\t\tl\tclk\treset\tstart\tdata_av\tpkg_data\tchks\twr_en\tfin");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%b\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, src_port, dest_port, seq_num, ack_num, 
                    flag, window, urg_ptr, opt_word,
                    data, len, clk, reset, start, data_av,
                    pkg_data, checksum_out, wr_en, fin);
   // $dumpvars(0, UDP_decoder_tb);
  end
  
  TCP_encoder dut (.src_port(src_port), .dest_port(dest_port), .seq_num(seq_num), .ack_num(ack_num), 
                   .f_urg(f_urg), .f_ack(f_ack), .f_psh(f_psh), 
                   .f_rst(f_rst), .f_syn(f_syn), .f_fin(f_fin),
                   .window(window), .urg_ptr(urg_ptr), .opt_word(opt_word),
                   .data(data), .len(len), .clk(clk), .reset(reset), .start(start), .data_av(data_av),
                   .pkg_data(pkg_data), .checksum_out(checksum_out), .wr_en(wr_en), .fin(fin));
  
endmodule
