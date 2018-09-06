`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/28 16:49:18
// Design Name: 
// Module Name: ddr_ctrl_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 001 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr_ctrl_test(
  // user interface signals
	output reg [27:0]       app_addr,
	output reg [2:0]       app_cmd,
	output reg            app_en,
	input            app_rdy,
	
	output [511:0]        app_wdf_data,
	output reg            app_wdf_end,
	output [63:0]        app_wdf_mask,
	output reg            app_wdf_wren,
	
	input [511:0]       app_rd_data,
	input            app_rd_data_end,
	input            app_rd_data_valid,

	input            app_wdf_rdy,
	output         app_sr_req,
	output         app_ref_req,
	output         app_zq_req,
	input            app_sr_active,
	input            app_ref_ack,
	input            app_zq_ack,
	input            ui_clk,
	input            ui_clk_sync_rst,
	input            init_calib_complete,  
	input			sys_rst  
    );
	localparam num = 256;
	reg[31:0] cnt1;
	reg[31:0] cnt2;
	reg[511:0] wr_data;
	reg[511:0] rd_data;
	reg[1:0] mode;//mode = 0, write; mode = 1, wait; mode = 2, read;
	
	always @(posedge ui_clk, posedge sys_rst)
		if(sys_rst) begin
			mode <= 0;
			app_en <= 0;
			app_cmd <= 0;
			app_addr <= 0;
			cnt1 <= 0 ;cnt2 <= 0;
			wr_data <= 0;
			
		end
		else if(init_calib_complete)
			case(mode)
			0: begin
				app_en <= 1;
				app_cmd <= 0;
				app_wdf_end <= 1;
				app_wdf_wren <= 1;
				if(cnt1 < num && app_rdy) begin
					app_addr <= cnt1 * 8;
					cnt1 <= cnt1 + 1;
				end
				if(cnt2 < num && app_wdf_rdy) begin
					wr_data <= cnt2;
					cnt2 <= cnt2 + 1;
				end
				if(cnt2 == num) begin
					app_wdf_wren <= 0;
					app_wdf_end <= 0;
				end
				if(cnt1 == num && cnt2 == num) begin
					mode <= 1;
					app_en <= 0;
					app_cmd <= 1;
					cnt1 <= 0;
					cnt2 <= 0;
				end	
			end
			1: begin
				cnt1 <= cnt1 + 1;
				if(cnt1 == 20) begin 
					mode <= 2;
					cnt1 <= 0; 
					cnt2 <= 0;
				end
			end
			2: begin
				app_en <= 1; 
				app_cmd <= 1;
				if( cnt1 < num && app_rdy == 1) begin
					app_addr <= cnt1 * 8;
					cnt1 <= cnt1 + 1;
				end
				if( app_rd_data_valid == 1) begin
					rd_data <= app_rd_data;
				end	
				if(cnt1 == num) begin
					app_en <= 0;
					mode <= 3;
					cnt1 <= 0;
				end
			end
			3: begin
				cnt1 <= cnt1 + 1;
				if(cnt1 == 30) begin 
					mode <= 0;
					cnt1 <= 0;
				end
			end
			endcase



	assign app_wdf_data = wr_data;
	assign app_wdf_mask = 0;
	assign app_sr_req = 0;
	assign app_ref_req = 0;
	assign app_zq_req = 0;
endmodule
