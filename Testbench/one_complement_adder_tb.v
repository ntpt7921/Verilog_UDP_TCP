module one_complement_adder_tb ();
  parameter LENGTH = 16;
  
  reg [LENGTH-1:0] a1;
  reg [LENGTH-1:0] a2;
  wire [LENGTH-1:0] res;
  
  
  // 0 + 0 = 0
  // 1 + 1 = 2
  // 1234 + 5678 = 6912
  // 'hFFFE + 'h1 = 'hFFFF
  // 'hFFFE + 'h2 = 'h0001
  initial begin
    a1 = 0;
    a2 = 0;
    #5;
    a1 = 1;
    a2 = 1;
    #5;
    a1 = 'd1234;
    a2 = 'd5678;
    #5;
    a1 = 'hFFFE;
    a2 = 'h0001;
    #5;
    a1 = 'hFFFE;
    a2 = 'h0002;
    #5;
    $finish;
  end
  
  initial begin
    $display("  T\ta1\ta2\tres");
    $monitor("%3d\t%h\t%h\t%h", $time, a1, a2, res);
  end
  
  one_complement_adder #(.LENGTH(LENGTH)) dut (.a1(a1), .a2(a2), .res(res));

endmodule
