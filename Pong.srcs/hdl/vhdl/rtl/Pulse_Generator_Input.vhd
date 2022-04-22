----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022
-- Design Name: 
-- Module Name: Pulse_Generator_Input
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

entity Pulse_Generator_Input is
    Generic(
        WIDTH       : positive := 1;
        MAX_COUNT   : std_logic_vector(WIDTH-1 downto 0) := (OTHERS=>'1')
    );
    Port(
        clk         : in std_logic;
        reset       : in std_logic;
        switch      : in std_logic;
        pulse       : out std_logic
    );
end Pulse_Generator_Input;

architecture Behavioral of Pulse_Generator_Input is 
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal D : std_logic_vector(WIDTH-1 downto 0);
    signal Q : std_logic_vector(WIDTH-1 downto 0);

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    -- current-state logic
    process(clk, reset) begin
        if(rising_edge(reset)) then
            Q <= (OTHERS=>'0');
        elsif(rising_edge(clk)) then
            Q <= D;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    -- next-state logic
    process begin
        case(switch) is
            when '1' => D <= (OTHERS=>'0') when (Q = MAX_COUNT) else std_logic_vector(unsigned(Q) + 1);
            when others => D <= (OTHERS=>'0');
        end case;
    end process;

    -- output MAX_COUNT*10ns pulse
    pulse <= '1' when (Q = MAX_COUNT) else '0';

end Behavioral;