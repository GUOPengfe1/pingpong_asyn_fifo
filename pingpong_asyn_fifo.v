module pingpong_asyn_fifo
    #(
        parameter DATASIZE = 8,
        parameter ADDRSIZE = 4
    ) 
    (
    input            wclk,
    input            rclk,
    input            rst_n,
    input      [DATASIZE-1:0] wdata,   // 输入数据    
    output reg [DATASIZE-1:0] rdata,   // 输出数据
    output     [DATASIZE-1:0] rdata0,rdata1,   // 输出数据
    output           wfull_0, wfull_1,
    output           rempty_0, rempty_1,
    output           w_stop
    );
// ------------------------------------------------------ //
    localparam R1W0 = 1'b0, R0W1 = 1'b1;
    reg       w_req_val_0,w_req_val_1;  // 写标志，wr_flag=0，写buffer1，wr_flag=1，写buffer2
    reg       r_req_val_0 = 1,r_req_val_1 = 1;
    reg       state, nextstate;    // 状态机，0：写1读2,1：写2读1，状态转移和输出分开编码

    always @ (*) begin
        case(state)
            R1W0   : nextstate = (wfull_0 & rempty_1) ? R0W1 : R1W0;    // 写1读2>写2读1
            R0W1   : nextstate = (wfull_1 & rempty_0) ? R1W0 : R0W1;    // 写2读1>写1读2
            default: nextstate = R1W0;
        endcase
    end

    always @ (posedge rclk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
                state <= R1W0;
            end
        else begin
                state <= nextstate;
        end
    end

    always @ (*) begin
        case(nextstate)
            R1W0:
            begin
                w_req_val_0 = w_stop? 1'b0 : 1'b1;
                w_req_val_0 = 1'b1;
                w_req_val_1 = 1'b0;
                r_req_val_0 = 1'b0;
                r_req_val_1 = 1'b1;
                rdata = rdata1;
            end
            R0W1:
            begin
                w_req_val_0 = 1'b0;
                w_req_val_1 = w_stop? 1'b0 : 1'b1;  //数据输入停止时，写入也停止
                w_req_val_1 = 1'b1;
                r_req_val_0 = 1'b1;
                r_req_val_1 = 1'b0;
                rdata = rdata0;
            end
            default:
            begin
                w_req_val_0 = 1'b0;
                w_req_val_1 = 1'b0;
                r_req_val_0 = 1'b0;
                r_req_val_1 = 1'b0;
                rdata = rdata0;
            end
        endcase
    end

    assign w_stop = (state == R1W0 && wfull_0) || (state == R0W1 && wfull_1); //写1但fifo1满时，停止写入，数据输入也停止
// ------------------------------------------------------ //    
    fifo 
    #(DATASIZE, ADDRSIZE)
    fifo0 (
                   .rdata(rdata0),  
                   .wfull(wfull_0),  
                   .rempty(rempty_0), 
                   .wdata(wdata),  
                   .w_req_val  (w_req_val_0), 
                   .wclk  (wclk), 
                   .wrst_n(rst_n),  //rst_n is used for wrst_n and rrst_n
                   .r_req_val(r_req_val_0), 
                   .rclk(rclk), 
                   .rrst_n(rst_n)
     ); 

    fifo 
    #(DATASIZE, ADDRSIZE)
    fifo1 (
                   .rdata(rdata1),  
                   .wfull(wfull_1),  
                   .rempty(rempty_1),
                   .wdata(wdata),
                   .w_req_val  (w_req_val_1), 
                   .wclk  (wclk), 
                   .wrst_n(rst_n), 
                   .r_req_val(r_req_val_1), 
                   .rclk(rclk), 
                   .rrst_n(rst_n)
     ); 
endmodule