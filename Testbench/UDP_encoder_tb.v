module UDP_encoder_tb ();

	reg [15:0] src_port, dest_port, len;
  reg [31:0] data;
  reg clk, reset, no_chksum, start, data_av;

  wire [31:0] pkg_data;
  wire [15:0] checksum_out;
  wire wr_en, fin;

  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 11;

  initial begin
    clk = 0;
    no_chksum = 0;
    change_starting_info('ha08f, 'h2694, package_data_length);
    load_new_package_data("Hello World");
    send_udp_data();
    #6;
    $finish;  
  end


  task change_starting_info;
    input [15:0] src_port_value, dest_port_value, len_value;
    src_port = src_port_value;
    dest_port = dest_port_value;
    len = len_value;
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
    $display("  T\tsrc_p\tdest_p\tlen\tdata\t\tclk\treset\tno_cs\tstart\tdata_av\tpkg_data\tcs_out\twr_en\tfin\tbleft\ttemp2\tacc_chks");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, src_port, dest_port, len, 
             data, clk, reset, no_chksum, start, data_av,
             pkg_data, checksum_out, wr_en, fin, 
             dut.bytes_left, dut.temp2, dut.accum_checksum);
    // $dumpvars(0, UDP_decoder_tb);
  end
  
  UDP_encoder dut (.src_port(src_port), .dest_port(dest_port), .len(len), .data(data), 
               .clk(clk), .reset(reset), .no_chksum(no_chksum), .start(start), .data_av(data_av),
               .pkg_data(pkg_data), .wr_en(wr_en), .fin(fin), .checksum_out(checksum_out));


endmodule
