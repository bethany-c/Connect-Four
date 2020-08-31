module drawScreen(
	input clk,resetn,resetb,
	input drawBoard,drawRWin,drawYWin,gameTie,en_screenCycle,
	
	output [8:0] colour,
	output [7:0] column,
	output [6:0] row,
	output reg [14:0] screenCycle);
	
	reg [7:0] colCounter; //X coordinate
	reg [6:0] rowCounter; //Y Coordinate
	reg[8:0] colourOut;
	
	wire [14:0] counter;
	reg [14:0] memAddr;
	
	wire[8:0] colourBoard;
	wire[8:0] colourRed;
	wire [8:0] colourYellow;
	wire [8:0]colourTie;

	//Instantiating RAM Modules Holding Images
	pictureboard p0(.address(memAddr),.clock(clk),.data(0),.wren(0),.q(colourBoard));
	redWin r1(.address(memAddr),.clock(clk),.data(0),.wren(0),.q(colourRed));
	yellowWin b2(.address(memAddr),.clock(clk),.data(0),.wren(0),.q(colourYellow));
	gameTie g3(.address(memAddr),.clock(clk),.data(0),.wren(0),.q(colourTie));

	//Draws 160x120 images (Fullscreen) row by row
	always@(posedge clk)
	begin
		if(!resetn || !resetb)
		begin
			colCounter <= 0;
			rowCounter <= 0;
			memAddr <= 0;
		end
		else if ((rowCounter==7'd119) && (colCounter==8'd159))
		begin
			colCounter <= 0;
			rowCounter <= 0;
			memAddr <= 0;
			colourOut <= 0;
		end
		else if (drawBoard)
		begin
			colourOut <= colourBoard;
			memAddr <= memAddr+1;
			if (colCounter < 8'd160)
			begin
				colCounter <= colCounter+1;
			end
				if (colCounter >= 8'd159 && rowCounter < 7'd120)
				begin
					rowCounter <= rowCounter + 1;
					colCounter <= 0;
				end
			end
		else if (drawRWin)
		begin
			memAddr <= memAddr + 1;
			colourOut <= colourRed;
			if (colCounter < 8'd160)
			begin
				colCounter <= colCounter + 1;
			end
				if (colCounter >= 8'd159 && rowCounter < 7'd120)
				begin
					rowCounter <= rowCounter + 1;
					colCounter <= 0;
				end
			end
		else if (drawYWin)
		begin
			memAddr <= memAddr + 1;
			colourOut <= colourYellow;
			if (colCounter < 8'd160)
			begin
				colCounter <= colCounter + 1;
			end
				if (colCounter >= 8'd159 && rowCounter < 7'd120)
				begin
					rowCounter <= rowCounter + 1;
					colCounter <= 0;
				end
			end
		else if (gameTie)
		begin
			memAddr <= memAddr + 1;
			colourOut <= colourTie;
			if (colCounter < 8'd160)
			begin
				colCounter <= colCounter+1;
			end
			if (colCounter >= 8'd159 && rowCounter < 7'd120)
			begin
				rowCounter <= rowCounter + 1;
				colCounter <= 0;
			end
		end
	end
	
	//X, Y, and Colour Info to be passed to VGA Controller
	assign column = colCounter;
	assign row = rowCounter;
	assign colour = colourOut;
	
	//Plots until entire 160x120 screen is fully drawn
	always@(posedge clk)
	begin
			if (!resetn)
				screenCycle<=15'b0;
			else if (screenCycle==15'd19199)
				screenCycle<=15'b0;
			else if (en_screenCycle==1'b1)
				screenCycle <= screenCycle + 1;
	end
endmodule