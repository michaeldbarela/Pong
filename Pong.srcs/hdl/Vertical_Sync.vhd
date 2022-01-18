----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022
-- Design Name: 
-- Module Name: Vertical_Sync
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

entity Vertical_Sync is
    Port(
        clk         : in std_logic;
        reset       : in std_logic;
        pulse       : in std_logic;
        h_end       : in std_logic;
        v_video_on  : out std_logic;
        v_end       : out std_logic;
        v_sync      : out std_logic;
        v_count     : out unsigned(9 downto 0)
    );
end Vertical_Sync;

architecture Behavioral of Vertical_Sync is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
    -- vertical display lines
    signal VD           : unsigned(8 downto 0) := to_unsigned(480, 9);
    -- vertical back porch lines
    signal VB           : unsigned(5 downto 0) := to_unsigned(33, 6);
    -- vertical front porch lines
    signal VF           : unsigned(3 downto 0) := to_unsigned(10, 4);
    -- vertical retrace lines
    signal VRT          : unsigned(1 downto 0) := to_unsigned(2, 2);
    -- current vertical sync signal
    signal v_sync_q     : std_logic;
    -- current vertical pixel position
    signal v_count_q    : unsigned(9 downto 0);
    -- next vertical sync signal
    signal v_sync_d     : std_logic;
    -- next vertical pixel position
    signal v_count_d    : unsigned(9 downto 0);
    -- v_end buffer signal
    signal v_end_buf    : std_logic;

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
    -- current-state logic
    process(clk, reset) begin
        if(rising_edge(reset)) then
            v_sync_q <= '0';
            v_count_q <= (OTHERS=>'0');
        elsif(rising_edge(clk)) then
            v_sync_q <= not(v_sync_d);
            v_count_q <= v_count_d;
        end if;
    end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
    process 
        variable concat : std_logic_vector(1 downto 0) := pulse & h_end;
    begin
        case(concat) is
            when "11" => v_count_d <= (OTHERS=>'0') when (v_end_buf='1') else (v_count_q + 1);
            when others => v_count_d <= v_count_q;
        end case;
    end process;

    v_sync_d <= '1' when ((v_count_q >= (VD+VF)) and (v_count_q <= (VD+VF+VRT-1))) else '0';
    v_end_buf <= '1' when (v_count_q = (VD+VB+VF+VRT-1)) else '0';

    -- output signals
    v_end <= v_end_buf;
    v_sync <= v_sync_q;
    v_video_on <= '1' when (v_count_q < VD) else '0';
    v_count <= v_count_q;

end Behavioral;