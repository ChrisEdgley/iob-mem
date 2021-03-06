`timescale 1ns/1ps

module bin_counter #(parameter   COUNTER_WIDTH = 4)
   (
	input 			                rst, //Count reset.
	input 			                clk,
	input 			                en, //Count enable.
	output reg [COUNTER_WIDTH-1:0] 	data_out
	);
	   
   	always @ (posedge clk or posedge rst)
		if (rst)
		    data_out <= 0;  
		else if (en)
		    data_out <= data_out + 1'b1;
   
endmodule

module iob_sync_fifo
	#(parameter 
		DATA_WIDTH = 8, 
		ADDRESS_WIDTH = 4, 
		FIFO_DEPTH = (1 << ADDRESS_WIDTH),
		USE_RAM = 1
	)
	(
	input                       rst,
	input                       clk,
	
	output reg [31:0] 			fifo_ocupancy,				

	//read port
	output [DATA_WIDTH-1:0] 	data_out, 
	output		                empty,
	input                       read_en,

	//write port	 
	input [DATA_WIDTH-1:0]      data_in, 
	output		                full,
	input                       write_en
	);

	//WRITE DOMAIN 
	wire [ADDRESS_WIDTH-1:0]    wptr;
	wire                        write_en_int;
	
	//READ DOMAIN    
	wire [ADDRESS_WIDTH-1:0]    rptr;
	wire                        read_en_int;


	always @ (posedge clk or posedge rst)
		if (rst)
			fifo_ocupancy <= 0;
		else if (write_en_int & !read_en_int)
			fifo_ocupancy <= fifo_ocupancy+1;
		else if (read_en_int & !write_en_int)
			fifo_ocupancy <= fifo_ocupancy-1;

	//WRITE DOMAIN LOGIC
	//effective write enable
	assign write_en_int = write_en & ~full;
	assign full = (fifo_ocupancy == FIFO_DEPTH);
    
	bin_counter #(ADDRESS_WIDTH) wptr_counter (
	   	.clk(clk),
	   	.rst(rst), 
	   	.en(write_en_int),
	   	.data_out(wptr)
	);

	//READ DOMAIN LOGIC
	//effective read enable
	assign read_en_int  = read_en & ~empty;
	assign empty = (fifo_ocupancy == 0);
   
	bin_counter #(ADDRESS_WIDTH) rptr_counter (
	   	.clk(clk),
	   	.rst(rst), 
		.en(read_en_int),
	   	.data_out(rptr)
	);
	
	
	//FIFO memory
	iob_2p_mem #(
		.DATA_W(DATA_WIDTH), 
		.ADDR_W(ADDRESS_WIDTH),
		.USE_RAM(USE_RAM)
	) fifo_mem (
		.clk(clk),
		.w_en(write_en_int),
		.data_in(data_in),
		.w_addr(wptr),
		.r_addr(rptr),
		.r_en(read_en_int),
		.data_out(data_out)
	);

endmodule
   

