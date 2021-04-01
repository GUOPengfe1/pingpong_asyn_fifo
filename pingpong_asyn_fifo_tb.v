module pingpong_asyn_fifo_tb();
// ------------------------------------------------------ //
    // Inputs
    parameter DATASIZE = 8;
    parameter ADDRSIZE = 4; //需要深度为9，设计为16
    reg       wclk;
    reg       rclk;
    reg       rst_n;
    reg [DATASIZE-1:0] wdata;
    // Outputs
    wire [DATASIZE-1:0] rdata, rdata0, rdata1;
    wire           wfull_0, wfull_1;
    wire           rempty_0, rempty_1;
    wire           w_stop;
// ------------------------------------------------------ //
    pingpong_asyn_fifo 
    #(DATASIZE, ADDRSIZE)
    pingpong_asyn_fifo0
    (
        .wclk(wclk),
        .rclk(rclk),
        .rst_n(rst_n),
        .wdata(wdata),   // 输入数据
        .rdata(rdata),
        .rdata0(rdata0),   // 输出数据
        .rdata1(rdata1),   // 输出数据
        .wfull_0(wfull_0),
        .wfull_1(wfull_1),
        .rempty_0(rempty_0),
        .rempty_1(rempty_1),
        .w_stop(w_stop)
    );
// ------------------------------------------------------ //
    initial
    begin
        wclk = 0;
        rclk = 0;
        rst_n = 0;
        wdata = 0;
        #2;
        rst_n = 1;
        
        #4000 $stop;
    end
// ------------------------------------------------------ //
    always #10 wclk = ~wclk;
    always #20 rclk = ~rclk;
// ------------------------------------------------------ //
    always @ (posedge wclk or negedge rst_n)
    begin
        if(rst_n == 1'b0) begin
            wdata <= 8'b0;
        end
        else if(w_stop) begin
            wdata <= wdata;
        end
        else begin
            wdata <= wdata + 1'b1;
        end
    end
// ------------------------------------------------------ //     
endmodule