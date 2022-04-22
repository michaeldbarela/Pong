`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: pong_left_wall_tf                                        //
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

module pong_left_wall_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg            clk, reset;
    reg     [3:0]  select, SW_red, SW_green, SW_blue;
    wire           aiso_reset, EN_LW;
    wire    [9:0]  pixel_x, pixel_y;
    wire    [11:0] left_wall_rgb;
    integer        i, j, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    pong_left_wall dut( .select( select ),
                        .SW_red( SW_red ),
                        .SW_green( SW_green ),
                        .SW_blue( SW_blue ),
                        .pixel_x( pixel_x ),
                        .pixel_y( pixel_y ),
                        .EN_LW( EN_LW ),
                        .left_wall_rgb( left_wall_rgb ) );
                     
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

//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                            
    //Creates a 100MHz, 10ns period 
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; select = 4'b0; {SW_red, SW_green, SW_blue} = 12'b0; i = 0; j = 0; errorCount = 0;
        #10 reset = 0; {SW_red, SW_green, SW_blue} = 12'b111100000000;
        #10 count;
        #10 reset = 1;
        #10 reset = 0; select = 4'b0010; {SW_red, SW_green, SW_blue} = 12'b101010101010;
        #10 count;
        #10 reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN PONG LEFT WALL MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times
    task count; begin
        //Counts through the amount of pixels in a row times the amount of lines on screen
        for( i = 0; i < 525; i = i + 1 ) begin
            for( j = 0; j < 800; j = j + 1 ) begin
                @( posedge dut2.pulse ); //Waits until the posedge of a 40ns pulse 
                @( negedge clk ); //Begins the checks at the negedge clk after pulse rises to ensure values have changed
                if( (pixel_y >= dut.LWT1 && pixel_y <= dut.LWB1) || (pixel_y >= dut.LWT2 && pixel_y <= dut.LWB2) ) begin
                    if( pixel_x >= dut.LWL && pixel_x <= dut.LWR ) begin
                        if( left_wall_rgb != ~{SW_red, SW_green, SW_blue} ) begin
                            $display("ERROR: INCORRECT COLOR DISPLAYED FOR LEFT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                        if( !EN_LW ) begin
                            $display("ERROR: ENABLE BIT INCORRECT FOR LEFT PADDLE AT PIXEL X = %d and PIXEL Y = %d", pixel_x, pixel_y);
                            errorCount = errorCount + 1;
                        end
                    end
                end
            end
        end
    end endtask

endmodule
