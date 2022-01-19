----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2022
-- Design Name: 
-- Module Name: Bottom_Wall
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

entity Bottom_Wall is
    port(
        -- input
        sel         : in std_logic_vector(2 downto 0);
        SW_red      : in std_logic_vector(3 downto 0);
        SW_gre      : in std_logic_vector(3 downto 0);
        SW_blu      : in std_logic_vector(3 downto 0);
        pixel_x     : in std_logic_vector(9 downto 0);
        pixel_y     : in std_logic_vector(9 downto 0);
        -- output
        EN_bw       : out std_logic;
        bw_rgb      : out std_logic_vector(11 downto 0)
    );
end Bottom_Wall; -- Bottom_Wall

architecture Behavioral of Bottom_Wall is 

----------------------------------------------------------------------------------
-- CONSTANT DECLARATIONS
----------------------------------------------------------------------------------
    -- position of bottom wall, left side
    constant BWL    : positive := 5;
    -- position of bottom wall, right side
    constant BWR    : positive := 635;
    -- position of bottom wall, top side
    constant BWT    : positive := 462;
    -- position of bottom wall, bottom side
    constant BWB    : positive := 464;

----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------

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
        case(sel) is
            when "000" => bw_rgb <= (OTHERS=>'1');
            when "001" => bw_rgb <= concat;
            when others => bw_rgb <= bw_rgb;
        end case;
    end process;

    -- asserts if the asset is within range of pixel x and pixel y
    EN_tw <= '1' when (unsigned(pixel_x) >= BWL and 
                       unsigned(pixel_x) <= BWR and 
                       unsigned(pixel_y) >= BWT and 
                       unsigned(pixel_y) <= BWB) else '0';

end Behavioral;