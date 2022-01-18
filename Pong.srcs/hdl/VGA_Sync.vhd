----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022
-- Design Name: 
-- Module Name: VGA_Sync
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

entity VGA_Sync is
    Port(
        clk         : in std_logic;
        reset       : in std_logic;
        h_sync      : out std_logic;
        v_sync      : out std_logic;
        video_on    : out std_logic;
        pulse       : out std_logic;
        pixel_x     : out unsigned(9 downto 0);
        pixel_y     : out unsigned(9 downto 0)
    );
end VGA_Sync;

architecture Behavioral of VGA_Sync is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    signal h_end            : std_logic;
    signal h_video_on       : std_logic;
    signal v_end            : std_logic;
    signal v_video_on       : std_logic;
    signal pulse_buf        : std_logic;
    -- signals for Pulse_Generator
    signal pulse_gen_width  : positive := 2;
    signal pulse_gen_max    : std_logic_vector := std_logic_vector(to_unsigned(4,pulse_gen_width));

begin
----------------------------------------------------------------------------------
-- ENTITY INSTANTIATION OF LOWER LEVEL MODULES
----------------------------------------------------------------------------------
    puls_gene: entity work.Pulse_Generator
        Generic map(
            WIDTH => pulse_gen_width,
            MAX_COUNT => pulse_gen_max
        )
        Port map(
            clk => clk,
            reset => reset,
            pulse => pulse_buf
        );

    hori_sync: entity work.Horizontal_Sync
        Port map(
            clk => clk,
            reset => reset,
            pulse => pulse_buf,
            h_video_on => h_video_on,
            h_end => h_end,
            h_sync => h_sync,
            h_count => pixel_x
        );

    vert_sync: entity work.Vertical_Sync
        Port map(
            clk => clk,
            reset => reset,
            pulse => pulse_buf,
            h_end => h_end,
            v_video_on => v_video_on,
            v_end => v_end,
            v_sync => v_sync,
            v_count => pixel_y
        );

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    pulse <= pulse_buf;
    -- turn the video on or off
    video_on <= (h_video_on and v_video_on);

end Behavioral;