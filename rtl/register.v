module register (
	//sys signal
	input wire sys_clk,
	input wire sys_rst_n,
	input wire [63:0] cnt, //communicate counter-64bit
	input wire wr_en,//apb
	input wire rd_en,//apb
	//APB signal
	input wire [11:0] addr,
	input wire [31:0] wdata,
	input wire [3:0]  pstrb,
	output reg[31:0] rdata,
	input wire tim_pready,
	//output sys
	output reg timer_en,
	output reg [3:0] div_val,
	output reg div_en,
	input wire  halt_ack,
	output reg [63:0] tcmp, 
	output wire tdr0_wr_sel,
	output wire tdr1_wr_sel,
	output wire [31:0] wdata_cnt,
	output reg error,
	output reg halt_reg
	);
	reg  int_en;
	reg  int_st;
	wire int_set;
	wire int_clr;
	wire tier_wr_sel;
	wire tisr_wr_sel;
	wire tcr_wr_sel;
	//address register
	localparam ADDR_TCR     = 12'h00;
	localparam ADDR_TDR0    = 12'h04;
        localparam ADDR_TDR1    = 12'h08;
        localparam ADDR_TCMP0   = 12'h0C;
        localparam ADDR_TCMP1   = 12'h10;
        localparam ADDR_TIER    = 12'h14;
        localparam ADDR_TISR    = 12'h18;
        localparam ADDR_THCSR   = 12'h1C;

	//internal signal
	assign tcr_wr_sel  = (addr == ADDR_TCR)  & wr_en;
	assign tdr0_wr_sel = (addr == ADDR_TDR0) & wr_en;
	assign tdr1_wr_sel = (addr == ADDR_TDR1) & wr_en;
	assign tier_wr_sel = (addr == ADDR_TIER) & wr_en;
	assign tisr_wr_sel = (addr == ADDR_TISR) & wr_en;

	//Register write transfer
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if(!sys_rst_n) begin
			div_en   <= 1'b0;
			timer_en <= 1'b0;
			div_val  <= 4'b0001;
			tcmp     <= 64'hFFFF_FFFF_FFFF_FFFF;
			halt_reg <= 1'b0;
		end else if(wr_en) begin
			case(addr)
				ADDR_TCR: begin
					div_val           <= (pstrb[1]) ? wdata[11:8] : div_val;
					{div_en,timer_en} <= (pstrb[0]) ? wdata[7:0]  :{div_en, timer_en};
				end
				ADDR_TCMP0: begin
                                        tcmp[31:24]  <= (pstrb[3]) ? wdata[31:24] : tcmp[31:24];
					tcmp[23:16]  <= (pstrb[2]) ? wdata[23:16] : tcmp[23:16];
					tcmp[15:8]   <= (pstrb[1]) ? wdata[15:8]  : tcmp[15:8];
					tcmp[7:0]    <= (pstrb[0]) ? wdata[7:0]   : tcmp[7:0];

				end
				ADDR_TCMP1: begin
                                        tcmp[63:56]  <= (pstrb[3]) ? wdata[31:24]   : tcmp[63:56];
					tcmp[55:48]  <= (pstrb[2]) ? wdata[23:16]   : tcmp[55:48];
					tcmp[47:40]   <= (pstrb[1]) ? wdata[15:8]   : tcmp[47:40];
					tcmp[39:32]    <= (pstrb[0]) ? wdata[7:0]   : tcmp[39:32];

				end
				ADDR_TIER  : int_en <= (pstrb[0]) ? wdata[0] : int_en;
				ADDR_THCSR : halt_reg <= (pstrb[0]) ? wdata[0] : halt_reg;
			endcase
		end
	end

	//register read transfer
	always @(*)
	  begin
		  if(rd_en & tim_pready) begin
			  case(addr)
				  ADDR_TCR   : rdata = {20'b0, div_val, 6'b0, div_en, timer_en};
                                  ADDR_TDR0  : rdata = cnt[31:0];
                                  ADDR_TDR1  : rdata = cnt[63:32];
                                  ADDR_TCMP0 : rdata = tcmp[31:0];
                                  ADDR_TCMP1 : rdata = tcmp[63:32];
                                  ADDR_TIER  : rdata = {31'b0, int_en};
                                  ADDR_TISR  : rdata = {31'b0, int_st};
                                  ADDR_THCSR : rdata = {30'b0, halt_ack, halt_reg};
                                  default    : rdata = 32'h0000_0000;
                          endcase
		  end
		  else begin
			  rdata = 32'b0;
		  end
	  end
	//TDR 
	assign wdata_cnt[31:0] = (tdr1_wr_sel | tdr0_wr_sel) ? wdata[31:0] : wdata_cnt[31:0];
	//Errorr handling
	always @(*) begin
		if(wr_en || rd_en) begin
			case(addr)
				ADDR_TCR: begin
					if(tcr_wr_sel) begin
						if(wdata > 4'b1000)
							error = (pstrb[2]) ? 1'b1 : 1'b0;
						else if(timer_en) begin
							error = wdata[11:8] ^ div_val; //xor
							error = wdata[1] ^ div_en;
						end else
							error = 1'b0;
					end
				end
				ADDR_TDR0, ADDR_TDR1, ADDR_TCMP0, ADDR_TCMP1, ADDR_TIER, ADDR_TISR, ADDR_THCSR: error <= 1'b0;
				default: error <= 1'b1;
			endcase
		end else
			error <= 1'b0;
	end

	//INTERRUPT
	assign int_set = (cnt==tcmp);
	assign int_clr = tisr_wr_sel && pstrb[0] && wdata[0];
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if(!sys_rst_n) begin
			int_en <= 1'b0;
		end
		else begin
			if(tier_wr_sel) begin
				int_en <= (pstrb[0]) ? wdata[0] : int_en;
			end
		end
	end
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if(!sys_rst_n) begin
			int_st <= 1'b0;
		end
		else begin
			if(int_clr) begin
				int_st <= 1'b0;
			end
			else begin
				if(int_set) begin
					int_st <= 1'b1;
				end
				else
					int_st <= int_st;
			end
		end
	end
	assign tim_int = int_en & int_st;


	endmodule


































