`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: pong_left_paddle_tf                                      //
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

module pong_left_paddle_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg            clk, reset;
    reg     [1:0]  player2;
    reg     [3:0]  select, SW_red, SW_green, SW_blue;
    reg     [9:0]  pixel_x, pixel_y;
    wire           aiso_reset, refr_tick, EN_LP;
    wire    [9:0]  LPT_Q, LPB;
    wire    [11:0] left_paddle_rgb;
    integer        i, j, k, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    pong_left_paddle dut( .clk( clk ),
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
                          .LPT_Q( LPT_Q ),
                          .LPB( LPB ),
                          .left_paddle_rgb( left_paddle_rgb ) );
                     
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
    
    vga_sync dut2( .clk( clk ),
                   .reset( aiso_reset ),
                   .hsync( hsync ),
                   .vsync( vsync ),
                   .video_on( video_on ),
                   .pixel_x(  ),
                   .pixel_y(  ) );
                   
    pulse_generator #( .BITS( 21 ), .MAX_COUNT( 1666667 ) ) dut3( .clk( clk ),
                                                                  .reset( aiso_reset ),
                                                                  .pulse( refr_tick ) );
//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                            
    //Creates a 100MHz, 10ns period 
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; player2 = 2'b0; select = 4'b1000; {SW_red, SW_green, SW_blue} = 12'b0; i = 0; j = 0; k = 0; errorCount = 0;
        #10 reset = 0; {SW_red, SW_green, SW_blue} = 12'b111100000000;
        #10 count;
        #10 reset = 1;
        #10 reset = 0; select = 4'b1010; {SW_red, SW_green, SW_blue} = 12'b101010101010;
        #10 count;
        #10 player2 = 2'b10;
        //Moves the left paddle up to the top
        //****REQUIREMENT 4**** Verify that the top button makes the paddle go up
        for( k = 0; k < 50; k = k + 1 ) begin
            @( negedge refr_tick ); //Wait for the negedge of the refresh to occur before checking
            //****REQUIREMENT 2**** Verify the paddle goes from the top to the bottom of the display
            //****REQUIREMENT 5**** Verify the paddle will go up four lines at a time
            //****REQUIREMENT 6**** Verify the paddle will not go past the allowed location (within four pixels of wall)
            if( LPT_Q > (dut.TWB + 4) && dut.LPT_D != (LPT_Q - 4) ) begin
                $display("ERROR: LEFT PADDLE DID NOT DECREMENT CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            count; 
        end
        #10 reset = 1;
        #10 reset = 0; select = 4'b1010; {SW_red, SW_green, SW_blue} = 12'b101010101010;
        #10 player2 = 2'b01;
        //Moves the left paddle down to the bottom
        //****REQUIREMENT 4**** Verify that the right button makes the paddle go down
        for( k = 0; k < 50; k = k + 1 ) begin
            @( negedge refr_tick ); //Wait for the negedge of the refresh to occur before checking
            //****REQUIREMENT 2**** Verify the paddle goes from the top to the bottom of the display
            //****REQUIREMENT 5**** Verify the paddle will go down four lines at a time
            //****REQUIREMENT 6**** Verify the paddle will not go past the allowed location (within four pixels of wall)
            if( LPB < (dut.BWT - 4) && dut.LPT_D != (LPT_Q + 4) ) begin
                $display("ERROR: LEFT PADDLE DID NOT INCREMENT CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            count; 
        end
        #10 reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN PONG LEFT PADDLE MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times
    task count; begin
        //Specifies the rectangular grid of where the right paddle should be and conducts checks
        for( pixel_y = (LPT_Q - 1); pixel_y < (LPB + 1) ; pixel_y = pixel_y + 1 ) begin
            for( pixel_x = (dut.LPL - 1); pixel_x < (dut.LPR + 1); pixel_x = pixel_x + 1 ) begin
                @( posedge dut2.pulse ); //Waits until the rising edge 40ns pulse
                @( negedge clk ); //Begins the checks at the negedge clk after pulse rises to ensure values have changed
                //****REQUIREMENT 3**** Verify that the bottom of the paddle is 36 pixels (RPLength) from the top
                if( LPB != (LPT_Q + dut.LPLength) ) begin
                    $display("ERROR: INCORRECT COLOR DISPLAYED FOR LEFT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
                if( pixel_y >= LPT_Q && pixel_y <= LPB ) begin
                    if( pixel_x >= dut.LPL && pixel_x <= dut.LPR ) begin
                        //Verify that the color is correct
                        if( left_paddle_rgb != ~{SW_red, SW_green, SW_blue} ) begin
                            $display("ERROR: INCORRECT COLOR DISPLAYED FOR LEFT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                        //Verify that the enable bit is high at the correct time
                        if( !EN_LP ) begin
                            $display("ERROR: ENABLE BIT INCORRECT FOR LEFT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                    end
                end
            end
            //****REQUIREMENT 6**** Verify the paddle will not go past the top or bottom walls
            if( LPT_Q <= dut.TWB ) begin
                $display("ERROR: LEFT PADDLE TOP SHOULD NOT BE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end else if( LPB >= dut.BWT ) begin
                $display("ERROR: LEFT PADDLE BOTTOM SHOULD NOT BE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
        end
    end endtask

endmodule
