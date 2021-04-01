module rptr_empty
#(
    parameter ADDRSIZE = 4
)
(
    output reg                rempty, 
    output     [ADDRSIZE-1:0] raddr,  //��������ʽ�Ķ�ָ��
    output reg [ADDRSIZE  :0] rptr,  //��������ʽ�Ķ�ָ��
    input      [ADDRSIZE  :0] rq2_wptr, //ͬ�����дָ��
    input                     r_req, rclk, rrst_n
);
  reg  [ADDRSIZE:0] rbin;
  wire [ADDRSIZE:0] rgraynext, rbinnext;
  wire rempty_temp;
 // GRAYSTYLE2 pointer
 //�������ƵĶ�ָ�����������ƵĶ�ָ��ͬ��
  always @(posedge rclk or negedge rrst_n) 
      if (!rrst_n) begin
          rbin <= 0;
          rptr <= 0;
      end  
      else begin        
          rbin<=rbinnext; //ֱ����Ϊ�洢ʵ��ĵ�ַ
          rptr<=rgraynext;//����� sync_r2w.vģ�飬��ͬ���� wrclk ʱ����
      end
  // Memory read-address pointer (okay to use binary to address memory)
  assign raddr     = rbin[ADDRSIZE-1:0]; //ֱ����Ϊ�洢ʵ��ĵ�ַ���������ӵ�RAM�洢ʵ��Ķ���ַ�ˡ�
  assign rbinnext  = rbin + (r_req & ~rempty); //�������ж������ʱ���ָ���1
  assign rgraynext = (rbinnext>>1) ^ rbinnext; //�������ƵĶ�ָ��תΪ������
  // FIFO empty when the next rptr == synchronized wptr or on reset 
  assign rempty_temp = (rgraynext == rq2_wptr); //����ָ�����ͬ�����дָ�룬��Ϊ�ա�
  always @(posedge rclk or negedge rrst_n) 
      if (!rrst_n)
          rempty <= 1'b1; 
      else     
          rempty <= rempty_temp;
 
endmodule