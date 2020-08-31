//TOP MODULE
module connectFour(
		CLOCK_50,						//	On Board 50 MHz
		// INPUTS 
		KEY,
		SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,				   //	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,	
		PS2_CLK,PS2_DAT
);
	
	//KEYBOARD
	inout	PS2_DAT;
	inout	PS2_CLK;
	
	//CLOCK
	input	CLOCK_50; //50 MHz
	wire clk;
	assign clk = CLOCK_50;
	
	//USER INPUTS
	input	[3:0]	KEY;	
	input [7:0] SW;
	
	//VGA OUTPUTS
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	//USER INPUTS - BUTTONS USED
	//RESET - ACTIVE LOW
	wire resetn;
	assign resetn = KEY[0];
	
	//ENTER KEY - START/REPLAY
	wire start;
	//assign enter = ~KEY[1];
	
	wire resetb;
	//assign resetb = KEY[2];
	
	//DROP - SPACEBAR
	wire drop;
	//assign drop = ~KEY[3];
	
	//COLUMN INPUTS BY USER - SW[7:0]
	wire [6:0] Column;
	assign Column = SW[7:1];
	
	//Create the colour, x, y and writeEn wires that are inputs to the VGA controller
	wire [8:0] colour;
	wire [7:0] column;
	wire [6:0] row;
	wire writeEn; //Took out plot
	
	//*******************KEYBOARD*********************
	//KEYBOARD OUTPUTS FROM PS2 CONTROLLER
	wire [7:0] keyboardData;
	wire keyPress;
	
	//Registers for Keyboard
	reg enterKey;
	reg resetKey;
	reg spacebarKey;
	
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50(CLOCK_50),
	.reset(~KEY[0]),

	// InOuts
	.PS2_CLK(PS2_CLK),
 	.PS2_DAT(PS2_DAT),

	// Outputs
	.received_data(keyboardData),
	.received_data_en(keyPress)
   );

	
	always @(posedge clk)
	begin
	if (!resetn) //Active Low Reset
		begin
			enterKey <= 0;
			resetKey <= 1;
			spacebarKey <= 0;
		end
	//If user pressed a key on the keyboard...
	else if (keyPress)
		begin
			//If user pressed SPACEBAR key...
			if (keyboardData == 8'b00101001)
				spacebarKey <= 1;
			//If user pressed ENTER key...
			else if (keyboardData == 8'b01011010)
				enterKey <= 1;
			//If user pressed BACKSPACE key...
			else if(keyboardData == 8'b01100110)
				resetKey<=0;
		end
	//No relevant keys pressed
	else if (keyboardData == 8'b11110000 && !keyPress)
		begin
			enterKey <= 0;
			resetKey <= 1;
			spacebarKey <= 0;
		end
	end
	
	//Assign Keys
	assign start = enterKey;
	assign drop = spacebarKey;
	assign resetb = resetKey;
	//*******************KEYBOARD*********************
	
	//**************************VGA**********************************
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(column),
			.y(row),
			.plot(writeEn),
	
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
			
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "mainscreen.mif";
	//**************************VGA**********************************
		
	Game g0(.clk(clk),.resetn(resetn),.resetb(resetb),.start(start),.drop(drop),.Column(Column),.colOut(column),.rowOut(row),.colourOut(colour),.writeEn(writeEn)); //Removed drawWin
		
endmodule

module Game(
	input clk,resetn,resetb,start,drop,
	input [6:0] Column,
	
	output [7:0] colOut,
	output [6:0] rowOut,
	output [8:0] colourOut,
	output writeEn
); //Removed drawWin

	//Wires for Enable Signals
	wire r_a,r_b,r_c,r_d,r_e,r_f,r_g; //Red Board State
	wire y_a,y_b,y_c,y_d,y_e,y_f,y_g; //Yellow Board State
	wire c_a,c_b,c_c,c_d,c_e,c_f,c_g; //Combined Board State
	wire en_chipCycle,en_screenCycle; //Cycle for drawing Chips and Full Screen Images
	wire drawr,drawy,checkRed,checkYellow,plot,drawBoard,drawRWin,drawYWin; //Plotting
	wire gameTie,RWin,YWin; //End Game States
	wire gameTieSignalW;
	
	
	
	//Wire for X and Y
	wire [7:0] colMoveChip;
	wire [6:0] rowMoveChip;
	
	//Wire for each Player's Board State
	wire [41:0] redBoard;
	wire [41:0] yellowBoard;
	
	//Wire for Drawing Cycles
	wire[8:0] chipCycle;
	wire[14:0] screenCycle;
	
	//Wire for Win
	wire win;
	
	//Wires for X, Y and Colour - For Chip
	wire [7:0] colChip;
	wire [6:0] rowChip;
	wire [8:0] colourChip;
	
	//Wires for X, Y and Colour - For Screen
	wire [7:0] colScreen;
	wire [6:0] rowScreen;
	wire [8:0] colourScreen;
	
	//Wire for Total Pieces on Board
	wire [5:0] chipCounter;

	//call gameControl
	gameControl g0(.clk(clk),.resetn(resetn),.resetb(resetb),.start(start),.drop(drop),.Column(Column),.chipCycle(chipCycle),
	.screenCycle(screenCycle),
	.RWin(RWin),
	.YWin(YWin),
	.win(win),
	.chipCounter(chipCounter),
	.r_a(r_a),.r_b(r_b),.r_c(r_c),.r_d(r_d),.r_e(r_e),.r_f(r_f),.r_g(r_g),
	.y_a(y_a),.y_b(y_b),.y_c(y_c),.y_d(y_d),.y_e(y_e),.y_f(y_f),.y_g(y_g),
	.c_a(c_a),.c_b(c_b),.c_c(c_c),.c_d(c_d),.c_e(c_e),.c_f(c_f),.c_g(c_g),
	.en_chipCycle(en_chipCycle),.drawr(drawr),.drawy(drawy),.checkRed(checkRed),.checkYellow(checkYellow),
	.drawBoard(drawBoard),.drawRWin(drawRWin),.drawYWin(drawYWin),.gameTie(gameTie),.en_screenCycle(en_screenCycle),.writeEn(plot)
	);

	drawScreen d1(
	.clk(clk),
	.resetn(resetn),.resetb(resetb), .drawBoard(drawBoard),.drawRWin(drawRWin),.drawYWin(drawYWin),.gameTie(gameTie),.en_screenCycle(en_screenCycle),
	.column(colScreen),.row(rowScreen),.colour(colourScreen),.screenCycle(screenCycle));

	
	board b2(
	.clk(clk),
	.resetn(resetn),.resetb(resetb),
	.r_a(r_a),.r_b(r_b),.r_c(r_c),.r_d(r_d),.r_e(r_e),.r_f(r_f),.r_g(r_g),
	.y_a(y_a),.y_b(y_b),.y_c(y_c),.y_d(y_d),.y_e(y_e),.y_f(y_f),.y_g(y_g),
	.c_a(c_a),.c_b(c_b),.c_c(c_c),.c_d(c_d),.c_e(c_e),.c_f(c_f),.c_g(c_g),
	.column(colMoveChip),.row(rowMoveChip),.redBoard(redBoard),.yellowBoard(yellowBoard),.boardcounter(chipCounter));

	drawchip d3(
	.clk(clk),.resetn(resetn),
	.colin(colMoveChip),.rowin(rowMoveChip),.cycle(chipCycle),
	.drawr(drawr),.drawb(drawy),.en_cycle(en_chipCycle),
	.colout(colChip),.rowout(rowChip),.colour(colourChip),.outcycle(chipCycle));

	winCondition g5(
	.clk(clk),.resetn(resetn),.resetb(resetb),
	.red(redBoard),.yellow(yellowBoard),
	.checkRed(checkRed),.checkYellow(checkYellow),
	.redWin(RWin),.yellowWin(YWin),.win(win));
	
	//Register for Final VGA Inputs
	reg [7:0] colFinal;
	reg [6:0] rowFinal;
	reg [8:0] colourFinal;

	always@(posedge clk)
	begin
		//If reset is pressed...
		if (!resetb || !resetn)
			begin
				colFinal <= 0;
				rowFinal <= 0;
				colourFinal <= 0;
			end
		//Drawing a chip
		else if (drawr || drawy)
		begin
			colFinal <= colChip;
			rowFinal <= rowChip;
			colourFinal <= colourChip;
		end
		//Drawing entire image on screen
		else if (drawBoard || drawRWin || drawYWin)
		begin
			colFinal <= colScreen;
			rowFinal <= rowScreen;
			colourFinal <= colourScreen;
		end
	end
	
	//Final VGA Inputs
	assign writeEn = plot;
	assign colOut = colFinal;
	assign rowOut = rowFinal;
	assign colourOut = colourFinal;
	
	//assign drawwin=drawredwin + drawbluewin;

endmodule

