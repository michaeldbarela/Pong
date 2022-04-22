----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/31/2021 03:36:11 PM
-- Design Name: 
-- Module Name: Loadable_Register - Behavioral
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

entity Loadable_Register is
    Generic(
        WIDTH   : positive := 1
    );
    Port( 
        reset   : in std_logic;
        clk     : in std_logic;
        LD      : in std_logic;
        D       : in std_logic_vector(WIDTH-1 downto 0);
        Q       : out std_logic_vector(WIDTH-1 downto 0)
    );
end Loadable_Register;

architecture Behavioral of Loadable_Register is
begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    process(clk) begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                Q <= (others => '0');
            elsif(LD = '1') then
                Q <= D;      
            end if;
        end if;
    end process;

end Behavioral;
