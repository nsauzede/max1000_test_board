--=============================================================================
--
-- Case statement sequence
--
--=============================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity case_state_seq is
  generic ( 
    cnt_clk_max : integer := 1_000_000
  );
	
  port (		
    clk     : in  std_logic;
    sel     : in  std_logic;
    led_out : out std_logic_vector(7 downto 0)
  );
end entity;

architecture behavioural of case_state_seq is
	
  signal cnt_led	: std_logic_vector(3 downto 0);
  signal cnt_clk	: integer range 0 to cnt_clk_max;
	
begin
-------------------------------------------------------------------------------
-- counter
-------------------------------------------------------------------------------
  process (clk, sel)
  begin
    if sel = '0' then
      cnt_clk <= 0;
      cnt_led <= (others => '0');
    elsif rising_edge(clk) then
      if cnt_clk = (cnt_clk_max - 1) then
        cnt_clk <= 0;
        cnt_led <= cnt_led + '1';
      else
        cnt_clk <= cnt_clk + 1;
      end if;
    end if;
  end process;

-------------------------------------------------------------------------------
-- LED output
-------------------------------------------------------------------------------
  process (cnt_led, sel)
  begin
    if sel = '1' then
      case cnt_led is
        when "0000" => led_out <=  "00000000";
        when "0001" => led_out <=  "10000001";
        when "0010" => led_out <=  "01000010";
        when "0011" => led_out <=  "00100100";
        when "0100" => led_out <=  "00011000";
        when "0101" => led_out <=  "00100100";
        when "0110" => led_out <=  "01000010";
        when "0111" => led_out <=  "10000001";
        when "1000" => led_out <=  "10000001";
        when "1001" => led_out <=  "11000011";
        when "1010" => led_out <=  "11100111";
        when "1011" => led_out <=  "11111111";
        when "1100" => led_out <=  "11100111";
        when "1101" => led_out <=  "11000011";
        when "1110" => led_out <=  "10000001";
        when "1111" => led_out <=  "00000000";
        when others => led_out <=  "00000000";
      end case;
    else 
      led_out <=  "00000000";
    end if;
  end process;

end architecture;