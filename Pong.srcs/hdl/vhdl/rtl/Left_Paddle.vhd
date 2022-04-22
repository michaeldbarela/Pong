----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2022
-- Design Name: 
-- Module Name: Left_Paddle
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

entity Left_Paddle is
    port(
        -- input
        clk         : in std_logic;
        reset       : in std_logic;
        tick        : in std_logic;
        pl_2        : in std_logic_vector(1 downto 0);
        sel         : in std_logic_vector(3 downto 0);
        SW_red      : in std_logic_vector(3 downto 0);
        SW_gre      : in std_logic_vector(3 downto 0);
        SW_blu      : in std_logic_vector(3 downto 0);
        pixel_x     : in std_logic_vector(9 downto 0);
        pixel_y     : in std_logic_vector(9 downto 0);
        -- output
        EN_lp       : out std_logic;
        lpt         : out std_logic_vector(9 downto 0);
        lpb         : out std_logic_vector(9 downto 0);
        lp_rgb      : out std_logic_vector(11 downto 0)
    );
end Left_Paddle;

architecture Behavioral of Left_Paddle is 
----------------------------------------------------------------------------------
-- CONSTANT DECLARATIONS
----------------------------------------------------------------------------------
    -- length of left paddle
    constant LP_LENGTH      : positive := 36;
    -- position of left paddle, left side
    constant LPL    : positive := 15;
    -- position of left paddle, right side
    constant LPR    : positive := 20;
    -- position of top wall, bottom side
    constant TWB    : positive := 39;
    -- position of bottom wall, top side
    constant BWT    : positive := 462;

----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal lpt_Q    : std_logic_vector(9 downto 0);
    signal lpt_D    : std_logic_vector(9 downto 0);

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    -- current-state logic
    process(clk, reset) begin
        if(rising_edge(reset)) then
            lpt_Q <= std_logic_vector(to_unsigned(231, lpt_Q'length));
        elsif(rising_edge(clk)) then
            lpt_Q <= lpt_D;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    process(all) 
        variable colors : std_logic_vector(11 downto 0) := std_logic_vector(SW_red & SW_gre & SW_blu);
        variable switches : std_logic_vector((1 + pl_2'length) downto 0) := std_logic_vector(tick & pl_2);
    -- color determined by switch combinations
    begin
        case(sel(2 downto 0)) is
            when "000" => lp_rgb <= "111100000000";
            when "010" => lp_rgb <= not(colors);
            when others => lp_rgb <= lp_rgb;
        end case;
        -- next-state logic
        case(switches) is 
            when "101" => lpt_D <= lpt_Q when (unsigned(lpb) >= (BWT-4)) else (lpt_Q + 4);
            when "110" => lpt_D <= lpt_Q when (unsigned(lpt) <= (TWB+4)) else (lpt_Q - 4);
            when others => lpt_D <= lpt_Q;
        end case;
    end process;

    lpt <= lpt_Q;

    -- assigns the position of the bottom of the paddle
    lpb <= std_logic_vector(unsigned(lpt) + LP_LENGTH);

    -- assert if the asset is within range of pixel x and pixel y
    EN_LP <= '1' when (sel(3) = '1' and
                       unsigned(pixel_x) <= LPL and
                       unsigned(pixel_x) >= LPR and
                       unsigned(pixel_y) >= unsigned(lpt) and
                       unsigned(pixel_y) <= unsigned(lpb)) else '0';

end Behavioral;