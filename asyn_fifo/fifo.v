module fifo
#(
  parameter DATASIZE = 8,        
  parameter ADDRSIZE = 4
 ) 
 (
     output [DATASIZE-1:0] rdata,  
     output             wfull,  
     output             rempty,  
     input [DATASIZE-1:0]  wdata,
     input              w_req_val, wclk, wrst_n, 
     input              r_req_val, rclk, rrst_n
 );

  wire   [ADDRSIZE-1:0] waddr, raddr;  
  wire   [ADDRSIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;
  wire   w_req, r_req;
// synchronize the read pointer into the write-clock domain
  sync_r2w  
  #(ADDRSIZE)  
  sync_r2w0
  (
                    .wq2_rptr    (wq2_rptr),
                    .rptr        (rptr    ),                          
                    .wclk        (wclk    ), 
                    .wrst_n      (wrst_n  )  
 );

// synchronize the write pointer into the read-clock domain
  sync_w2r  
  #(ADDRSIZE)  
  sync_w2r0
  (
                   .rq2_wptr(rq2_wptr), 
                   .wptr(wptr),                          
                   .rclk(rclk),
                   .rrst_n(rrst_n)
 );

//this is the FIFO memory buffer that is accessed by both the write and read clock domains.
//This buffer is most likely an instantiated, synchronous dual-port RAM. 
//Other memory styles can be adapted to function as the FIFO buffer. 
  fifomem 
  #(DATASIZE, ADDRSIZE)
  fifomem0                        
  (
      .rdata(rdata), 
      .wdata(wdata),                           
      .waddr(waddr),
      .raddr(raddr),                           
      .wclken(w_req),
      .wfull(wfull),
      .wclk(wclk),
      .rclken(r_req),
      .rempty(rempty),
      .rclk(rclk)
  );

//this module is completely synchronous to the read-clock domain and contains the FIFO read pointer and empty-flag logic.  
  rptr_empty
  #(ADDRSIZE)    
  rptr_empty0                          
  (
      .rempty(rempty),                          
      .raddr(raddr),                          
      .rptr(rptr),
      .rq2_wptr(rq2_wptr),                          
      .r_req(r_req),
      .rclk(rclk),                          
      .rrst_n(rrst_n)
  );

//this module is completely synchronous to the write-clock domain and contains the FIFO write pointer and full-flag logic
  wptr_full 
  #(ADDRSIZE)    
  wptr_full0                         
  (
      .wfull(wfull),
      .waddr(waddr),  
      .wptr(wptr),
      .wq2_rptr(wq2_rptr),    
      .w_req(w_req),
      .wclk(wclk),        
      .wrst_n(wrst_n)
  );

/*
  always  @(posedge wclk or negedge wrst_n)begin
      if(wrst_n==1'b0)begin
          w_req <= 0;
      end
      else begin
          w_req <= w_req_val;
      end
  end

  always  @(posedge rclk or negedge rrst_n)begin
      if(rrst_n==1'b0)begin                  
          r_req <= 0;
      end
      else begin                
          r_req <= r_req_val;
      end
  end
*/
    assign w_req = w_req_val;
    assign r_req = r_req_val;

endmodule