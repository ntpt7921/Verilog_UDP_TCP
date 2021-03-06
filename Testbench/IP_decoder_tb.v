module IP_decoder_tb ();
  reg [31:0] data;
  reg start;
  reg clk;
  reg reset;
  
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
  
  wire [15:0] len_out;
  wire [31:0] data_out;
  wire wr_en;
  wire ok;
  wire fin;
  
  
  reg [3:0] version_r;
  reg [3:0] IHL_r;
  reg [7:0] type_of_ser_r;
  reg [15:0] total_length_r;
  reg [15:0] identification_r;
  reg [2:0] flag_r;
  reg [12:0] frag_offset_r;
  reg [7:0] time_to_live_r;
  reg [7:0] protocol_r;
  reg [15:0] chksum_r;
  reg [31:0] src_ip_r;
  reg [31:0] dest_ip_r;
  
  
  parameter package_data_length = 11;
  reg [8*package_data_length-1:0] package_data;
  
  
  initial begin
    clk = 0;
    load_new_package_data("Hello World");
    change_ip_header_value(4'd4, 4'd5, 8'd0, package_data_length + 4*5,
                           16'h1234, 3'b000, 13'h123, 8'h10, 17,
                           16'hd601, 32'h9801_331b, 32'h980e_5e4b); 
    send_ip_data();
    #2;
    $finish;  
  end
  
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    begin
      package_data = value;
    end
  endtask
  
  task change_ip_header_value;
    input [3:0] version_v;
    input [3:0] IHL_v;
    input [7:0] type_of_ser_v;
    input [15:0] total_length_v;
    input [15:0] identification_v;
    input [2:0] flag_v;
    input [12:0] frag_offset_v;
    input [7:0] time_to_live_v;
    input [7:0] protocol_v;
    input [15:0] chksum_v;
    input [31:0] src_ip_v;
    input [31:0] dest_ip_v;
    
    begin
      version_r = version_v;
      IHL_r = IHL_v;
      type_of_ser_r = type_of_ser_v;
      total_length_r = total_length_v;
      identification_r = identification_v;
      flag_r = flag_v;
      frag_offset_r = frag_offset_v;
      time_to_live_r = time_to_live_v;
      protocol_r = protocol_v;
      chksum_r = chksum_v;
      src_ip_r = src_ip_v;
      dest_ip_r = dest_ip_v;
      
      // printing IP header field value
      // version, IHL, type of service, total length, id, flags, frag offset,
      // time to live, protocol, checksum, source ip, dest ip
      $display("IP Header Fields' Values:");
      $display("Version:\t\t%1d\t\t%1h", version_r, version_r);
      $display("IHL:\t\t\t%1d\t\t%1h", IHL_r, IHL_r);
      $display("Type of Service:\t%1d\t\t%1h", type_of_ser_r, type_of_ser_r);
      $display("Total Length:\t\t%1d\t\t%1h", total_length_r, total_length_r);
      $display("Identification:\t\t%1d\t\t%1h", identification_r, identification_r);
      $display("Flags:\t\t\t%1d\t\t%1h", flag_r, flag_r);
      $display("Fragment Offset:\t%1d\t\t%1h", frag_offset_r, frag_offset_r);
      $display("Time to Live:\t\t%1d\t\t%1h", time_to_live_r, time_to_live_r);
      $display("Protocol:\t\t%1d\t\t%1h", protocol_r, protocol_r);
      $display("Header Checksum:\t%1d\t\t%1h", chksum_r, chksum_r);
      $display("Source IP:\t\t%1d.%1d.%1d.%1d\t%1h", src_ip_r[31:24], 
                                                     src_ip_r[23:16], 
                                                     src_ip_r[15:8], 
                                                     src_ip_r[7:0], 
                                                     src_ip_r);
      $display("Destination IP:\t\t%1d.%1d.%1d.%1d\t%1h", dest_ip_r[31:24], 
                                                          dest_ip_r[23:16], 
                                                          dest_ip_r[15:8], 
                                                          dest_ip_r[7:0],
                                                          dest_ip_r);
      $display(); // create a blank line
    end
  endtask
  
  task send_ip_data;
    begin
      reset = 1;
      @(negedge clk);
      reset = 0;
      start = 1;
      data = {version_r, IHL_r, type_of_ser_r, total_length_r};
      @(negedge clk);
      data = {identification_r, flag_r, frag_offset_r};
      @(negedge clk);
      data = {time_to_live_r, protocol_r, chksum_r};
      @(negedge clk);
      data = src_ip_r;
      @(negedge clk);
      data = dest_ip_r;
      @(negedge clk);
      repeat(IHL_r - 5) begin // option part, module will ignore this
        data = 32'd0;
        @(negedge clk);
      end
      
      data = package_data[11*8-1:7*8];
      @(negedge clk);
      start = 0;
      data = package_data[7*8-1:3*8];
      @(negedge clk);
      data = {package_data[3*8-1:0], 8'h00};
      @(negedge clk);
      start = 0;
    end
  endtask
  
  always
    #1 clk = ~clk;
 
  initial begin
    $display("  T\td\t\tstart\tclk\trst\tver\tIHL\tTofSe\tlen\tid\tflag\tfr_os\tTtoL\tprtcl\tsip\t\tdip\t\tl_out\tdout\t\twr_en\tok\tfin\tchks");
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
                    version, IHL, type_of_ser, total_length, identification, flag,
                    frag_offset, time_to_live, protocol, src_ip, dest_ip,
                    len_out, data_out, wr_en, ok, fin, dut.head_chks16);
   // $dumpvars(0, UDP_decoder_tb);
  end
  
  
  IP_decoder dut (.data(data), .start(start), .clk(clk), .reset(reset),
                  .version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
                  .total_length(total_length), .identification(identification), .flag(flag),
                  .frag_offset(frag_offset), .time_to_live(time_to_live), 
                  .protocol(protocol), .src_ip(src_ip), .dest_ip(dest_ip),
                  .len_out(len_out), .data_out(data_out), 
                  .wr_en(wr_en), .ok(ok), .fin(fin));

endmodule
