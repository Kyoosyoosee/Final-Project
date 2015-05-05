-- Shawn Jiang
-- VGA Controller
-- Filename: VGAController
-- This Controller is made for use with a resolution
-- of 800 x 600 with 60 Hz timing and a
-- a pixel frequency of 40 MHz

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGAController is

	-- Sets up the default values for 1600 x 1200
	generic(
		h_width    : integer := 1280; -- Horizontal Pixel Width
		h_fp       : integer := 80;  -- Horizontal Front Porch
		h_bp       : integer := 216;  -- Horizontal Back Porch
		h_polarity : std_logic := '1'; -- Horizontal Polarity (1 = positive)
		h_sp       : integer := 136; -- Horizontal Sync Pulse
		
		v_width    : integer := 960; -- Vertical Pixel Width
		v_fp       : integer := 1;   -- Vertical Front Porch
		v_bp       : integer := 30;  -- Vertical Back Porch
		v_polarity : std_logic := '1'; -- Vertical Polarity (1 = positive)
		v_sp       : integer := 3    -- Vertical Sync Pulse
	);
		
	port(
		pixel_clk : in std_logic;  -- Pixel Clock at frequency 40 MHz
		reset     : in std_logic;  -- Reset Button
		h_sync    : out std_logic; -- Horizonal Sync Signal
		v_sync    : out std_logic; -- Vertical Sync Signal
		denable   : out std_logic; -- Display enabler
		row       : out integer;   -- Y pixel value (0 = top row)
		column    : out integer   -- X pixel value (0 = leftmost column)
	);
end entity; 

architecture GreekGod of VGAController is
	
	constant h_total : integer := h_width + h_sp + h_fp + h_bp;  -- Total number of pixels in a row
	constant v_total : integer := v_width + v_sp + v_fp + v_bp; -- Total number of pixels in a column
	
	-- Create Horizontal and Vertical Counters
	signal hpos : integer range 0 to h_total - 1 := 0; -- Horizontal Position Counter
	signal vpos : integer range 0 to v_total - 1 := 0; -- Vertical Position Counter
	
begin
	
	Process(pixel_clk,reset)
	begin
		
		-- Reset the Display
		if reset = '0' then
		
			row <= 0;
			column <= 0;
			
			-- Reset the Counters
			hpos <= 0;
			vpos <= 0;
			
			-- Set the Display Enable to 0
			denable <= '0';
			
			-- Invert the Sync Polarities
			h_sync <= not h_polarity;
			v_sync <= not v_polarity;
		
		elsif (rising_edge(pixel_clk)) then
			
			-- Loop Through the Horizonal Pixels on one Row, then shift rows
			if (hpos < h_total -1) then
				hpos <= hpos + 1;
			else
				hpos <= 0; -- Reset the horizonal position
				if (vpos < v_total -1) then -- Shift the Vertical Position and restart the loop
					vpos <= vpos + 1;
				else
					vpos <= 0;
				end if;
			end if;
			
			-- Horizonal Syncing
			if ((hpos > h_fp) and (hpos < h_bp)) then  -- check to see if the counter is betwen the display length and the back porch
				h_sync <= not h_polarity;
			else
				h_sync <= h_polarity;
			end if;
			
			-- Vertical Syncing
			if ((vpos > v_fp) and (vpos < v_bp)) then  -- check to see if the counter is betwen the display length and the back porch
				v_sync <= not v_polarity;
			else
				v_sync <= v_polarity;
			end if;
			
			-- Set Pixel Locations
			if (hpos > (h_fp + h_bp + h_sp) and hpos < h_total) then
				column <= hpos - (h_fp + h_bp + h_sp);  -- set the current horizontal position to the column
			end if;
			
			if (vpos > (v_fp + v_bp + v_sp) and vpos < v_total) then
				row <= vpos - (v_fp + v_bp + v_sp);  -- set the current vertical position to the row
			end if;
			
			-- Display Enable
			if (hpos > (h_fp + h_bp + h_sp) and hpos < h_total and vpos > (v_fp + v_bp + v_sp)  and vpos < v_total) then	
				denable <= '1';											 	--enable display
			else																	
				denable <= '0';												--disable display
			end if;
				
		end if;
	end process;
end GreekGod;
