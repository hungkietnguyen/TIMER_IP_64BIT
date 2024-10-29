module apb_slave (

	//input APB
	input wire sys_clk,
	input wire sys_rst_n,
	input wire tim_psel,
	input wire tim_penable,
	input wire tim_pwrite,
	input wire [11:0] tim_paddr,
	input wire [31:0] tim_pwdata,
	input wire [31:0] rdata,
	input wire [3:0] tim_pstrb,
	input wire error,
	//output APB
	output wire [31:0] tim_prdata,
	output wire [31:0] wdata,
	output wire [11:0] addr,
	output wire [3:0] pstrb,
	output wire tim_pslverr,
	output wire tim_pready,
	output wire wr_en,
	output wire rd_en
	);
	//internal signal
	reg wait_state;

	//assignment
	assign wr_en  = tim_psel & tim_penable & tim_pwrite;
	assign rd_en  = tim_psel & tim_penable & !tim_pwrite;

	assign addr       = tim_paddr;
	assign wdata      = tim_pwdata;
	assign pstrb      = tim_pstrb;
	assign tim_prdata = rdata;
	
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if(!sys_rst_n) begin
			wait_state <= 1'b0;
		end
		else begin
			if(tim_psel & tim_penable) begin
				wait_state <= 1'b1;
			end
			else begin
				wait_state <= 1'b0;
			end
		end
	end
	assign tim_pready = wait_state;
	assign tim_pslverr = tim_psel & tim_penable & tim_pready & error;

endmodule



