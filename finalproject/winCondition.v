`timescale 1ns / 1ns
module winCondition(
	input clk,resetn,resetb, //Active Low
	input [41:0] red, //Location of Red Chip on Board
	input [41:0] yellow, //Location of Yellow Chip on Board
	input checkRed,checkYellow,
	
	output redWin,yellowWin,win); //Output if anyone has won and who won

	reg redRowWin,redColWin,redWinDiag1,redWinDiag2; //Win conditions for Red
	reg yellowRowWin,yellowColWin,yellowWinDiag1,yellowWinDiag2; //Win conditions for Yellow
	integer i; //Counter to count in for loop to check all the spots for win conditions
	
	
	//RED WIN CONDITIONS
	//Check for Row wins
	always@(posedge clk)
	begin 
		if(!resetn || !resetb) //When reset is hit...
			redRowWin<=0; //Set it to 0
		else if(checkRed) //Checks if position being checked is chosen is Red - Enable Signal
		begin
			if (!redRowWin) //If Red hasn't had a Row Win Condition yet... - Enable Signal
			begin
				for(i=0;i<=38;i=i+1) //38 because it is the last possible value of i without running off the edge
				begin
					if ((i<=3) || (i>=7 && i<=10) || (i>=14 && i<=17) || (i>=21 && i<=24) || (i>=28 && i<=31) || (i>=35))
					//Shift down one everytime 4 consecutive spots are checked
					begin
						if ((red[i]&red[i+1]&red[i+2]&red[i+3])) //Check to find consecutive Red pieces
						begin
							redRowWin<=1; //Red has a Row Win
						end
					end
				end
			end
		end
	end
	//Check for Col wins
	always@(posedge clk)
	begin 
		if(!resetn || !resetb)//When reset is hit...
			redColWin<=0; //Set it to 0
		else if(checkRed)
		begin
			if(!redColWin)
			begin
				for(i=0;i<=20;i=i+1) //20 is the last value that can be checked for a col win
				begin
					if ((red[i]&red[7+i]&red[14+i]&red[21+i]))
					begin	
						redColWin<=1;
					end
				end
			end
		end
	end
	//Diagonal #1 - Top Right to Bottom Left
	always@(posedge clk)
	begin 
		if(!resetn || !resetb)//When reset is hit...
			redWinDiag1<=0; //Set it to 0
		else if(checkRed)
		begin
			if (!redWinDiag1)
			begin
				for(i=0;i<=20;i=i+1) //20 is the last possible position for this diagonal win condition
				begin
					if (i==20 || i==13 || i==19 || i==6 || i==12 || i==18 || i==11 || i==5 || i==17 || i==4 || i==10 || i==3)
					begin
						if ((red[i]&red[6+i]&red[12+i]&red[18+i]))
						begin	
							redWinDiag1<=1;
						end
					end					
				end
			end
		end
	end
	//Diagonal #2 - Top Left to Bottom Right
	always@(posedge clk)
	begin 
	if(!resetn || !resetb)//When reset is hit...
			redWinDiag2<=0; //Set it to zero
	else if(checkRed)
	begin
			if (!redWinDiag2)
			begin
				for(i=0;i<=17;i=i+1) //17 is the last possible position for this diagonal win condition
				begin
					if (i==14 || i==7 || i==15 || i==0 || i==8 || i==16 || i==1 || i==9 || i==17 || i==2 || i==10 || i==3)
					begin
						if ((red[i]&red[8+i]&red[16+i]&red[24+i]))
							redWinDiag2<=1;
					end					
				end
			end
		end
	end
	
	//YELLOW CONDITIONS
	//Check for Row wins	
	always@(posedge clk)
	begin 
		if(!resetn || !resetb)//When reset is hit...
			yellowRowWin<=0; //Set it to 0
		else if(checkYellow)
		begin
			if (!yellowRowWin)
			begin
				for(i=0; i<=38; i = i+1)//38 because it is the last possible value of i without running off the edge
				begin
					if (( i<=3) || (i>=7 && i<=10) || (i>=14 && i<=17) || (i>=21 && i<=24) || (i>=28 && i<=31) || (i>=35))
					begin
						if ((yellow[i]&yellow[1+i]&yellow[2+i]&yellow[3+i]))
						//Shift down one everytime 4 consecutive spots are checked
						begin
							yellowRowWin <= 1;
						end
					end
				end
			end
		end
	end
	//Check for Col wins
	always@(posedge clk)
	begin 
		if(!resetn || !resetb)
			yellowColWin <= 0; //set it to 0
		else if(checkYellow)
		begin
			if(!yellowColWin)
			begin
				for(i=0; i<=20; i = i+1) //20 is the last value that can be checked for a col win
				begin
					if ((yellow[i]&yellow[7+i]&yellow[14+i]&yellow[21+i]))
					begin
							yellowColWin <= 1;
					end
				end
			end
		end
	end
	//Diagonal #1 - Top Right to Bottom Left
	always@(posedge clk)
	begin 
		if(!resetn || !resetb)
			yellowWinDiag2 <= 0; //set it to 0
		else if(checkYellow)
		begin
			if (!yellowWinDiag2)
			begin
				for(i=0; i<=20; i = i+1) //20 is the last for this diagonal pattern
				begin
					if (i==20 || i==13 || i==19 || i==6 || i==12 || i==18 || i==5 || i==11 || i==17 || i==4 || i==10 || i==3)
					begin
						if ((yellow[i]&yellow[6+i]&yellow[12+i]&yellow[18+i]))
						begin
							yellowWinDiag2<=1;
						end
					end
				end
			end
		end
	end
	
	//Diagonal #2 - Top Left to Bottom Right
	always@(posedge clk)
	begin 
		if(!resetn || !resetb)
			yellowWinDiag1<=0;
		else if(checkYellow)
		begin
			if (!yellowWinDiag1)
			begin
				for(i=0;i<=17;i=i+1) //17 is the last possible position for this diagonal win condition
				begin
					if (i==14 || i==7 || i==15 || i==0 || i==8 || i==16 || i==1 || i==9 || i==17 || i==2 || i==10 || i==3)
					begin
						if ((yellow[i]&yellow[8+i]&yellow[16+i]&yellow[24+i])== 4)
						begin
							yellowWinDiag1<=1;
						end
					end					
				end
			end
		end
	end
		
	assign redWin=redRowWin+redColWin+redWinDiag1+redWinDiag2;
	assign yellowWin=yellowRowWin+yellowColWin+yellowWinDiag1+yellowWinDiag2;
	assign win=redWin+yellowWin;
endmodule