module rptr_empty
#(
    parameter ADDRSIZE = 4
)
(
    output reg                rempty, 
    output     [ADDRSIZE-1:0] raddr,  //二进制形式的读指针
    output reg [ADDRSIZE  :0] rptr,  //格雷码形式的读指针
    input      [ADDRSIZE  :0] rq2_wptr, //同步后的写指针
    input                     r_req, rclk, rrst_n
);
  reg  [ADDRSIZE:0] rbin;
  wire [ADDRSIZE:0] rgraynext, rbinnext;
  wire rempty_temp;
 // GRAYSTYLE2 pointer
 //将二进制的读指针与格雷码进制的读指针同步
  always @(posedge rclk or negedge rrst_n) 
      if (!rrst_n) begin
          rbin <= 0;
          rptr <= 0;
      end  
      else begin        
          rbin<=rbinnext; //直接作为存储实体的地址
          rptr<=rgraynext;//输出到 sync_r2w.v模块，被同步到 wrclk 时钟域
      end
  // Memory read-address pointer (okay to use binary to address memory)
  assign raddr     = rbin[ADDRSIZE-1:0]; //直接作为存储实体的地址，比如连接到RAM存储实体的读地址端。
  assign rbinnext  = rbin + (r_req & ~rempty); //不空且有读请求的时候读指针加1
  assign rgraynext = (rbinnext>>1) ^ rbinnext; //将二进制的读指针转为格雷码
  // FIFO empty when the next rptr == synchronized wptr or on reset 
  assign rempty_temp = (rgraynext == rq2_wptr); //当读指针等于同步后的写指针，则为空。
  always @(posedge rclk or negedge rrst_n) 
      if (!rrst_n)
          rempty <= 1'b1; 
      else     
          rempty <= rempty_temp;
 
endmodule