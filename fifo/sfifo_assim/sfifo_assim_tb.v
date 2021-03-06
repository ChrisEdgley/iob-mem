`timescale 1ns / 1ps

module sfifo_assim_tb;
	
	//Inputs
	reg clk;
    reg reset;
   	reg [31:0] data_in;
   	reg read;
   	reg write;
   	
   	//Ouptuts
   	wire [7:0] data_out;
   	wire empty_out;
   	wire full_out;

    integer i;
    
   	// Instantiate the Unit Under Test (UUT)
    iob_sync_assim_fifo #(
    	.W_DATA_W(32), 
    	.W_ADDR_W(2),
    	.R_DATA_W(8),
    	.R_ADDR_W(4)
	) uut (
		.clk(clk), 
		.rst(reset), 
		.data_in(data_in), 
		.data_out(data_out), 
		.empty(empty_out), 
		.read_en(read), 
		.full(full_out), 
		.write_en(write)
	);
    
	always
		#5 clk = ~clk; 

    initial begin
    
    	$dumpfile("sfifo_assim.vcd");
    	$dumpvars();
    	
    	//Initialize Inputs
        clk = 0;
        reset = 0;
        data_in = 0;
        read = 0;
        write = 0;
        
   		@(posedge clk) #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
         //Write all the locations of FIFO
		for(i=0; i < 4; i = i + 1) begin
        	write = 1;
			data_in[7:0] = i*4;
			data_in[15:8] = i*4+1;
			data_in[23:16] = i*4+2;
			data_in[31:24] = i*4+3;
			@(posedge clk) #1;
		end
        write = 0; //Fifo is now full
        
        //Read all the locations of RAM. 
		for(i=0; i < 16; i = i + 1) begin
        	 read=1;
        	 @(posedge clk) #1;
		end
		read = 0; //Fifo is now empty
        #50 $finish;
    end


endmodule // sfifo_assim_tb


