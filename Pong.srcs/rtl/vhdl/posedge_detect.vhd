----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/31/2021 03:37:14 PM
-- Design Name: 
-- Module Name: posedge_detect - Behavioral
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

entity posedge_detect is
    Port( 
        reset   : in std_logic;
        clk     : in std_logic;
        level   : in std_logic;
        ped     : out std_logic
    );
end posedge_detect;

architecture Behavioral of posedge_detect is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal delay_Q : std_logic_vector(1 downto 0);
    signal delay_D : std_logic_vector(1 downto 0);

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    process(clk) begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                delay_Q <= "00";
            else
                delay_Q <= delay_D;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    delay_D <= (delay_Q(0) & level);
    ped <= (not(delay_Q(1)) and delay_Q(0));

end Behavioral;
