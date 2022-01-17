----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2022
-- Design Name: 
-- Module Name: Horizontal_Sync
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

entity Horizontal_Sync is
	Port(
		clk 		: in std_logic;
		reset 		: in std_logic;
		pulse 		: in std_logic;
		h_end 		: out std_logic;
		h_sync 		: out std_logic;
		h_video_on	: out std_logic;
		h_count 	: out unsigned(9 downto 0)
	);
end Horizontal_Sync;

architecture Behavioral of Horizontal_Sync is
----------------------------------------------------------------------------------
-- SIGNAL DECLARATIONS
----------------------------------------------------------------------------------
	-- horizontal display pixels
	signal HD 			: unsigned(9 downto 0) := to_unsigned(640, 10);
	-- horizontal front porch pixels
	signal HF 			: unsigned(3 downto 0) := to_unsigned(16, 4);
	-- horizontal back porch pixels
	signal HB 			: unsigned(5 downto 0) := to_unsigned(48, 6);
	-- horizontal retrace pixels
	signal HRT 			: unsigned(7 downto 0) := to_unsigned(98, 8);
	-- current horizontal sync signal
	signal h_sync_q		: std_logic;
	-- current horizontal pixel position
	signal h_count_q	: unsigned(9 downto 0);
	-- next horizontal sync signal
	signal h_sync_d		: std_logic;
	-- next horizonal pixel position
	signal h_count_d 	: unsigned(9 downto 0);
	-- h_end buffer signal
	signal h_end_buf	: std_logic;

begin
----------------------------------------------------------------------------------
-- SEQUENTIAL LOGIC
----------------------------------------------------------------------------------
	-- state logic
	process(clk, reset) begin
	   if(rising_edge(reset)) then
			h_sync_q <= '0';
			h_count_q <= (OTHERS => '0');
		elsif(rising_edge(clk)) then
			h_sync_q <= not(h_sync_q);
			h_count_q <= h_count_d;
		end if;
	end process;

----------------------------------------------------------------------------------
-- COMBINATIONAL LOGIC
----------------------------------------------------------------------------------
	process begin
		case(pulse) is
			--when '1' => h_count_d <= (OTHERS=>'0') when (h_end='1') else (h_count_q + '1');
			when '1' => h_count_d <= (OTHERS=>'0') when (h_end_buf='1');
			when others => h_count_d <= h_count_q;
		end case;
	end process;

	h_sync_d <= '1' when ((h_count_q >= (HD+HF)) and (h_count_q <= (HD+HF+HRT-1))) else '0';
	h_end_buf <= '1' when (h_count_q = (HD+HB+HF+HRT-1)) else '0';
	
	-- output signals
	h_end <= h_end_buf;
	h_sync <= h_sync_q;
	h_video_on <= '1' when (unsigned(h_count_q) < unsigned(HD)) else '0';
	h_count <= h_count_q;

end Behavioral;
