----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/02/2021 08:15:34 PM
-- Design Name: 
-- Module Name: Pulse_Generator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Pulse_Generator is
    Generic(
        WIDTH       : positive := 1;
        MAX_COUNT   : std_logic_vector(WIDTH-1 downto 0) := (OTHERS=>'1')
    );
    Port( 
        clk         : in std_logic;
        reset       : in std_logic;
        pulse       : out std_logic
    );
end Pulse_Generator;

architecture Behavioral of Pulse_Generator is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal D : std_logic_vector(WIDTH-1 downto 0);
    signal Q : std_logic_vector(WIDTH-1 downto 0);
    
begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    process(clk) begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                Q <= (others => '0');
            else
                Q <= D;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    process begin
        if(Q = MAX_COUNT) then 
            D <= (others => '0');
        else
            D <= std_logic_vector(unsigned(Q) + 1);
        end if;
    end process;
    
    pulse <= '1' when (Q = MAX_COUNT) else '0';

end Behavioral;
