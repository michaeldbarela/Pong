----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/31/2021 03:36:43 PM
-- Design Name: 
-- Module Name: AISO_Reset - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AISO_Reset is
    Port( 
        reset       : in std_logic;
        clk         : in std_logic;
        aiso_reset  : out std_logic
    );
end AISO_Reset;

architecture Behavioral of AISO_Reset is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal Q1 : std_logic;
    signal Q2 : std_logic;
    
begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    -- active low reset
    process(clk, reset) begin
        if(rising_edge(clk) or falling_edge(reset)) then
            if(reset = '0') then
                Q1 <= '0';
            else
                Q1 <= '1';
            end if;
        end if;
    end process;
    
    process(clk) begin
        if(rising_edge(clk)) then
            Q2 <= Q1;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    aiso_reset <= not(Q2);

end Behavioral;
