module IP_encoder_tb ();
  
  reg [3:0] version;
  reg [3:0] IHL;
  reg [7:0] type_of_ser;
  reg [15:0] identification;
  reg [2:0] flag;
  reg [12:0] frag_offset;
  reg [7:0] time_to_live;
  reg [7:0] protocol;
  reg [31:0] src_ip;
  reg [31:0] dest_ip;
  reg check; // 0 for udp, 1 for tcp
  
  reg [15:0] len_in;
  reg [31:0] data;
  reg [15:0] checksum_in;
  reg clk, reset, start, data_av;

  wire [31:0] pkg_data;
  wire [15:0] len_out;
  wire wr_en, fin;


  parameter package_data_length = 22;
  reg [8*package_data_length-1:0] package_data;
  

  initial begin
    clk = 0;
    checksum_in = 16'h0000;
    change_starting_info(4'd4, 4'd5, 8'd0,
                         16'h1234, 3'b000, 13'b0_1111_0000_0000, 
                         8'h18, 6, // protocol: 17 is udp, 6 is tcp
                         32'h9801_331b, 32'h980e_5e4b, 1'b1, // check: 0 is udp, 1 is tcp
                         package_data_length);
    load_new_package_data("Hello WorldHello World");
    send_pkg_data();
    #14;
    $finish;  
  end
  
  
  
  integer fout; // for file output
  initial begin
    fout = $fopen("IP_out.dump", "wb");
    @(posedge fin);
    $fclose(fout);
  end
  
  always @(posedge clk) begin
    if (wr_en == 1) begin
      $fwriteh(fout, "%u", {pkg_data[7:0], pkg_data[15:8], 
                            pkg_data[23:16], pkg_data[31:24]});
    end
  end
  
  


  task change_starting_info;
    input [3:0] version_v;
    input [3:0] IHL_v;
    input [7:0] type_of_ser_v;
    input [15:0] identification_v;
    input [2:0] flag_v;
    input [12:0] frag_offset_v;
    input [7:0] time_to_live_v;
    input [7:0] protocol_v;
    input [31:0] src_ip_v;
    input [31:0] dest_ip_v;
	  input check_v;
    input [15:0] len_value;
    
    begin
      version = version_v;
      IHL = IHL_v;
      type_of_ser = type_of_ser_v;
      identification = identification_v;
      flag = flag_v;
      frag_offset = frag_offset_v;
      time_to_live = time_to_live_v;
      protocol = protocol_v;
      src_ip = src_ip_v;
      dest_ip = dest_ip_v;
      check = check_v;
      len_in = len_value;
      
      // printing IP header field value
      // version, IHL, type of service, total length, id, flags, frag offset,
      // time to live, protocol, checksum, source ip, dest ip
      $display("IP Header Fields' Values:");
      $display("Version:\t\t%1d\t\t%1h", version, version);
      $display("IHL:\t\t\t%1d\t\t%1h", IHL, IHL);
      $display("Type of Service:\t%1d\t\t%1h", type_of_ser, type_of_ser);
      $display("Total Length:\t\t*\t\t*\t(Create by module)");
      $display("Identification:\t\t%1d\t\t%1h", identification, identification);
      $display("Flags:\t\t\t%1d\t\t%1h", flag, flag);
      $display("Fragment Offset:\t%1d\t\t%1h", 8*frag_offset, frag_offset);
      $display("Time to Live:\t\t%1d\t\t%1h", time_to_live, time_to_live);
      $display("Protocol:\t\t%1d\t\t%1h", protocol, protocol);
      $display("Header Checksum:\t*\t\t*\t(Create by module)");
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
    end
  endtask
  
  
  task send_pkg_data;
    begin
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
    end
  endtask
  
  
  task load_new_package_data;
    input [8*package_data_length-1:0] value;
    begin
      package_data = value;
    end
  endtask


  always
    #1 clk = ~clk;
    
  initial begin
    $display("  T\tdata\t\tstr\tclk\trst\tver\tIHL\tToS\tid\tflag\tfr_off\tTtoL\tprotcl\tcheck\tlen_in\tchks_in\td_av\tl_out\tpkg_data\twr_en\tfin");   
    $monitor("%3d\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
             $time, data, start, clk, reset,
                    version, IHL, type_of_ser, identification, flag,
                    frag_offset, time_to_live, protocol, check, 
                    len_in, checksum_in, data_av,
                    len_out, pkg_data, wr_en, fin);

  end
  
  
  IP_encoder dut  (.version(version), .IHL(IHL), .type_of_ser(type_of_ser), 
                   .identification(identification), .flag(flag),
                   .frag_offset(frag_offset), .time_to_live(time_to_live), .protocol(protocol), 
                   .src_ip(src_ip), .dest_ip(dest_ip), .check(check), .len_in(len_in), 
                   .data(data), .checksum_in(checksum_in), .clk(clk), .reset(reset), 
                   .start(start), .data_av(data_av), .pkg_data(pkg_data),
                   .len_out(len_out), .wr_en(wr_en), .fin(fin));

endmodule
