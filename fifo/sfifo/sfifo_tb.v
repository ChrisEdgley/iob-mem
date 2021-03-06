`timescale 1ns / 1ps

module sfifo_tb;
	
	//Inputs
	reg clk;
    reg reset;
   	reg [7:0] data_in;
   	reg read;
   	reg write;
   	
   	//Ouptuts
   	wire [7:0] data_out;
   	wire empty_out;
   	wire full_out;

    integer i;
    

    initial begin
    
    	$dumpfile("sfifo.vcd");
    	$dumpvars();
    	
    	//Initialize Inputs
        clk = 1;
        reset = 0;
        data_in = 0;
        read = 0;
        write = 0;
        
         //Write all the locations of FIFO
   		#10;
        @(posedge clk) #1; 
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        
        @(posedge clk) #1;
       
		for(i=1; i <= 16; i = i + 1) begin
        	 write = 1;
			data_in = i;
			@(posedge clk) #1;
		end
       
       @(posedge clk) #1;
       write = 0; //Fifo is now full
        
        #10
        @(posedge clk) #1;
        read=1;
        //Read all the locations of RAM. 
		for(i=1; i <= 16; i = i + 1) begin
			//Result will only be available in the next cycle
			@(posedge clk) #1;
		end
		@(posedge clk) #1;
		read = 0; //Fifo is now empty
        #50 $finish;
    end

   	// Instantiate the Unit Under Test (UUT)
    iob_sync_fifo #(
    	.DATA_WIDTH(8), 
    	.ADDRESS_WIDTH(4),
    	.USE_RAM(0)
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
    
	always #5 clk = ~clk; 

endmodule // sfifo_tb


