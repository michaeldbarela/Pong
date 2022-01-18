----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2022
-- Design Name: 
-- Module Name: Ball
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

entity Ball is 
    Port(
        -- input
        clk         : in std_logic;
        reset       : in std_logic;
        tick        : in std_logic;
        delay       : in std_logic;
        select      : in std_logic_vector(3 downto 0);
        SW_red      : in std_logic_vector(3 downto 0);
        SW_gre      : in std_logic_vector(3 downto 0);
        SW_blu      : in std_logic_vector(3 downto 0);
        RPT         : in std_logic_vector(9 downto 0);
        RPB         : in std_logic_vector(9 downto 0);
        LPT         : in std_logic_vector(9 downto 0);
        LPB         : in std_logic_vector(9 downto 0);
        pixel_x     : in std_logic_vector(9 downto 0);
        pixel_y     : in std_logic_vector(9 downto 0);
        -- output
        EN_ball     : out std_logic;
        pause       : out std_logic;
        score_l     : out std_logic_vector(3 downto 0);
        score_r     : out std_logic_vector(3 downto 0);
        ball_rgb    : out std_logic_vector(11 downto 0)
    );
end Ball;

architecture Behavioral of Ball is 
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal bounce_top       : std_logic;
    signal bounce_bot       : std_logic;
    signal bounce_r_pad     : std_logic;
    signal bounce_l_pad     : std_logic;
    signal bounce_l_wall    : std_logic;
    signal right_goal       : std_logic;
    signal left_goal        : std_logic;
    signal goal             : std_logic;
    signal x_dir_Q          : std_logic;
    signal x_dir_D          : std_logic;
    signal y_dir_Q          : std_logic;
    signal y_dir_D          : std_logic;
    signal pause_Q          : std_logic;
    signal pause_D          : std_logic;
    signal score_l_Q        : std_logic_vector(3 downto 0);
    signal score_l_D        : std_logic_vector(3 downto 0);
    signal score_r_Q        : std_logic_vector(3 downto 0);
    signal score_r_D        : std_logic_vector(3 downto 0);
    signal ball_l           : std_logic_vector(9 downto 0);
    signal ball_r           : std_logic_vector(9 downto 0);
    signal ball_t           : std_logic_vector(9 downto 0);
    signal ball_b           : std_logic_vector(9 downto 0);
    signal ball_x_Q         : std_logic_vector(9 downto 0);
    signal ball_x_D         : std_logic_vector(9 downto 0);
    signal ball_y_Q         : std_logic_vector(9 downto 0);
    signal ball_y_D         : std_logic_vector(9 downto 0);
    variable ball_size      : positive := 3;


begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------

end Behavioral;