module IP_encoder_tb ();
  
  reg [3:0] version;
  reg [3:0] IHL;
  reg [7:0] type_of_ser;
  reg [15:0] total_length;
  reg [15:0] identification;
  reg [2:0] flag;
  reg [12:0] frag_offset;
  reg [7:0] time_to_live;
  reg [7:0] protocol;
 
  reg [31:0] src_ip;
  reg [31:0] dest_ip;
  reg check;
  reg [15:0] len_in;
  reg [31:0] data;
  reg [15:0] checksum_in;
  reg clk, reset,start, data_av;

  wire [31:0] pkg_data;
  wire [15:0] len_out;
  wire wr_en, fin;
  wire [15:0] checksum_out;

  reg [8*package_data_length-1:0] package_data;
  parameter package_data_length = 22;

  initial begin
    clk = 0;
    change_starting_info(4'd4, 4'd5, 8'd0, package_data_length + 4*5,
                           16'h1234, 3'b000, 13'h123, 8'h10, 17,
                           32'h9801_331b, 32'h980e_5e4b,1'b1,package_data_length);
    load_new_package_data("Hello WorldHello World");
    send_tcp_data();
    #14;
    $finish;  
  end


  task change_starting_info;
    input [3:0] version_v;
    input [3:0] IHL_v;
    input [7:0] type_of_ser_v;
    input [15:0] total_length_v;
    input [15:0] identification_v;
    input [2:0] flag_v;
    input [12:0] frag_offset_v;
    input [7:0] time_to_live_v;
    input [7:0] protocol_v;
    input [31:0] src_ip_v;
    input [31:0] dest_ip_v;
	input check_v;
    input [15:0] len_value;
    
    version = version_v;
    IHL=IHL_v;
    type_of_ser=type_of_ser_v;
    total_length=total_length_v;
    identification=identification_v;
    flag=flag_v;
    frag_offset=frag_offset_v;
    time_to_live=time_to_live_v;
    protocol = protocol_v;
    src_ip=src_ip_v;
    dest_ip=dest_ip_v;
    check = check_v;
    len_in = len_value;
  endtask
  
  
  task send_tcp_data;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;
    start = 1;
    data_av = 1;
    data = package_data[22*8-1:18*8];
    @(negedge clk);
    start = 0;
    data_av = 0;
    data = package_data[18*8-1:14*8];
    @(negedge clk);
    data_av = 1;
    @(negedge clk);
    data = package_data[14*8-1:10*8];
    @(negedge clk);
    data_av = 0;
    @(negedge clk);
    data_av = 1;
    data = package_data[10*8-1:6*8];
    @(negedge clk);
    start = 0;
    data_av = 0;
    data = package_data[6*8-1:2*8];
    @(negedge clk);
    data_av = 1;
    @(negedge clk);
    data = {package_data[2*8-1:0], 16'h0000};
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
   $display("  T\td\t\tstart\tclk\trst\tver\tIHL\tTofSe\tlen\tid\tflag\tfr_os\tTtoL\tprtcl\tchecksum_out\tsip\t\tdip\t\tcheck\tlen_in\tck_in\tdt_av\tlen_out\tdata\t\twr\tfin\tcount\tdl_av\tst");
   $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
                    version, IHL, type_of_ser, total_length, identification, flag,
                    frag_offset, time_to_live, protocol,checksum_out, src_ip, dest_ip,check,len_in,checksum_in,data_av,
                    len_out, pkg_data,wr_en,fin,dut.count,dut.data_av_dl,dut.state);

  end
  
  
  IP_encoder dut  ( 
                  .version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
                  .total_length(total_length), .identification(identification), .flag(flag),
                  .frag_offset(frag_offset), .time_to_live(time_to_live), 
                  .protocol(protocol),.checksum_out(checksum_out), .src_ip(src_ip), .dest_ip(dest_ip),.check(check),.len_in(len_in),.data(data),.checksum_in(checksum_in), .clk(clk), .reset(reset),.start(start),.data_av(data_av), .pkg_data(pkg_data),
    .len_out(len_out),      .wr_en(wr_en),  .fin(fin));

endmodule