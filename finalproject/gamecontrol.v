module gameControl(
	input clk,resetn,resetb,
	input [6:0] Column,
	input [8:0] chipCycle,
	input [14:0] screenCycle,
	input start,drop,RWin,YWin,win,
	input [5:0] chipCounter,

	output reg r_a,r_b,r_c,r_d,r_e,r_f,r_g,
	output reg y_a,y_b,y_c,y_d,y_e,y_f,y_g,
	output reg c_a,c_b,c_c,c_d,c_e,c_f,c_g,
	output reg en_chipCycle,drawr,drawy,writeEn,checkRed,checkYellow,drawBoard,drawRWin,drawYWin,gameTie,en_screenCycle
);
	
	//State Registers
	reg[5:0] current_state,next_state;
	
	//State Parameters
	localparam  S_START=5'd0, //Starts the Game
					S_START_WAIT=5'd1, //Waits for Release
					S_CHOOSE_R=5'd2,
					S_CHOOSE_Y=5'd3,
					S_R_TURN=5'd4, //Red's Turn
					S_R_WAIT=5'd5, //Waits for button to be released
					S_R_LOAD=5'd6, //Loads columns in Red's Board
					S_R_DRAW=5'd7, //Plots Red Chip
					S_CHECK_R=5'd8, //Checks for Red's Win Condition
					S_Y_TURN=5'd9, //Yellow's Turn
					S_Y_WAIT=5'd10, //Waits for button to be released
					S_Y_LOAD=5'd11, //Loads columns in Yellow's Board
					S_Y_DRAW=5'd12, //Plots Yellow Chip
					S_CHECK_Y=5'd13, //Checks for Yellow's Win Condition
					S_GAME_OVER=5'd14, //Game Over
					S_UPDATE_R=5'd15, //Determines if the Game is Over or Not
					S_UPDATE_Y=5'd16, //Determines if the Game is Over or Not
					S_DRAW_BOARD=5'd17, //Plots the GameBoard
					S_DRAW_MESSAGE=5'd18, //Plots End Game State Message
					S_GAME_OVER_WAIT=5'd19, //Waits for button to be released
					S_Y_LOAD_C=5'd20, //Loads columns in Combined Board
					S_R_LOAD_C=5'd21, //Loads columns in Combined Board
					S_GAME_TIE = 5'd22; //game tie condition
	
	//State Table
	always @(*)
	begin: state_table
	case(current_state)
	
//	S_START: next_state = start ? S_START_WAIT:S_START;
//	S_START_WAIT: next_state = start ? S_START_WAIT:S_DRAW_BOARD;
	S_DRAW_BOARD: next_state = (screenCycle==15'd19199 && start) ? S_R_TURN:S_DRAW_BOARD; //Game Board (Full Screen) - 160 x 120 = 19200 Pixels - 1 - DownCounter
	S_R_TURN: next_state = drop ? S_R_WAIT:S_R_TURN;
	S_R_WAIT: next_state = drop ? S_R_WAIT:S_R_LOAD;
	S_R_LOAD: next_state = S_R_LOAD_C;
	S_R_LOAD_C: next_state = S_R_DRAW;
	S_R_DRAW: next_state = (chipCycle==9'd255) ? S_CHECK_R:S_R_DRAW; //Game Chip - 16x16 Pixels = 256 Pixels - 1 - DownCounter
	S_CHECK_R: next_state = S_UPDATE_R;
	S_UPDATE_R :next_state = win ? S_DRAW_MESSAGE:S_Y_TURN; //Check for Win - If Red Wins - Game Over - If Not - Yellow's Turn
	S_Y_TURN: next_state = drop ? S_Y_WAIT:S_Y_TURN;
	S_Y_WAIT: next_state = drop ? S_Y_WAIT:S_Y_LOAD;
	S_Y_LOAD: next_state = S_Y_LOAD_C;
	S_Y_LOAD_C:next_state = S_Y_DRAW;
	S_Y_DRAW: next_state = (chipCycle==9'd255) ? S_CHECK_Y:S_Y_DRAW; //Game Chip - 16x16 Pixels = 256 Pixels - 1 - DownCounter
	S_CHECK_Y: next_state = S_UPDATE_Y;
	S_UPDATE_Y: next_state = win ? S_DRAW_MESSAGE:S_R_TURN;
	S_GAME_OVER: next_state = start ? S_GAME_OVER_WAIT:S_GAME_OVER;
	S_GAME_OVER_WAIT: next_state= start ? S_GAME_OVER_WAIT:S_DRAW_MESSAGE;
	S_DRAW_MESSAGE: next_state =(screenCycle==15'd19199 && start) ? S_DRAW_BOARD:S_DRAW_MESSAGE; //Messages (Full Screen) - 160 x 120 = 19200 Pixels - 1 - DownCounter
	//S_GAME_TIE: next_state=(chipCounter == 6'd43) ? S_GAME_OVER:S_START;
	
	default : next_state = S_START;
	endcase
	end
	
	//Enable Signals
	always @(*)
	begin: enable_signals
	
		r_a=1'b0;
		r_b=1'b0;
		r_c=1'b0;
		r_d=1'b0;
		r_e=1'b0;
		r_f=1'b0;
		r_g=1'b0;
		y_a=1'b0;
		y_b=1'b0;
		y_c=1'b0;
		y_d=1'b0;
		y_e=1'b0;
		y_f=1'b0;
		y_g=1'b0;
		c_a=1'b0;
		c_b=1'b0;
		c_c=1'b0;
		c_d=1'b0;
		c_e=1'b0;
		c_f=1'b0;
		c_g=1'b0;
		drawr=1'b0;
		drawy=1'b0;
		drawBoard=1'b0;
		drawRWin=1'b0;
		drawYWin=1'b0;
		gameTie=1'b0;
		writeEn=1'b0;
		en_chipCycle=1'b0;
		checkRed=1'b0;
		checkYellow=1'b0;
		en_screenCycle=1'b0;

	
		case (current_state)
				S_START:
				begin
				end
				S_CHOOSE_R:
				begin
				end
				S_CHOOSE_Y:
				begin
				end
				S_DRAW_BOARD:
				begin
				
				
				en_screenCycle=1'b1;
				drawBoard=1'b1;
				writeEn=1'b1;
				end
				S_R_LOAD: //Loads Column for Red Board State
				begin 
					case(Column[6:0]) //Columns starts at INDEX 1, so 8 Bits Used
						7'b0000001: r_a=1'b1;
						7'b0000010: r_b=1'b1;
						7'b0000100: r_c=1'b1;
						7'b0001000: r_d=1'b1;
						7'b0010000: r_e=1'b1;
						7'b0100000: r_f=1'b1;
						7'b1000000: r_g=1'b1;
					endcase
				end
				S_R_LOAD_C: //Loads Column for Combined Board State
				begin
					case(Column[6:0])
						7'b0000001: c_a=1'b1;
						7'b0000010: c_b=1'b1;
						7'b0000100: c_c=1'b1;
						7'b0001000: c_d=1'b1;
						7'b0010000: c_e=1'b1;
						7'b0100000: c_f=1'b1;
						7'b1000000: c_g=1'b1;
					endcase
				end
				S_R_DRAW:
				begin
					drawr=1'b1;
					en_chipCycle=1'b1;
					writeEn=1'b1;
				end
				S_CHECK_R:
				begin
					checkRed=1'b1;
				end
				S_Y_LOAD: //Loads Column for Yellow Board State
				begin
					case(Column[6:0])
						7'b0000001: y_a=1'b1;
						7'b0000010: y_b=1'b1;
						7'b0000100: y_c=1'b1;
						7'b0001000: y_d=1'b1;
						7'b0010000: y_e=1'b1;
						7'b0100000: y_f=1'b1;
						7'b1000000: y_g=1'b1;
					endcase
				end
				S_Y_LOAD_C:
				begin
					case(Column[6:0])
						7'b0000001: c_a=1'b1;
						7'b0000010: c_b=1'b1;
						7'b0000100: c_c=1'b1;
						7'b0001000: c_d=1'b1;
						7'b0010000: c_e=1'b1;
						7'b0100000: c_f=1'b1;
						7'b1000000: c_g=1'b1;
					endcase
				end
				S_Y_DRAW:
				begin
					drawy=1'b1;
					en_chipCycle=1'b1;
					writeEn=1'b1;
				end
				S_CHECK_Y:
				begin
					checkYellow=1'b1;
				end
				S_DRAW_MESSAGE:
				begin
					if (RWin)
					begin
						drawRWin=1'b1;
						en_screenCycle=1'b1;
						writeEn=1'b1;
					end
					else if (YWin)
					begin
						drawYWin=1'b1;
						en_screenCycle=1'b1;
						writeEn=1'b1;
					end
					else if (chipCounter == 6'd43)
					begin
						gameTie=1'b1;
						en_screenCycle=1'b1;
						writeEn=1'b1;
					end
				end
			endcase
		end
		
		//State Registers
		always @(posedge clk)
		begin: stateFFS
		if (!resetn)
			current_state <= S_DRAW_BOARD;
		else if(!resetb)
		begin
			current_state <= S_DRAW_BOARD;
		end
		else if (chipCounter == 6'd43)
			current_state <= S_DRAW_MESSAGE;
		else
			current_state <= next_state;
		end
		
endmodule