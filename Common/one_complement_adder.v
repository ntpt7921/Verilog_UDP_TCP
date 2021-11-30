module one_complement_adder (a1, a2, res);
  parameter LENGTH = 32;
  
  input [LENGTH-1:0] a1;
  input [LENGTH-1:0] a2;
  output [LENGTH-1:0] res;
  
  wire [LENGTH-1:0] a1;
  wire [LENGTH-1:0] a2;
  wire [LENGTH-1:0] res;
  
  wire [LENGTH:0] temp;
  assign temp = a1 + a2;
  assign res = temp[LENGTH] + temp[LENGTH-1:0];
  
endmodule
