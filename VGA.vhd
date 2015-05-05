-- Shawn Jiang
-- VGA Display Main Component

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA is
	port
	(
	 clk        : in std_logic;
	 main_reset : in std_logic;
	 h_sync_out : out std_logic;
	 v_sync_out : out std_logic;
	 d_red      : out std_logic_vector(3 downto 0);
	 d_green    : out std_logic_vector(3 downto 0);
	 d_blue     : out std_logic_vector(3 downto 0);
	 L1         : in std_logic; -- Left Key
	 R1         : in std_logic; -- Right Key
	 U1         : in std_logic; -- Up Key
	 D1         : in std_logic -- Down Key
	);
	
	end VGA;

architecture rtl of VGA is
	
	-- Link in the Pixel Clock
	component altpll1 is
		PORT
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0		      : OUT STD_LOGIC 
		);
	end component;
	
	-- Link in the Controller
	component VGAController is
	
		port
	   (
		 pixel_clk : in std_logic;  -- Pixel Clock at frequency 40 MHz
		 reset     : in std_logic;  -- Reset Button
		 h_sync    : out std_logic; -- Horizonal Sync Signal
		 v_sync    : out std_logic; -- Vertical Sync Signal
		 denable   : out std_logic; -- Display enabler
		 row       : out integer;   -- Y pixel value (0 = top row)
		 column    : out integer   -- X pixel value (0 = leftmost column)
	);
	end component;
	
	-- Link in the Display
	component IGF is
		port(
		clk            : in std_logic;
		reset          : in std_logic;
		enable         : in std_logic; -- Display Enable
		row_point      : in integer; -- Row Coordinate
		column_point	: in integer; -- Column Coordinate
		L              : in std_logic; -- Left Key
		R              : in std_logic; -- Right Key
		U              : in std_logic; -- Up Key
		D              : in std_logic; -- Down Key
		red            : out std_logic_vector(3 downto 0);
		green          : out std_logic_vector(3 downto 0);
		blue           : out std_logic_vector(3 downto 0)
	);
	end component;
	
	-- Signals
	signal pix_clk  : std_logic;
	signal d_enable : std_logic;
	signal row_num  : integer;
	signal col_num  : integer;
	
begin
	
	altpll11 : altpll1 port map(inclk0 => clk, c0 => pix_clk);
	VGAController1 : VGAController port map(pixel_clk => pix_clk, reset => main_reset, h_sync => h_sync_out, v_sync => v_sync_out, denable => d_enable, row => row_num, column => col_num);
	IGF1 : IGF port map(clk => pix_clk, reset => main_reset, enable => d_enable, row_point => row_num, column_point => col_num, L => L1, R => R1, U => U1, D => D1, red => d_red, green => d_green, blue => d_blue);
	
end rtl;
	