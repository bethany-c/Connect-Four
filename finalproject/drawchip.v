module drawchip(
	input clk,resetn,
	input [7:0] colin,
	input [6:0] rowin,
	input [8:0] cycle,
	input en_cycle,drawr,drawb,

	output [7:0] colout,
	output [6:0] rowout,
	output [8:0] colour,
	output reg [8:0] outcycle);
	
	
	reg [7:0] counter;
	reg [8:0] memAddrRed;
	reg [8:0] memAddrYellow;
	reg [8:0] c;
	wire[8:0] colourRed;
	wire[8:0] colourYellow;
	
	//Draws red and yellow chip
	yellowDot b0(.address(memAddrYellow),.clock(clk),.data(0),.wren(0),.q(colourYellow));
	reddot  r1(.address(memAddrRed),.clock(clk),.data(0),.wren(0),.q(colourRed));
	
	//Outputs each pixel of the selected image
	always@(posedge clk)begin
	if (!resetn)begin
	memAddrRed<=0;
	memAddrYellow<=0;
	counter<=0;
	c<=0;
	end
	else if(counter==9'd256)begin
	memAddrRed<=0;
	memAddrYellow<=0;
	counter<=0;
	end
	else if (drawr)begin
	memAddrRed<=memAddrRed+1;
	counter<=counter+1;
	c<=colourRed;
	end
	else if (drawb)begin
	memAddrYellow<=memAddrYellow+1;
	counter<=counter+1;
	c<=colourYellow;
	end
	end
	
	//Assigns x and y coordinates
	//Assigns colour of pixel
	assign colout=colin+counter[3:0];
	assign rowout=rowin+counter[7:4];
	assign colour=c;
	
	//If enable is on, increment.
	//Reset the count when entire 16x16 image has been plotted or when reset has been pressed.
	always@(posedge clk)begin
			if (!resetn)
				outcycle<=9'b0;
			else if (outcycle==9'd255)
				outcycle<=9'b0;
			else if (en_cycle==1'b1)
				outcycle<=outcycle+1;
		end
endmodule