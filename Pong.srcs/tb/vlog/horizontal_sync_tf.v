`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: horizontal_sync_tf                                       //
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

module horizontal_sync_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg        clk, reset;
    wire       h_video_on, h_end, h_sync_q, pulse, aiso_reset;
    wire [9:0] h_count_q;
    integer    i, errorCount;
                     
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    horizontal_sync dut( .clk( clk ),
                         .reset( aiso_reset ),
                         .pulse( pulse ),
                         .h_video_on( h_video_on ),
                         .h_end( h_end ),
                         .h_sync_q( h_sync_q ),
                         .h_count_q( h_count_q ) );
                            
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
                    
    pulse_generator #( .BITS( 2 ), .MAX_COUNT( 4 ) ) dut2( .clk( clk ),
                                                           .reset( aiso_reset ),
                                                           .pulse( pulse ) );

//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                 
    //Creates a 100MHz, 10ns period                                                        
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; i = 0; errorCount = 0;
        #10 reset = 0;
        #10 count;
        #10 reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN HORIZONTAL SYNC MODULE.");
        #10 $stop;
    end
    
    //Counts a lot of times
    task count; begin
        //Counts the number of pizels in a row
        for( i = 0; i < 800; i = i + 1 ) begin
            @( posedge pulse ); //Waits until the posedge of a 40ns pulse 
            @( negedge clk ); //Begins the checks at the negedge clk after pulse rises to ensure values have changed
            //(**REQUIREMENT 3**)Shows that the h count is updated at the 25MHz, 40ns, rate
            //This is done by checking the next count against the current count as each increment of i takes 40ns
            if(h_count_q < 799) begin
                if(dut.h_count_d != h_count_q + 1) begin
                    $display("ERROR: NEXT H COUNT IS INCORRECT VALUE AT h_count_q = %d", h_count_q);
                    errorCount = errorCount + 1;
                end
            end else if(h_count_q == 799) begin
                if(dut.h_count_d != 0) begin
                    $display("ERROR: NEXT H COUNT IS INCORRECT VALUE AT h_count_q = %d", h_count_q);
                    errorCount = errorCount + 1;
                end
            end
            //(**REQUIREMENT 4**)Shows that the h_count_q is bounded between 0 and 799
            if(h_count_q < 0 || h_count_q > 799) begin
                $display("ERROR: H COUNT OUT OF BOUNDS AT h_count_q = %d", h_count_q);
                errorCount = errorCount + 1;
            end
            //(**REQUIREMENT 5**)Shows that the hsync is low active and active from scan count 656 to 751
            if(h_sync_q == 0 && (h_count_q < 656 || h_count_q > 751) ) begin
                $display("ERROR: H SYNC IS LOW AT h_count_q = %d", h_count_q);
                errorCount = errorCount + 1;
            end else if(h_sync_q == 1 && h_count_q >= 656 && h_count_q <= 751) begin
                $display("ERROR: H SYNC IS HIGH AT h_count_q = %d", h_count_q);
                errorCount = errorCount + 1;
            end
            //(**REQUIREMENT 6**)Shows that the h video on is high active and active from scan count 0 to 639
            if(h_video_on == 0 && h_count_q <= 639) begin
                $display("ERROR: H VIDEO ON IS LOW AT h_count_q = %d", h_count_q);
                errorCount = errorCount + 1;
            end else if(h_video_on == 1 && h_count_q > 639) begin
                $display("ERROR: H VIDEO ON IS HIGH AT h_count_q = %d", h_count_q);
                errorCount = errorCount + 1;
            end
        end
    end endtask
    
endmodule
