module UDP_encoder_tb ();

  reg [31:0] src_ip, dest_ip; 
	reg [15:0] src_port, dest_port, len_in;
  reg [31:0] data;
  reg clk, reset, no_chksum, start, data_av;

  wire [31:0] pkg_data;
  wire [15:0] checksum_out;
  wire [15:0] len_out;
  wire wr_en, fin;

  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;

  initial begin
    clk = 0;
    no_chksum = 0;
    change_starting_info(32'h9801_331b, 32'h980e_5e4b, 'ha08f, 'h2694, package_data_length);
    load_new_package_data("Hello World");
    send_udp_data();
    #6;
    $finish;  
  end


  task change_starting_info;
    input [31:0] src_ip_value, dest_ip_value;
    input [15:0] src_port_value, dest_port_value, len_value;
    src_ip = src_ip_value;
    dest_ip = dest_ip_value; 
    src_port = src_port_value;
    dest_port = dest_port_value;
    len_in = len_value;
    
    // printing IP pseduo header field value
    $display("IP Pseudo Header Fields' Values:");
    $display("UDP Length:\t\t%1d\t\t%1h", len_in, len_in);
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
    // printing UDP header field value
    // source port, dest port, length, checksum
    $display("UDP Header Fields' Values:");
    $display("Source Port:\t\t%1d\t\t%1h", src_port, src_port);
    $display("Destination Port:\t%1d\t\t%1h", dest_port, dest_port);
    $display("Length:\t\t\t%1d\t\t%1h", len_in, len_in);
    $display("Checksum:\t\t*\t\t*\t(Create by module)");
    $display(); // create a blank line
  endtask
  
  
  task send_udp_data;
    @(negedge clk);
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
  
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    package_data = value;
  endtask


  always
    #1 clk = ~clk;
    
  initial begin
    $display("  T\tsrc_ip \t\tdest_ip\t\tsrc_p\tdest_p\tlen_in\tdata\t\tclk\treset\tno_cs\tstart\tdata_av\tpkg_data\tcs_out\twr_en\tfin\tlen_out");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, src_ip, dest_ip, src_port, dest_port, len_in, 
             data, clk, reset, no_chksum, start, data_av,
             pkg_data, checksum_out, wr_en, fin, len_out);
    // $dumpvars(0, UDP_decoder_tb);
  end
  
  UDP_encoder dut (.src_ip(src_ip), .dest_ip(dest_ip),
                   .src_port(src_port), .dest_port(dest_port), .len_in(len_in), 
                   .data(data), .clk(clk), .reset(reset), .no_chksum(no_chksum), 
                   .start(start), .data_av(data_av), .pkg_data(pkg_data), .wr_en(wr_en), 
                   .fin(fin), .checksum_out(checksum_out), .len_out(len_out));


endmodule
