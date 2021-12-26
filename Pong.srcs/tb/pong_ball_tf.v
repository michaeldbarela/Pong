`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: pong_ball_tf                                             //
//                                                                      //
//  Created by:         Michael Barela on 04/26/2020.                   //
//  Copyright © 2020    Michael Barela. All rights reserved.            //
//                                                                      //
//  In submitting this file for class work at CSULB                     //
//  I am confirming that this is my work and the work                   //
//  of no one else. In submitting this code I acknowledge that          //
//  plagiarism in student product work is subject to dismissial         //
//  from the class                                                      //
//**********************************************************************//

module pong_ball_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg            clk, reset;
    reg     [3:0]  select, SW_red, SW_green, SW_blue;
    wire           aiso_reset, refr_tick, delay, pause_Q, EN_BALL;
    wire    [3:0]  score_left_Q, score_right_Q;
    wire    [9:0]  pixel_x, pixel_y, RPT, RPB, LPT, LPB;
    wire    [11:0] ball_rgb;
    integer        i, j, k, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    pong_ball dut( .clk( clk ),
                   .reset( aiso_reset ),
                   .refr_tick( refr_tick ),
                   .delay( delay ),
                   .select( select ),
                   .SW_red( SW_red ),
                   .SW_green( SW_green ),
                   .SW_blue( SW_blue ),
                   .RPT( RPT ),
                   .RPB( RPB ),
                   .LPT( LPT ),
                   .LPB( LPB ),
                   .pixel_x( pixel_x ),
                   .pixel_y( pixel_y ),
                   .EN_BALL( EN_BALL ),
                   .pause_Q( pause_Q ),
                   .score_left_Q( score_left_Q ),
                   .score_right_Q( score_right_Q ),
                   .ball_rgb( ball_rgb ) );
                     
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
    
    vga_sync dut2( .clk( clk ),
                   .reset( aiso_reset ),
                   .hsync( hsync ),
                   .vsync( vsync ),
                   .video_on( video_on ),
                   .pixel_x( pixel_x ),
                   .pixel_y( pixel_y ) );
                   
    pulse_generator #( .BITS( 21 ), .MAX_COUNT( 1666667 ) ) dut3( .clk( clk ),
                                                                  .reset( aiso_reset ),
                                                                  .pulse( refr_tick ) );
    
    //Normally a 3 second delay, but it takes too long to simulate                                                              
    pulse_generator_input #( .BITS( 1 ), .MAX_COUNT( 1 ) ) dut4( .clk( clk ),
                                                                 .reset( aiso_reset ),
                                                                 .in( pause_Q ),
                                                                 .pulse( delay ) );
                                                                           
    pong_right_paddle dut5( .clk( clk ),
                            .reset( aiso_reset ),
                            .refr_tick( refr_tick ),
                            .player1( player1 ),
                            .select( select ),
                            .SW_red( SW_red ),
                            .SW_green( SW_green ),
                            .SW_blue( SW_blue ),
                            .pixel_x( pixel_x ),
                            .pixel_y( pixel_y ),
                            .EN_RP( EN_RP ),
                            .RPT_Q( RPT ),
                            .RPB( RPB ),
                            .right_paddle_rgb( right_paddle_rgb ) );
    
    pong_left_paddle dut6( .clk( clk ),
                           .reset( aiso_reset ),
                           .refr_tick( refr_tick ),
                           .player2( player2 ),
                           .select( select ),
                           .SW_red( SW_red ),
                           .SW_green( SW_green ),
                           .SW_blue( SW_blue ),
                           .pixel_x( pixel_x ),
                           .pixel_y( pixel_y ),
                           .EN_LP( EN_LP ),
                           .LPT_Q( LPT ),
                           .LPB( LPB ),
                           .left_paddle_rgb( left_paddle_rgb ) );
                           
//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                            
    //Creates a 100MHz, 10ns period 
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; select = 4'b0; {SW_red, SW_green, SW_blue} = 12'b0; i = 0; j = 0; k = 0; errorCount = 0;
        #10 reset = 0; dut.pause_Q = 0; {SW_red, SW_green, SW_blue} = 12'b000000001111;
        #10 dut.x_direction_Q = 0; dut.y_direction_Q = 0; //Set the direction of the ball as x left, y down
        //Checks 3 movements of the ball going left and down
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 0; dut.y_direction_Q = 1; //Set the direction of the ball as x left, y up
        //Checks 3 movements of the ball going left and up
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 1; dut.y_direction_Q = 0; //Set the direction of the ball as x right, y down
        //Checks 3 movements of the ball going right and down
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 1; dut.y_direction_Q = 1; //Set the direction of the ball as x right, y up
        //Checks 3 movements of the ball going right and up
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 reset = 1;
        #10 reset = 0; dut.pause_Q = 0; select = 4'b0001; {SW_red, SW_green, SW_blue} = 12'b101010101010;
        #10 dut.x_direction_Q = 0; dut.y_direction_Q = 1; //Set the direction of the ball as x left, y up
        dut.ball_y_Q = dut.TWB + dut.BSize + 1; //Set ball location just below the top wall
        //Checks 3 movements of the ball going left and up (Ball should bounce off top wall here)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 1; dut.y_direction_Q = 0; //Set the direction of the ball as x right, y down
        dut.ball_y_Q = dut.BWT - dut.BSize - 1; //Set ball location just above bottom wall
        //Checks 3 movements of the ball going right and down (Ball should bounce off bottom wall here)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 1; dut.y_direction_Q = 1; //Set the direction of the ball as x right, y up
        dut.ball_x_Q = dut.RPL - dut.BSize - 1; dut.ball_y_Q = dut.RPT + 18; //Set ball location just left of right paddle
        //Checks 3 movements of the ball going right and up (Ball should bounce off right paddle here)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 1; dut.y_direction_Q = 1; //Set the direction of the ball as x right, y up
        dut.ball_x_Q = dut.RPR + 2; dut.ball_y_Q = dut.RPT + 40; //Set ball location near right goal
        //Checks 3 movements of the ball going right and up (Ball should score and be sent to center)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.pause_Q =0; dut.x_direction_Q = 0; dut.y_direction_Q = 0; //Set the direction of the ball as x left, y down
        dut.ball_x_Q = dut.LWR + dut.BSize + 1; dut.ball_y_Q = dut.LWT2 + 18; //Set ball location just right of left wall
        //Checks 3 movements of the ball going left and down (Ball should bounce off left wall here)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 0; dut.y_direction_Q = 0; //Set the direction of the ball as x left, y down
        dut.ball_x_Q = dut.LWL - 2; dut.ball_y_Q = dut.LWT2 - 25; //Set ball location right of left side goal
        //Checks 3 movements of the ball going left and down (Ball should score and be sent to center)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 select[3] = 1; //Enable 
        dut.pause_Q = 0; dut.x_direction_Q = 0; dut.y_direction_Q = 1; //Set the direction of the ball as x left, y up
        dut.ball_x_Q = dut.LPR + dut.BSize + 1; dut.ball_y_Q = dut.LPT + 18; //Set ball location just right of left paddle
        //Checks 3 movements of the ball going right and up (Ball should bounce off left paddle here)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 dut.x_direction_Q = 0; dut.y_direction_Q = 1; //Set the direction of the ball as x left, y up
        dut.ball_x_Q = dut.LPL - 2; dut.ball_y_Q = dut.LPT + 40; //Set ball location just right of left goal
        //Checks 3 movements of the ball going right and up (Ball should score and be sent to center)
        for( k = 0; k < 3; k = k + 1 ) begin
            ball_move_check;
            count; 
        end
        #10 reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN PONG BALL MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times
    task count; begin
        //Specifies the rectangular grid of where the right paddle should be and conducts checks
        for( i = 0; i < 525; i = i + 1 ) begin
            for( j = 0; j < 800; j = j + 1 ) begin
                @( posedge dut2.pulse ); //Waits until the rising edge 40ns pulse
                @( negedge clk ); //Begins the checks at the negedge clk after pulse rises to ensure values have changed
            end
        end
    end endtask
    
    task ball_move_check; begin
        @( posedge refr_tick ); //Wait for the posedge of the refresh to occur before checking
        @( negedge clk ); //Wait for the negedge of the next clk before conducting the check to ensure values change
        //****REQUIREMENT 7**** Verifies that the ball is being tracked by two registers (for x and y)
        //****REQUIREMENT 9**** Verifies that the ball only moves 1x1 pixel at a time in the x and y directions
        if( dut.x_direction_Q == 0 && dut.y_direction_Q == 0 ) begin
            if( (dut.ball_x_D != (dut.ball_x_Q - 1)) && (dut.ball_y_D != (dut.ball_y_Q + 1)) ) begin
                $display("ERROR: BALL DID NOT MOVE CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        end else if( dut.x_direction_Q == 0 && dut.y_direction_Q == 1 ) begin
            if( (dut.ball_x_D != (dut.ball_x_Q - 1)) && (dut.ball_y_D != (dut.ball_y_Q - 1)) ) begin
                $display("ERROR: BALL DID NOT MOVE CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        end else if( dut.x_direction_Q == 1 && dut.y_direction_Q == 0 ) begin
            if( (dut.ball_x_D != (dut.ball_x_Q + 1)) && (dut.ball_y_D != (dut.ball_y_Q + 1)) ) begin
                $display("ERROR: BALL DID NOT MOVE CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        end else if( dut.x_direction_Q == 1 && dut.y_direction_Q == 1 ) begin
            if( (dut.ball_x_D != (dut.ball_x_Q + 1)) && (dut.ball_y_D != (dut.ball_y_Q - 1)) ) begin
                $display("ERROR: BALL DID NOT MOVE CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        end
        //****REQUIREMENT 8**** Verify the area of the ball is computed by using the current position and defined size
        //EN_BALL should only be asserted when within the area of the ball, BSize = 3
        if( EN_BALL ) begin
            //Check left side
            if( pixel_x < (dut.ball_x_Q - dut.BSize) ) begin
                $display("ERROR: LEFT AREA OUT OF BOUNDS AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            //Check right side
            end else if( pixel_x > (dut.ball_x_Q + dut.BSize) ) begin
                $display("ERROR: RIGHT AREA OUT OF BOUNDS AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            //Check top
            if( pixel_y < (dut.ball_y_Q - dut.BSize) ) begin
                $display("ERROR: TOP AREA OUT OF BOUNDS AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            //Check bottom
            end else if( pixel_y > (dut.ball_y_Q + dut.BSize) ) begin
                $display("ERROR: BOTTOM AREA OUT OF BOUNDS AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
        end
        //****REQUIREMENT 10**** Verify that the ball restarts in the center after crossing the paddle or wall
        //Checks if it's a right goal
        if( dut.ball_left >= dut.RPR ) begin
            if( dut.ball_x_D != 320 && dut.ball_y_D != 240 ) begin
                $display("ERROR: RIGHT GOAL SHOULD HAVE OCCURED AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        //Checks if it's a left goal with player 2
        end else if( select[3] && dut.ball_right <= dut.LPL ) begin
            if( dut.ball_x_D != 320 && dut.ball_y_D != 240 ) begin
                $display("ERROR: LEFT PADDLE GOAL SHOULD HAVE OCCURED AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        //Checks if it's a left goal without player 2
        end else if( !select[3] && dut.ball_right <= dut.LWL ) begin
            if( dut.ball_x_D != 320 && dut.ball_y_D != 240 ) begin
                $display("ERROR: LEFT WALL GOAL SHOULD HAVE OCCURED AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                $display("\t\t OCCURS WHEN CURRENT X = %d AND CURRENT Y = %d", dut.ball_x_Q, dut.ball_y_Q);
                $display("\t\t OCCURS WHILE CURRENT X DIR = %d AND CURRENT Y DIR = %d", dut.x_direction_Q, dut.y_direction_Q);
                errorCount = errorCount + 1;
            end
        end
        //****REQUIREMENT 11**** Verify that the ball reflects
        //Checks to see if it bounces off of left paddle correctly
        if( select[3] && dut.ball_left <= dut.LPR && dut.ball_bottom >= LPT && dut.ball_top <= LPB ) begin
            if( dut.ball_x_D != (dut.ball_x_Q + 1) ) begin
                $display("ERROR: LEFT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            if( dut.y_direction_D == 1 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q - 1) ) begin
                    $display("ERROR: LEFT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end else if( dut.y_direction_Q == 0 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q + 1) ) begin
                    $display("ERROR: LEFT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end
        //Checks to see if it bounces off of left wall correctly
        end else if( !select[3] && dut.ball_left <= dut.LWR && (dut.ball_top <= dut.LWB1 || dut.ball_bottom >= dut.LWT2) ) begin
            if( dut.ball_x_D != (dut.ball_x_Q + 1) ) begin
                $display("ERROR: LEFT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            if( dut.y_direction_D == 1 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q - 1) ) begin
                    $display("ERROR: LEFT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end else if( dut.y_direction_Q == 0 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q + 1) ) begin
                    $display("ERROR: LEFT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end
        //Checks to see if it bounces off of right paddle correctly
        end else if( dut.ball_right >= dut.RPR && dut.ball_bottom >= RPT && dut.ball_top <= RPB ) begin
            if( dut.ball_x_D != (dut.ball_x_Q + 1) ) begin
                $display("ERROR: RIGHT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            if( dut.y_direction_D == 1 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q - 1) ) begin
                    $display("ERROR: RIGHT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end else if( dut.y_direction_Q == 0 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q + 1) ) begin
                    $display("ERROR: RIGHT PADDLE BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end
        end
        //Checks to see if it bounces off of the top wall correctly
        if( dut.ball_top <= dut.TWB ) begin
            if( dut.ball_y_D != (dut.ball_x_Q + 1) ) begin
                $display("ERROR: TOP WALL BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            if( dut.x_direction_D == 1 ) begin
                if( dut.ball_x_D != (dut.ball_x_Q + 1) ) begin
                    $display("ERROR: TOP WALLBOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end else if( dut.x_direction_Q == 0 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q - 1) ) begin
                    $display("ERROR: TOP WALL BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end
        //Checks to see if it bounces off of the bottom wall correctly
        end else if( dut.ball_y_Q >= dut.BWT ) begin
            if( dut.ball_y_D != (dut.ball_x_Q - 1) ) begin
                $display("ERROR: BOTTOM WALL BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            if( dut.x_direction_D == 1 ) begin
                if( dut.ball_x_D != (dut.ball_x_Q + 1) ) begin
                    $display("ERROR: BOTTOM WALLBOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end else if( dut.x_direction_Q == 0 ) begin
                if( dut.ball_y_D != (dut.ball_y_Q - 1) ) begin
                    $display("ERROR: BOTTOM WALL BOUNCE ISSUE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end
        end
    end endtask

endmodule
