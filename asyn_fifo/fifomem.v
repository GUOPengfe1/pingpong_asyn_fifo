module fifomem
#(
    parameter  DATASIZE = 8, // Memory data word width               
    parameter  ADDRSIZE = 4  // ���Ϊ16����ַΪ4λ���ɣ�����ඨ��һλ��ԭ���������ж��ǿջ���������ϸ�ں��Ľ���
) // Number of mem address bits
(
    output [DATASIZE-1:0] rdata, 
    input  [DATASIZE-1:0] wdata, 
    input  [ADDRSIZE-1:0] waddr, raddr, 
    input                 wclken, wfull, wclk,
    input                 rclken, rempty, rclk
);
  
`ifdef RAM   //���Ե���һ��RAM IP��
  // instantiation of a vendor's dual-port RAM 
    my_ram  mem
        (
            .dout(rdata),
            .din(wdata),     
            .waddr(waddr),
            .raddr(raddr),   
            .wclken(wclken), 
            .wclken_n(wfull),
            .clk(wclk)
        );
`else  //���������ɴ洢��
   // RTL Verilog memory model
    localparam DEPTH = 1<<ADDRSIZE;   // �����൱�ڳ˷���2^4
    reg [DATASIZE-1:0] mem [0:DEPTH-1]; //����2^4��λ��λ8������
    assign rdata = mem[raddr];
    always @(posedge wclk)  //��дʹ����Ч�һ�δд����ʱ������д��洢ʵ���У�ע����������wclkͬ����
        if (wclken && !wfull)
            mem[waddr] <= wdata;
    /*always @(posedge rclk)
        if (rclken && !rempty)
            rdata = mem[raddr];*/
`endif
endmodule