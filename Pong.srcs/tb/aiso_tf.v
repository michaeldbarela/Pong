`timescale 1ns / 1ps

//**********************************************************************//
//  File Name: aiso_tf                                                  //
//  Description: Testing for aiso reset                                 //
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

module aiso_tf;

//////////////////////////////////////////
//         Signal Declarations
//////////////////////////////////////////
    reg            clk, reset;
    wire           aiso_reset;
    integer        errorCount;
    
//////////////////////////////////////////
//         Device Under Test
//////////////////////////////////////////     
    aiso dut1( .clk( clk ),
               .reset( reset ),
               .aiso_reset( aiso_reset ) );
                   
//////////////////////////////////////////
//      Self Checking Test Bench
//////////////////////////////////////////                               
    //Creates a 100MHz, 10ns period    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; errorCount = 0; 
        #10; reset = 0;
        #20; reset = 1; check_reset;
        if(errorCount == 0)
            $display("NO ERRORS FOUND IN VGA SYNC MODULE.");
        #10; $stop;
    end
    
    //Counts a lot of times
    task check_reset; begin
        //Check after not allowing enought time for the aiso_reset to go high
        if( aiso_reset == 1 ) begin
            $display("ERROR: AISO RESET WENT HIGH TOO EARLY AT TIME %d ns", $time);
                errorCount = errorCount + 1;
        end
        #10; //Wait a clock cycle before checking again, aiso_reset should be high now
        if( aiso_reset != 1 ) begin
            $display("ERROR: AISO RESET NOT WORKING CORRECTLY AT TIME %d ns", $time);
            errorCount = errorCount + 1;
        end  
    end endtask
   
endmodule

