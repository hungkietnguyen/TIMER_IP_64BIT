module interrupt (

	//input
	input wire sys_rst_n,
	input wire sys_clk,
	input wire tier_wr_sel,
	input wire tisr_wr_sel,
	input wire [3:0] tim_pstrb,
	input wire [63:0] cnt,
	input wire [31:0] tim_pwdata,
	input wire [63:0] tcmp,
	input wire int_en,
	input wire int_st,
	//output
	output wire tim_int
	);
	//register
	wire int_set;
	wire int_clr;
	reg int_en_tmp;
	reg int_st_tmp;
	//internal signal
	assign int_clr = tisr_wr_sel && ( tim_pwdata[0] == 1'b1) && tim_pstrb[0];
	assign int_set = (cnt == tcmp);

	always @(posedge sys_clk or negedge sys_rst_n)
	  begin
		  if(!sys_rst_n) begin
			  int_st_tmp <= 1'b0;
		  end
		  else begin
			  if(int_clr) begin
				  int_st_tmp <= 1'b0;
			  end
			  else begin
				  if(int_set) begin
					  int_st_tmp <= 1;
				  end
				  else
					  int_st_tmp <= int_st_tmp;
			  end
		  end
	  end
	 always @(posedge sys_clk or negedge sys_rst_n)
	   begin
		   if(!sys_rst_n) begin
			   int_en_tmp <= 1'b0;
		   end
		   else begin
			   if(tier_wr_sel) begin
				   int_en_tmp <= (tim_pstrb[0]) ? tim_pwdata[0] : int_en_tmp;
			   end
		   end
	   end
	 assign int_en  = int_en_tmp;
	 assign int_st  = int_st_tmp; 
	 assign tim_int = int_en & int_st;
	 endmodule




