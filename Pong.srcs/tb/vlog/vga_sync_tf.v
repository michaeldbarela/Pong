`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: vga_sync_tf                                              //
//                                                                      //
//  Created by:         Michael Barela on 03/09/2020.                   //
//  Copyright © 2020    Michael Barela. All rights reserved.            //
//                                                                      //
//  In submitting this file for class work at CSULB                     //
//  I am confirming that this is my work and the work                   //
//  of no one else. In submitting this code I acknowledge that          //
//  plagiarism in student product work is subject to dismissial         //
//  from the class                                                      //
//**********************************************************************//

module vga_sync_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg        clk, reset;
    wire       hsync, vsync, video_on, aiso_reset;
    wire [9:0] pixel_x, pixel_y;
    integer    i, j, a, b, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    vga_sync dut( .clk( clk ),
                  .reset( aiso_reset ),
                  .hsync( hsync ),
                  .vsync( vsync ),
                  .video_on( video_on ),
                  .pixel_x( pixel_x ),
                  .pixel_y( pixel_y ) );
                  
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
             
    //Creates a 100MHz, 10ns period       
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; i = 0; j = 0; a = 0; b = 0; errorCount = 0; 
        #10 reset = 0;
        #10 count;
        #10 reset = 1;
        #10 reset = 0;
        #10 countRandomThenReset;
        #10 countRandomThenReset;
        #10 countRandomThenReset;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN VGA SYNC MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times.
    task count; begin
        //Each iteration counts through the number of lines
        for(i = 0; i < 525; i = i + 1) begin
            //Each iteration counts through the horizontal pixels
            for(j = 0; j < 800; j = j + 1) begin
                @( posedge dut.pulse ); //Waits until the rising edge of the 40ns pulse
                @( negedge clk ); //Wait until the negedge clk to ensure values have changed                        
                //(**REQUIREMENT 2**)Shows that the vga sync signal is updated at the 25MHz, 40ns, rate
                //This is done by checking the pulse at the current time as j takes 40ns per increment already
                if(dut.pulse != 1) begin
                    $display("ERROR: PULSE DOES NOT OCCUR AT A RATE OF 25MHZ, ISSUE BEGINS AT PIXEL_X = %d and PIXEL_Y = %d", pixel_x, pixel_y); 
                    errorCount = errorCount + 1;
                end                
                //(**REQUIREMENT 11**)Shows that video_on is only high when h_video_on and v_video_on are high
                if(dut.h_video_on && dut.v_video_on) begin
                    if(video_on == 0) begin
                        $display("ERROR: VIDEO_ON IS LOW WHEN IT SHOULD BE HIGH AT PIXEL_X = %d and PIXEL_Y = %d", pixel_x, pixel_y);
                        errorCount = errorCount + 1;
                    end else if(!(dut.h_video_on && dut.v_video_on)) begin
                        if(video_on == 1) begin
                            $display("ERROR: VIDEO_ON IS HIGH WHEN IT SHOULD BE LOW AT PIXEL_X = %d and PIXEL_Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                    end
                end
            end
        end
    end endtask
    
    //Counter to randomize which pixels will be counted up to, execute reset, and check that values are reset.
    task countRandomThenReset; begin
            //Geneartes two random numbers, a range is 0 to 800 and b range is 0 to 525
            a = $urandom%800;
            b = $urandom%525;
            //i loop will count up to the b integer representing which line on the screen
            for(i = 0; i < b; i = i + 1) begin
                //j loop will count up to the a integer representing the pixel in that row
                for(j = 0; j < a; j = j + 1) begin
                    @( posedge dut.pulse ); //Waits until the rising edge of the 40ns pulse
                    @( negedge clk ); //Waits until the negedge clk to ensure values change
                end
            end
            //Wait a bit before resetting then check
            #10 reset = 1;
            #10 reset = 0;
            #10;
            //(**REQUIREMENT 1**)Shows that the reset will bring all values to a known state with all outputs inactive
            //video_on will remain on due to h video on and v video on being high at 0
            if(aiso_reset == 1) begin
                if(hsync || vsync || pixel_x || pixel_y) begin
                    $display("ERROR: RESET NOT WORKING AT PIXEL_X = %d and PIXEL_Y = %d", pixel_x, pixel_y);
                    errorCount = errorCount + 1;
                end
            end
    end endtask
    
endmodule
