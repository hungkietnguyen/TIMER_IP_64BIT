module counter_64bit (
	//input sys
	input wire sys_clk,
	input wire sys_rst_n,
	input wire count_en, //comunicate control_counter
	//input wire [31:0] tim_pwdata,
	input wire [31:0] wdata_cnt,
	input wire [3:0] pstrb,

	//comunication with register
	input wire tdr0_wr_sel,
	input wire tdr1_wr_sel,
	//output
	output reg [63:0] cnt
	);
	always @(posedge sys_clk or negedge sys_rst_n)
	  begin
		  if(!sys_rst_n) begin
			  cnt <= 64'b0;
		  end
		  else if (tdr0_wr_sel) begin
                          cnt[31:24] <= (pstrb[3]) ? wdata_cnt[31:24] : cnt[31:24];
			  cnt[23:16] <= (pstrb[2]) ? wdata_cnt[23:16] : cnt[23:16];
			  cnt[15:8]  <= (pstrb[1]) ? wdata_cnt[15:8]  : cnt[15:8];
			  cnt[7:0]   <= (pstrb[0]) ? wdata_cnt[7:0]   : cnt[7:0];

		  end
		  else if(tdr1_wr_sel) begin
                          cnt[63:56] <= (pstrb[3]) ? wdata_cnt[31:24] : cnt[63:56];
			  cnt[55:48] <= (pstrb[2]) ? wdata_cnt[23:16] : cnt[55:48];
			  cnt[47:40] <= (pstrb[1]) ? wdata_cnt[15:8]  : cnt[47:40];
			  cnt[39:32] <= (pstrb[0]) ? wdata_cnt[7:0]   : cnt[39:32];
		  end
		  else if(count_en) begin
			  cnt <= cnt + 1'b1;
		  end
		  else begin
			  cnt <= cnt;

		  end
	  end
	endmodule



