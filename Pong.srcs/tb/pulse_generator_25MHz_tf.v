`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: pulse_generator_25MHz_tf                                 //
//  Description: Testing for a 25MHz pulse                              //
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

module pulse_generator_25MHz_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg            clk, reset;
    wire           aiso_reset, pulse_60Hz;
    integer        i, errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////
    pulse_generator #( .BITS( 2 ), .MAX_COUNT( 4 ) ) dut( .clk( clk ),
                                                          .reset( aiso_reset ),
                                                          .pulse( pulse_25MHz ) );
                               
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
                   
//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                               
    //Creates a 100MHz, 10ns period    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; i = 0; errorCount = 0;
        #10; reset = 0; 
        #10; count;
        #10; reset = 1;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN 25 MHZ PULSE GENERATOR MODULE.");
        #10; $stop;
    end
    
    //Counts a lot of times
    task count; begin
        for(i = 0; i < 20; i = i + 1) begin
            #40; //40ns or 25MHz wait time
            //Check to ensure the pulse is high at this specifc time
            if( pulse_25MHz != 1 ) begin
                $display("ERROR: PULSE IS NOT IN SYNC AT TIME %d ns", $time);
                errorCount = errorCount + 1;
            end
        end
    end endtask

endmodule
