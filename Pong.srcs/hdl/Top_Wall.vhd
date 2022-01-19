----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2022
-- Design Name: 
-- Module Name: Top_Wall
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

entity Top_Wall is 
    Port(
        -- input
        sel         : in std_logic_vector(2 downto 0);
        SW_red      : in std_logic_vector(3 downto 0);
        SW_gre      : in std_logic_vector(3 downto 0);
        SW_blu      : in std_logic_vector(3 downto 0);
        pixel_x     : in std_logic_vector(9 downto 0);
        pixel_y     : in std_logic_vector(9 downto 0);
        -- output
        EN_tw       : out std_logic;
        tw_rgb      : out std_logic_vector(11 downto 0)
    );
end Top_Wall;

architecture Behavioral of Top_Wall is
----------------------------------------------------------------------------------
-- CONSTANT DECLARATIONS
----------------------------------------------------------------------------------
    -- position of top wall, left side
    constant TWL    : positive := 5;
    -- position of top wall, right side
    constant TWR    : positive := 635;
    -- position of top wall, top side
    constant TWT    : positive := 37;
    -- position of top wall, bottom side
    constant TWB    : positive := 39;

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
            when "000" => tw_rgb <= (OTHERS=>'1');
            when "001" => tw_rgb <= concat;
            when others => tw_rgb <= tw_rgb;
        end case;
    end process;

    -- asserts is the asset is within range of pixel x and pixel y
    EN_tw <= '1' when (unsigned(pixel_x)>=TWL and 
                       unsigned(pixel_x)<=TWR and 
                       unsigned(pixel_y)>=TWT and 
                       unsigned(pixel_y)<=TWB) else '0';

end Behavioral;