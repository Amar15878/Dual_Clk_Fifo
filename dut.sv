// Author- Amar
// DUAL CLOCK FIFO -------- CLK for Read anad Write

module dual_clock_fifo #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 16)
(
	input wire 						wr_rst_i,
	input wire 						wr_clk_i,
	input wire 						wr_en_i,
	input wire  [DATA_WIDTH-1:0]	wr_data_i,

	input wire 						rd_rst_i,
	input wire 						rd_clk_i,
	input wire 						rd_en_i,
	output reg  [DATA_WIDTH-1:0]	rd_data_o,

	output reg 						full_o,
	output reg 						empty_o
);
  /////////////////////////////////////////////
  
  //////// SIGNALS  
  reg [ADDR_WIDTH-1:0] wptr_add;		// To write
  reg [ADDR_WIDTH-1:0] wptr_add_gr;		// For Flag -|
  reg [ADDR_WIDTH-1:0] wptr_add_grr;	// For Flag  |-Metastability
  reg [ADDR_WIDTH-1:0] wptr_add_grrr;	// For Flag -|
  
  reg [ADDR_WIDTH-1:0] rptr_add;		// To Read	
  reg [ADDR_WIDTH-1:0] rptr_add_gr;		// For Flag -|
  reg [ADDR_WIDTH-1:0] rptr_add_grr;	// For Flag  |-Metastability
  reg [ADDR_WIDTH-1:0] rptr_add_grrr;   // For Flag -|
  
  
  
  ///// MEMORY
  
  reg [DATA_WIDTH-1:0] fifo[(1<<ADDR_WIDTH)-1:0];
  
  
  ///////////////       FUNCTION   ---  " convert_to_gray "
  //##### Gray Code is a good choice as only 1 bit changes in transition and works seemlessly with 2 FF sync, Also its easy to convert from and to binary
  
  function [ADDR_WIDTH-1:0] convert_to_gray; 
    input [ADDR_WIDTH-1:0] input_add;
    begin
      convert_to_gray = { input_add[ADDR_WIDTH-1], 
         input_add[ADDR_WIDTH-2:0]^input_add[ADDR_WIDTH-1:1]};
  	end
  endfunction
  
  
  //////////////////  WRITE  //////////////////
  
  // Write data to fifo
  always@(posedge wr_clk_i)begin
    if(wr_en_i && !full_o) begin
      fifo[wptr_add] <= wr_data_i;
    end
  end
  
  // Pointer Inc
  always@(posedge wr_clk_i)begin
    if(wr_rst_i) begin
      wptr_add <= 0;
      wptr_add_gr <=0;
    end
    else if(wr_en_i && !full_o) begin
      //fifo[wptr_add] <= wr_data_i;
      wptr_add       <= wptr_add +1'b1;
      wptr_add_gr    <= convert_to_gray(wptr_add);
    end
  end
  
  //// Flag logic
  always@(posedge wr_clk_i)begin
    if(wr_rst_i) begin
      full_o <= 1'b0;
    end
    else begin
      // if we were to accept a write, would we collide?
      full_o <= (convert_to_gray(wptr_add + 1'b1) == {~rptr_add_grrr[ADDR_WIDTH:ADDR_WIDTH-1], rptr_add_grrr[ADDR_WIDTH-2:0]});
    end
  end
  
  //// Metastability - Synchronize read Gray into write domain (2-FF)
  always@(posedge wr_clk_i)begin
    if(!wr_rst_i)begin
    rptr_add_grr  <= rptr_add_gr;
    rptr_add_grrr <= rptr_add_grr;
  end
  end

  /////////////////   READ  ///////////////////
  
  // Read data from fifo
  always@(posedge rd_clk_i) begin
    if(rd_rst_i)      rd_data_o <= '0;
    else if (rd_en_i && !empty_o) rd_data_o <= fifo[rptr_add];
  end
  
  //// Flag logic
  always@(posedge rd_clk_i) begin
    if(rd_rst_i)begin
      empty_o <= 1;
    end
    else if(rd_en_i && !empty_o) begin
      empty_o <= (convert_to_gray(rptr_add+1) == wptr_add_grrr);
      end
      else begin
        empty_o <= (convert_to_gray(rptr_add) == wptr_add_grrr);
      end
    end
  
  // Pointer Inc
  always@(posedge rd_clk_i)begin
    if(rd_rst_i) begin
      rptr_add <= 0;
      rptr_add_gr <=0;
    end
    else if(rd_en_i && !empty_o) begin
      //rd_data_o   <= fifo[rptr_add];
      rptr_add 	  <= rptr_add +1'b1;
      rptr_add_gr <= convert_to_gray(rptr_add +1'b1);
    end
  end
  
  //// Metastability
  always@(posedge rd_clk_i)begin
    if(!wr_rst_i)begin
    wptr_add_grr  <= wptr_add_gr;
    wptr_add_grrr <= wptr_add_grr;
  end
  end
  
  //////////////////////////////////////////////
  
endmodule
