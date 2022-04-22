`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: pong_right_paddle_tf                                     //
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

module pong_right_paddle_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg            clk, reset;
    reg     [1:0]  player1;
    reg     [2:0]  select;
    reg     [3:0]  SW_red, SW_green, SW_blue;
    reg     [9:0]  pixel_x, pixel_y;
    wire           aiso_reset, refr_tick, EN_RP;
    wire    [9:0]  RPT_Q, RPB;
    wire    [11:0] right_paddle_rgb;
    integer        i, j, k, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    pong_right_paddle dut( .clk( clk ),
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
                           .RPT_Q( RPT_Q ),
                           .RPB( RPB ),
                           .right_paddle_rgb( right_paddle_rgb ) );
                     
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
        clk = 0; reset = 1; player1 = 2'b0; select = 3'b0; {SW_red, SW_green, SW_blue} = 12'b0; i = 0; j = 0; k = 0; errorCount = 0;
        #10 reset = 0; {SW_red, SW_green, SW_blue} = 12'b111100000000;
        #10 count;
        #10 reset = 1;
        #10 reset = 0; select = 3'b010; {SW_red, SW_green, SW_blue} = 12'b101010101010;
        #10 count;
        #10 player1 = 2'b10;
        //Moves the right paddle up to the top
        //****REQUIREMENT 4**** Verify that the top button makes the paddle go up
        for( k = 0; k < 50; k = k + 1 ) begin
            @( negedge refr_tick ); //Wait for the negedge of the refresh to occur before checking
            //****REQUIREMENT 2**** Verify the paddle goes from the top to the bottom of the display
            //****REQUIREMENT 5**** Verify the paddle will go up four lines at a time
            //****REQUIREMENT 6**** Verify the paddle will not go past the allowed location (within four pixels of wall)
            if( RPT_Q > (dut.TWB + 4) && dut.RPT_D != (RPT_Q - 4) ) begin
                $display("ERROR: RIGHT PADDLE DID NOT DECREMENT CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            count; 
        end
        #10 reset = 1;
        #10 reset = 0; select = 3'b010; {SW_red, SW_green, SW_blue} = 12'b101010101010;
        #10 player1 = 2'b01;
        //Moves the right paddle down to the bottom
        //****REQUIREMENT 4**** Verify that the right button makes the paddle go down
        for( k = 0; k < 50; k = k + 1 ) begin
            @( negedge refr_tick ); //Wait for the negedge of the refresh to occur before checking
            //****REQUIREMENT 2**** Verify the paddle goes from the top to the bottom of the display
            //****REQUIREMENT 5**** Verify the paddle will go down four lines at a time
            //****REQUIREMENT 6**** Verify the paddle will not go past the allowed location (within four pixels of wall)
            if( RPB < (dut.BWT - 4) && dut.RPT_D != (RPT_Q + 4) ) begin
                $display("ERROR: RIGHT PADDLE DID NOT INCREMENT CORRECTLY AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
            count; 
        end
        #10 reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN PONG RIGHT PADDLE MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times
    task count; begin
        //Specifies the rectangular grid of where the right paddle should be and conducts checks
        for( pixel_y = (RPT_Q - 1); pixel_y < (RPB + 1) ; pixel_y = pixel_y + 1 ) begin
            for( pixel_x = (dut.RPL - 1); pixel_x < (dut.RPR + 1); pixel_x = pixel_x + 1 ) begin
                @( posedge dut2.pulse ); //Waits until the rising edge 40ns pulse
                @( negedge clk ); //Begins the checks at the negedge clk after pulse rises to ensure values have changed
                //****REQUIREMENT 3**** Verify that the bottom of the paddle is 36 pixels (RPLength) from the top
                if( RPB != (RPT_Q + dut.RPLength) ) begin
                    $display("ERROR: INCORRECT COLOR DISPLAYED FOR RIGHT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
                if( pixel_y >= RPT_Q && pixel_y <= RPB ) begin
                    if( pixel_x >= dut.RPL && pixel_x <= dut.RPR ) begin
                        //Verify that the color is correct
                        if( right_paddle_rgb != {SW_red, SW_green, SW_blue} ) begin
                            $display("ERROR: INCORRECT COLOR DISPLAYED FOR RIGHT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                        //Verify that the enable bit is high at the correct time
                        if( !EN_RP ) begin
                            $display("ERROR: ENABLE BIT INCORRECT FOR RIGHT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                    end
                end
            end
            //****REQUIREMENT 6**** Verify the paddle will not go past the top or bottom walls
            if( RPT_Q <= dut.TWB ) begin
                $display("ERROR: RIGHT PADDLE TOP SHOULD NOT BE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end else if( RPB >= dut.BWT ) begin
                $display("ERROR: RIGHT PADDLE BOTTOM SHOULD NOT BE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                errorCount = errorCount + 1;
            end
        end
    end endtask

endmodule
