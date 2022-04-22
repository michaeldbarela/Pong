----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2022
-- Design Name: 
-- Module Name: Left_Wall
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

entity Left_Wall is
    port(
        -- input
        sel         : in std_logic_vector(3 downto 0);
        SW_red      : in std_logic_vector(3 downto 0);
        SW_gre      : in std_logic_vector(3 downto 0);
        SW_blu      : in std_logic_vector(3 downto 0);
        pixel_x     : in std_logic_vector(9 downto 0);
        pixel_y     : in std_logic_vector(9 downto 0);
        -- output
        EN_lw       : out std_logic;
        lw_rgb      : out std_logic_vector(11 downto 0)
    );
end Left_Wall;

architecture Behavioral of Left_Wall is 
----------------------------------------------------------------------------------
-- CONSTANT DECLARATIONS
----------------------------------------------------------------------------------
    -- position of left wall, left side
    constant LWL    : positive := 15;
    -- position of left wall, right side
    constant LWR    : positive := 20;
    -- position of left wall, top side
    constant LWT1   : positive := 40;
    -- position of left wall, top side
    constant LWT2   : positive := 210;
    -- position of left wall, bottom side
    constant LWB1   : positive := 270;
    -- position of left wall, bottom side
    constant LWB2   : positive := 461;

----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal lw_1     : std_logic;
    signal lw_2     : std_logic;

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    -- color determined by switch combinations
    process(all) 
        variable concat : std_logic_vector(11 downto 0) := std_logic_vector(SW_red & SW_gre & SW_blu);
    begin
        case(sel(2 downto 0)) is
            when "000" => lw_rgb <= "111100000000";
            when "010" => lw_rgb <= not(concat);
            when others => lw_rgb <= lw_rgb;
        end case;
    end process;

    -- asserts if the assets are within range of pixel x and pixel y
    lw_1 <= '1' when (unsigned(pixel_x) >= LWL and
                      unsigned(pixel_x) <= LWR and
                      unsigned(pixel_y) >= LWT1 and
                      unsigned(pixel_y) <= LWB1) else '0';
    lw_2 <= '1' when (unsigned(pixel_x) >= LWL and
                      unsigned(pixel_x) <= LWR and
                      unsigned(pixel_y) >= LWT2 and
                      unsigned(pixel_y) <= LWB2) else '0';

    -- asserts if either object is within range and two-player switch is de-asserted
    EN_lw <= '1' when (sel(3) = '0' and
                       (lw_1 = '1' or 
                       lw_2 = '1')) else '0';

end Behavioral;