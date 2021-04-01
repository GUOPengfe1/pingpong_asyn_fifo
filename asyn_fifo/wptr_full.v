module wptr_full
#(
    parameter ADDRSIZE = 4
) 
(
    output reg                wfull,   
    output     [ADDRSIZE-1:0] waddr,
    output reg [ADDRSIZE  :0] wptr, 
    input      [ADDRSIZE  :0] wq2_rptr,
    input                     w_req, wclk, wrst_n
);
  reg  [ADDRSIZE:0] wbin;
  wire [ADDRSIZE:0] wgraynext, wbinnext;
  wire wfull_temp;
  // GRAYSTYLE2 pointer
  always @(posedge wclk or negedge wrst_n)   
      if (!wrst_n)
          {wbin, wptr} <= 0;   
      else         
          {wbin, wptr} <= {wbinnext, wgraynext};
  // Memory write-address pointer (okay to use binary to address memory) 
  assign waddr = wbin[ADDRSIZE-1:0];
  assign wbinnext  = wbin + (w_req & ~wfull);
  assign wgraynext = (wbinnext>>1) ^ wbinnext; //二进制转为格雷码
  //-----------------------------------------------------------------
  assign wfull_temp = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]}); //当最高位和次高位不同其余位相同时则写指针超前于读指针一圈，即写满。后面会详细解释。
  always @(posedge wclk or negedge wrst_n)
      if (!wrst_n)
          wfull  <= 1'b0;   
      else     
          wfull  <= wfull_temp;
 
  endmodule