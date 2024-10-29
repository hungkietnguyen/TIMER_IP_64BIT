module control_counter (
	//input
	input wire sys_clk,
	input wire sys_rst_n,
	input wire dbg_mode,

	//communicate
	input wire timer_en,
	input wire div_en,
	input wire [3:0] div_val,
	input wire halt_reg,
	output wire halt_ack,
	output wire count_en
	);
	
	//internal signal
	reg [7:0] limit;
	reg [7:0] ps_counter;
	wire tmp0;
	wire tmp1;
	wire tmp2;
	wire count_en_tmp;
	wire halt_tmp;
	always @(*) begin
		case(div_val[3:0])
			4'b0000: limit = 8'd0;
			4'b0001: limit = 8'd1;
			4'b0010: limit = 8'd3;
			4'b0011: limit = 8'd7;
			4'b0100: limit = 8'd15;
			4'b0101: limit = 8'd31;
			4'b0110: limit = 8'd63;
			4'b0111: limit = 8'd127;
			4'b1000: limit = 8'd255;
			default: limit = 8'd1;
		endcase
	end

	assign compare = (ps_counter == limit);
	assign int_rst = ~timer_en | ~div_en | compare;
	always @(posedge sys_clk or negedge sys_rst_n)
	  begin
		  if(!sys_rst_n) begin
			  ps_counter <= 8'b0;
		  end
		  else begin
			  if(dbg_mode & halt_reg) begin
				  ps_counter <= ps_counter;
			  end
		  	  else begin
			  	if(int_rst) begin
					ps_counter <= 8'b0;
			  	end
			  	else begin
					if(timer_en)
						ps_counter <= ps_counter + 1'b1;
				  	else
						ps_counter <= ps_counter;
				end
			end
		end
	end
	//halt_ack
	assign halt_ack = dbg_mode && halt_reg;
	assign tmp0 = timer_en & ~div_en;
	assign tmp1 = timer_en & div_en & (ps_counter == limit) & (div_val != 4'b0000);
	assign tmp2 = timer_en & div_en & (div_val == 4'b0000);

	assign count_en_tmp = (tmp0 | tmp1 | tmp2) && !halt_ack;
	assign count_en = count_en_tmp;

	endmodule





























