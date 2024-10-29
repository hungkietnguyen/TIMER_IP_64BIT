`timescale 1ns /1ps
module test_bench;
	parameter ADDR_TCR      =  12'h00;
        parameter ADDR_TDR0     =  12'h04;
        parameter ADDR_TDR1     =  12'h08;
        parameter ADDR_TCMP0    =  12'h0C;
        parameter ADDR_TCMP1    =  12'h10;
        parameter ADDR_TIER     =  12'h14;
        parameter ADDR_TISR     =  12'h18;
        parameter ADDR_THCSR    =  12'h1C;

	//signal
	reg sys_clk;
	reg sys_rst_n;
	reg [11:0] tim_paddr;
        reg tim_pwrite;
        reg tim_psel;
        reg tim_penable;
        reg [31:0] tim_pwdata;
        wire tim_pready;
        wire [31:0] tim_prdata;
        wire tim_int;
        wire tim_pslverr;
        reg  dbg_mode;
        reg [3:0] tim_pstrb;

        timer_top u_top(.*);
	//`include "run_test.v"
	initial begin
		sys_clk = 0;
		forever #2.5 sys_clk = ~sys_clk; //200Mhz
	end
	//task reset
	task reset;
	  begin
		sys_rst_n = 0;
		#10;
		sys_rst_n = 1;
	end
       endtask

	//task ini
	task ini;
	  begin
		sys_clk         = 0;
                tim_psel        = 0;
                tim_paddr       = 0;
                tim_pwrite      = 0;
                tim_penable     = 0;
                tim_pwdata      = 32'h0000_0000;
                dbg_mode        = 0;
                tim_pstrb       = 4'b0000;
	  end
        endtask
	// WRITE TASk
	task write;
		input [11:0] address;
                input [31:0] data;
                input [3:0] strb;

		begin
			@(posedge sys_clk);
			#1;
			tim_psel = 1;
			tim_pwrite = 1;
			tim_paddr = address;
			tim_pwdata = data;
			tim_pstrb = strb;
			//$display("t=%10d, Start write to address = %h, data = %h",$stime, address, data);
			@(posedge sys_clk);
			#1;
			tim_penable = 1'b1;
			@(posedge sys_clk);
			@(posedge sys_clk);
			#1;
			tim_penable = 1'b0;
                        tim_psel = 1'b0;

		end
	endtask
	//READ TASK
	task read;
		input [11:0] address;

		begin
			@(posedge sys_clk);
			#1;
			tim_psel = 1;
			tim_pwrite = 0;
			tim_paddr = address;
			//$display("t=%10d, Start read to addr = %h",$stime, address);
			@(posedge sys_clk);
			#1;
			tim_penable = 1;
			@(posedge sys_clk);
			@(posedge sys_clk);
			#1;
			tim_psel = 0;
			tim_penable = 0;

		  end
	  endtask

	initial begin
                ini;
                reset;
		write(ADDR_TCR,32'b00000000000000000000001100000011,4'b1111);
		read(ADDR_TCR);
	

		//run_test();


		#2000;
		$finish;

        end

endmodule
