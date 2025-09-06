`timescale 1us/1ns

module tb;
  
  parameter ADDR_WIDTH =4,DATA_WIDTH=16, TEST_COUNT=15;
    
  reg 						wr_rst_i;
  reg 						wr_clk_i=0;
  reg 						wr_en_i;
  reg  [DATA_WIDTH-1:0]	wr_data_i;
  reg 						rd_rst_i;
  reg 						rd_clk_i=0;
  reg 						rd_en_i;
  wire  [DATA_WIDTH-1:0]	rd_data_o;
  wire 						full_o;
  wire 						empty_o;
  
  dual_clock_fifo #(ADDR_WIDTH,DATA_WIDTH) temp
  ( wr_rst_i,wr_clk_i,wr_en_i,wr_data_i,
	rd_rst_i,rd_clk_i,rd_en_i,rd_data_o,
	full_o,empty_o);
  
  ///// CLOCK
  always #0.5 wr_clk_i = ~wr_clk_i;
  always #1   rd_clk_i = ~rd_clk_i;
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(1);
    wr_rst_i =1; 
    rd_rst_i=1; // Assert reset
    wr_en_i=0; 
    rd_en_i=0;
    
    repeat (3) @(posedge wr_clk_i);
    wr_rst_i = 0;
    repeat (3) @(posedge rd_clk_i);
    rd_rst_i = 0;
    
    // Write 
    for(int i=0; i<TEST_COUNT; i++)begin
      @(posedge wr_clk_i);
      wr_en_i =1;  
      wr_data_i=i+1;
    end
    @(posedge wr_clk_i) wr_en_i = 0;
    
    // Read
    repeat (5) @(posedge rd_clk_i);
    rd_en_i = 1;
    repeat (TEST_COUNT) @(posedge rd_clk_i);
    rd_en_i = 0;
    
    repeat (5) @(posedge rd_clk_i);
    $finish;
  end
    
  always @(posedge rd_clk_i)
      $display("Time=%0t | rd_data_o=%0d | empty=%b | full=%b", $time, rd_data_o, empty_o, full_o);

endmodule
