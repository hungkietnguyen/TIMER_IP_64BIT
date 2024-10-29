module timer_top (
	input wire sys_clk,
	input wire sys_rst_n,
	input wire dbg_mode,
	input wire [11:0] tim_paddr,
	input wire tim_psel,
	input wire tim_penable,
	input wire tim_pwrite,
	input wire [31:0] tim_pwdata,
	input wire [3:0] tim_pstrb,

	//output
	output wire [31:0] tim_prdata,
	output wire tim_pready,
	output wire tim_pslverr,
	output wire tim_int
	);
	//signal apb
	wire [31:0] rdata_tmp;
	wire wr_en_tmp;
	wire rd_en_tmp;
	wire [31:0] wdata_tmp;
	wire [11:0] addr_tmp;
	wire [3:0]  pstrb_tmp;
	
	//signal register
	wire [63:0] cnt_tmp;
	wire timer_en_tmp;
	wire div_en_tmp;
	wire [3:0] div_val_tmp;
	wire halt_ack_tmp;
	wire tdr0_wr_tmp;
	wire tdr1_wr_tmp;
	wire [31:0] wdata_cnt_tmp;
	wire halt_reg_tmp;

	//signal contro_cnt
	wire count_en_tmp;

	//instance module apb_slave
	apb_slave u_apb(. sys_clk(sys_clk), 
			.sys_rst_n(sys_rst_n),
		       	.tim_psel(tim_psel),
		       	.tim_penable(tim_penable),
		       	.tim_pwrite(tim_pwrite),
			.tim_paddr(tim_paddr),
			.tim_pwdata(tim_pwdata),
			.tim_pstrb(tim_pstrb),
			.error(error),
			.rdata(rdata_tmp),
		       	.wr_en(wr_en_tmp),
		       	.rd_en(rd_en_tmp),
			.tim_prdata(tim_prdata),
			.wdata(wdata_tmp),
			.addr(addr_tmp),
			.pstrb(pstrb_tmp),
			.tim_pslverr(tim_pslverr),
		       	.tim_pready(tim_pready));

	//instance module register
	register u_register(. sys_clk(sys_clk),
	       		    .sys_rst_n(sys_rst_n),
			    .cnt(cnt_tmp),
			    .wr_en(wr_en_tmp),
			    .rd_en(rd_en_tmp),
			    .addr(addr_tmp),
			    .wdata(wdata_tmp),
			    .pstrb(pstrb_tmp),
			    .rdata(rdata_tmp),
			    .tim_pready(tim_pready),
			    .timer_en(timer_en_tmp),
			    .div_val(div_val_tmp),
			    .div_en(div_en_tmp),
			    .halt_ack(halt_ack_tmp),
			    .tdr0_wr_sel(tdr0_wr_tmp),
			    .tdr1_wr_sel(tdr1_wr_tmp),
			    .wdata_cnt(wdata_cnt_tmp),
			    .error(error),
			    .halt_reg(halt_reg));

	//instance module control_counter
	control_counter u_control_cnt(. sys_clk(sys_clk),
	       			      .sys_rst_n(sys_rst_n),
				      .dbg_mode(dbg_mode),
				      .timer_en(timer_en_tmp),
				      .div_en(div_en_tmp),
				      .div_val(div_val_tmp),
				      .halt_reg(halt_reg_tmp),
				      .halt_ack(halt_ack_tmp),
				      .count_en(count_en_tmp));


/*        //instance module interrupt
	interrupt u_interrupt(. sys_clk(sys_clk),
	       	     	      .sys_rst_n(sys_rst_n),
			      .tier_wr_sel(tier_wr_tmp),
			      .tisr_wr_sel(tisr_wr_tmp),
			      .cnt(cnt_tmp),
			      .int_en(int_en_tmp),
			      .int_st(int_st_tmp),
			      .tim_pwdata(tim_pwdata),
			      .tcmp(tcmp),
			      .tim_int(tim_int));

	//instance module counter_64bit
*/
	//instance module counter-64bit
	counter_64bit u_counter_64bit(. sys_clk(sys_clk),
	       		       	      .sys_rst_n(sys_rst_n),
				      .count_en(count_en_tmp),
				      .wdata_cnt(wdata_cnt_tmp),
				      .tdr0_wr_sel(tdr0_wr_tmp),
				      .tdr1_wr_sel(tdr1_wr_tmp),
				      .cnt(cnt_tmp));
endmodule





