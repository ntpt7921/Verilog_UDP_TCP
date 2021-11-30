module UDP_decoder_tb ();
  reg [31:0] dest_ip;
  reg [31:0] src_ip;
  reg [15:0] len_ip;
  reg [31:0] data;
  reg start, clk, reset;

  wire [15:0] dest_port, src_port, len_udp;
  wire [31:0] data_udp;
  wire wr_en, ok, fin;
  
  
  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;
  
  
  initial begin
    clk = 0;
    reset = 1;
    @(posedge clk);
    reset = 0;
    change_ip_info('h9801_331b, 'h980e_5e4b, package_data_length + 8);
    load_new_package_data("Hello World");
    send_udp_data('ha08f, 'h2694, len_ip);
    #2;
    $finish;  
  end
  
  
  task change_ip_info;
    input [31:0] src_ip_value, dest_ip_value;
    input [15:0] len_ip_value;
    dest_ip = dest_ip_value;
    src_ip = src_ip_value;
    len_ip = len_ip_value;
  endtask
  
  
  task send_udp_data;
    input [15:0] src_udp_port_value, dest_udp_port_value, len_udp_value;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
    data = {src_udp_port_value, dest_udp_port_value};
    @(negedge clk);
    start = 0;
    data = {len_udp_value, 16'h2560}; // checksum for current test
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
  
  
  
  always
    #1 clk = ~clk;
  
  initial begin
    $display("  T\tsip\t\tdip\t\tlip\tdata\t\tstart\tclk\treset\tsport\tdport\tlen_udp\tdata_udp\twr_en\tok\tfin\tudp.bytes_left\tudp_chksum");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t\t%h", 
             $time, src_ip, dest_ip, len_ip, data, start, clk, reset,
             src_port, dest_port, len_udp, data_udp, wr_en, ok, fin, 
             dut.bytes_left, dut.complete_checksum);
   // $dumpvars(0, UDP_decoder_tb);
  end
  
  
  UDP_decoder dut 
  (.dest_ip(dest_ip), .src_ip(src_ip), .len_ip(len_ip), .data(data), .start(start),
   .clk(clk), .reset(reset), 
   .dest_port(dest_port), .src_port(src_port), .len_udp(len_udp), .data_udp(data_udp),
   .wr_en(wr_en), .ok(ok), .fin(fin));
  
endmodule
