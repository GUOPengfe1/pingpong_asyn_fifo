module sync_w2r
#(parameter ADDRSIZE = 4)
(
    output reg [ADDRSIZE:0] rq2_wptr, //写指针同步到读时钟域
    input      [ADDRSIZE:0] wptr,     //格雷码形式的写指针
    input                   rclk, rrst_n
);
 
  reg [ADDRSIZE:0] rq1_wptr;
 
  always @(posedge rclk or negedge rrst_n)   
      if (!rrst_n)begin
          rq1_wptr <= 0;
          rq2_wptr <= 0;
      end 
      else begin
          rq1_wptr <= wptr;
          rq2_wptr <= rq1_wptr;
      end
        
endmodule