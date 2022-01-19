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
        sel         : in std_logic_vector(3 downto 0);
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
-- CONSTANT DECLARATIONS
----------------------------------------------------------------------------------
    constant BALL_SIZE      : positive := 3;
    -- length of the left wall left side
    constant LWL            : positive := 15;
    -- length of the left wall right side
    constant LWR            : positive := 20;
    -- length of the left wall top side 1
    constant LWT1           : positive := 40;
    -- length of the left wall bottom side 1
    constant LWB1           : positive := 210;
    -- length of the left wall top side 2
    constant LWT2           : positive := 270;
    -- length of the left wall bottom side 2
    constant LWB2           : positive := 461;
    -- length of the right paddle left side
    constant RPL            : positive := 603;
    -- length of the right paddle right side
    constant RPR            : positive := 608;
    -- length of the left paddle left side
    constant LPL            : positive := 15;
    -- length of the left paddle right side
    constant LPR            : positive := 20;
    -- length of the top wall bottom side
    constant TWB            : positive := 39;
    -- length of the bottom wall top side
    constant BWT            : positive := 462;

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

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    -- current-state logic
    process(clk, reset) begin
        if(rising_edge(reset)) then
            pause_Q <= '1'; -- start game in a paused state
            ball_x_Q <= std_logic_vector(to_unsigned(320, ball_x_Q'length)); -- start at this x-coordinate
            ball_y_Q <= std_logic_vector(to_unsigned(240, ball_y_Q'length)); -- start at this y-coordinate
            x_dir_Q <= '0'; -- start going left
            y_dir_Q <= '0'; -- start going down
            score_l_Q <= (OTHERS=>'0'); -- start left score at 0
            score_r_Q <= (OTHERS=>'0'); -- start right score at 0
        elsif(rising_edge(clk)) then
            pause_Q <= pause_D;
            ball_x_Q <= ball_x_D;
            ball_y_Q <= ball_y_D;
            x_dir_Q <= x_dir_D;
            y_dir_Q <= y_dir_D;
            score_l_Q <= score_l_D;
            score_r_Q <= score_r_D;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    process 
        variable concat : std_logic_vector(11 downto 0) := std_logic_vector(SW_red & SW_gre & SW_blu);
    begin
        -- determine color of asset based on switches
        case(sel(2 downto 0))is 
            when "000" => ball_rgb <= (OTHERS=>'0');
            when "001" => ball_rgb <= concat;
            when others => ball_rgb <= ball_rgb;
        end case;

        -- detenmine next location of the ball
        if(pause_Q = '1') then
            pause_D <= '0' when (delay='1') else '0'; -- pause for three sec if 1
            ball_x_D <= ball_x_Q; -- ball will not move
            ball_y_D <= ball_y_Q; -- ball will not move
        elsif(tick = '1') then
            pause_D <= '0'; -- game is no longer paused
            ball_x_D <= std_logic_vector(unsigned(ball_x_Q) + 1) when (x_dir_Q='1') else std_logic_vector(unsigned(ball_x_Q) + 1);
            ball_y_D <= std_logic_vector(unsigned(ball_y_Q) + 1) when (y_dir_Q='1') else std_logic_vector(unsigned(ball_y_Q) + 1);
        else
            pause_D <= '0'; -- game is no longer paused
            ball_x_D <= ball_x_Q; -- ball will move
            ball_y_D <= ball_y_Q; -- ball will move
        end if;

        -- resets ball to center after a goal, pauses, and increments score

        -- changes direction after a bounce
        --  x: =0 means left; =1 means right
        --  y: =0 means down; =1 means up

    end process;

    -- detemine ball boundaries

    -- determine if ball hits an object

    -- determine if there was a goal

    -- assert if ball is within range of pixel x and pixel y

end Behavioral;