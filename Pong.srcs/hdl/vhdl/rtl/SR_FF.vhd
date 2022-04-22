----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2021 05:04:45 PM
-- Design Name: 
-- Module Name: SR_FF - Behavioral
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

entity SR_FF is
    Port(
        clk     : in std_logic;
        reset   : in std_logic;
        S       : in std_logic;
        R       : in std_logic;
        Q       : out std_logic
    );
end SR_FF;

architecture Behavioral of SR_FF is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal D        : std_logic;
    signal Q_bfr    : std_logic;
    signal SR       : std_logic_vector(1 downto 0);
    
begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    process(clk) begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                Q_bfr <= '0';
            else
                Q_bfr <= D;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    process(clk, reset, S, R) begin
        case(SR) is
            when "00" => D <= Q_bfr;
            when "01" => D <= '0';
            when "10" => D <= '1';
            when others => D <= '0';
        end case;
    end process;
    
    Q <= Q_bfr;
    SR <= S & R;
    
end Behavioral;
