`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: vertical_sync_tf                                         //
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

module vertical_sync_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg        clk, reset;
    wire       v_video_on, v_end, v_sync_q, pulse, h_end, aiso_reset;
    wire [9:0] v_count_q;
    integer    i, j, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    vertical_sync dut( .clk( clk ),
                       .reset( aiso_reset ),
                       .pulse( pulse ),
                       .h_end( h_end ),
                       .v_video_on( v_video_on ),
                       .v_end( v_end ),
                       .v_sync_q( v_sync_q ),
                       .v_count_q( v_count_q ) );
                      
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
                    
    pulse_generator #( .BITS( 2 ), .MAX_COUNT( 4 ) ) dut2( .clk( clk ),
                                                           .reset( aiso_reset ),
                                                           .pulse( pulse ) );
                                                          
    horizontal_sync dut3( .clk( clk ),
                          .reset( aiso_reset ),
                          .pulse( pulse ),
                          .h_video_on( ),
                          .h_end( h_end ),
                          .h_sync_q( ),
                          .h_count_q( ) );

//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                            
    //Creates a 100MHz, 10ns period 
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; i = 0; j = 0; errorCount = 0;
        #10 reset = 0;
        #10 count;
        #10 reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN VERTICAL SYNC MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times
    task count; begin
        //Counts through the amount of pixels in a row times the amount of lines on screen
        for( i = 0; i < 525; i = i + 1 ) begin
            for( j = 0; j < 800; j = j + 1 ) begin
                @( posedge pulse ); //Waits until the posedge of a 40ns pulse 
                @( negedge clk ); //Begins the checks at the negedge clk after pulse rises to ensure values have changed
                //(**REQUIREMENT 7**)Shows that v_count_q increments at the end of a horizontal scan
                if(h_end) begin
                    if(v_count_q < 524) begin
                        if(dut.v_count_d != v_count_q + 1) begin
                            $display("ERROR: V COUNT DID NOT INCREMENT AT END OF HORIZONTAL SCAN AT v_count_q = %d", v_count_q);
                            errorCount = errorCount + 1;
                        end
                    end else if(v_count_q == 524) begin
                        if(dut.v_count_d != 0) begin
                            $display("ERROR: V COUNT DID NOT INCREMENT AT END OF HORIZONTAL SCAN AT v_count_q = %d", v_count_q);
                            errorCount = errorCount + 1;
                        end
                    end
                end
            end
            //(**REQUIREMENT 8**)Shows that the v_count_q is bounded between 0 and 524
            if(v_count_q < 0 || v_count_q > 524) begin
                $display("ERROR: V COUNT OUT OF BOUNDS AT v_count_q = %d", v_count_q);
                errorCount = errorCount + 1;
            end
            //(**REQUIREMENT 9**)Shows that the vsync is low active and active from scan count 490 to 491
            if(v_sync_q == 0 && (v_count_q < 490 || v_count_q > 491) ) begin
                $display("ERROR: V SYNC IS LOW AT v_count_q = %d", v_count_q);
                errorCount = errorCount + 1;
            end else if(v_sync_q == 1 && v_count_q >= 490 && v_count_q <= 491) begin
                $display("ERROR: V SYNC IS HIGH AT v_count_q = %d", v_count_q);
                errorCount = errorCount + 1;
            end
            //(**REQUIREMENT 10**)Shows that the v video on is high active and active from scan count 0 to 479
            if(v_video_on == 0 && v_count_q <= 479) begin
                $display("ERROR: H VIDEO ON IS LOW AT h_count_q = %d", v_count_q);
                errorCount = errorCount + 1;
            end else if(v_video_on == 1 && v_count_q > 479) begin
                $display("ERROR: H VIDEO ON IS HIGH AT h_count_q = %d", v_count_q);
                errorCount = errorCount + 1;
            end
        end
    end endtask

endmodule
