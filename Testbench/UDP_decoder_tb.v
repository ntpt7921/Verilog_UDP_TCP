module UDP_decoder_tb ();
  reg [31:0] dest_ip;
  reg [31:0] src_ip;
  reg [15:0] len_udp;
  reg [31:0] data;
  reg start, clk, reset;

  wire [15:0] dest_port, src_port, len_data;
  wire [31:0] data_udp;
  wire wr_en, ok, fin;
  
  
  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;
  reg [15:0] src_port_r, dest_port_r, len_udp_r, chks_udp_r;
  
  
  initial begin
    clk = 0;
    
    load_new_package_data("Hello World");
    change_ip_info('h9801_331b, 'h980e_5e4b, package_data_length + 8);
    change_udp_header_value('ha08f, 'h2694, len_udp, 16'h2560);
    send_udp_data();
    
    @(posedge fin);
    #1;
    $finish;  
  end
  
  
  
  task change_ip_info;
    input [31:0] src_ip_value, dest_ip_value;
    input [15:0] len_udp_value;
    dest_ip = dest_ip_value;
    src_ip = src_ip_value;
    len_udp = len_udp_value;
    
    // printing IP pseduo header field value
    $display("IP Pseudo Header Fields' Values:");
    $display("UDP Length:\t\t%1d\t\t%1h", len_udp, len_udp);
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
  endtask
  
  task change_udp_header_value;
    input [15:0] src_port_value, dest_port_value;
    input [15:0] length_value, checksum_value;
    
    src_port_r = src_port_value;
    dest_port_r = dest_port_value;
    len_udp_r = length_value;
    chks_udp_r = checksum_value;
    
    // printing UDP header field value
    // source port, dest port, length, checksum
    $display("UDP Header Fields' Values:");
    $display("Source Port:\t\t%1d\t\t%1h", src_port_r, src_port_r);
    $display("Destination Port:\t%1d\t\t%1h", dest_port_r, dest_port_r);
    $display("Length:\t\t\t%1d\t\t%1h", len_udp_r, len_udp_r);
    $display("Checksum:\t\t%1d\t\t%1h", chks_udp_r, chks_udp_r);
    $display(); // create a blank line
    
  endtask
  
  task send_udp_data;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
    data = {src_port_r, dest_port_r};
    @(negedge clk);
    start = 0;
    data = {len_udp_r, chks_udp_r}; // checksum for current test
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
    $display("  T\tsip\t\tdip\t\tludp\tdata\t\tstart\tclk\treset\tsport\tdport\tlen_data\tdata_udp\twr_en\tok\tfin\tudp.bytes_left\tcs");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t\t%h\t%h\t%h\t%h\t%h\t\t%h", 
             $time, src_ip, dest_ip, len_udp, data, start, clk, reset,
             src_port, dest_port, len_data, data_udp, wr_en, ok, fin, 
             dut.bytes_left, dut.complete_checksum);
   // $dumpvars(0, UDP_decoder_tb);
  end
  
  UDP_decoder dut 
  (.dest_ip(dest_ip), .src_ip(src_ip), .len_udp(len_udp), .data(data), .start(start),
   .clk(clk), .reset(reset), 
   .dest_port(dest_port), .src_port(src_port), .len_data(len_data), .data_udp(data_udp),
   .wr_en(wr_en), .ok(ok), .fin(fin));
  
endmodule
