library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BitArduino is
  Port (
    input_signal : in std_logic;
    led : out std_logic
  );
end entity BitArduino;

architecture Behavioral of BitArduino is
begin
  process(input_signal)
  begin
    if input_signal = '1' then
      led <= '1';
    else
      led <= '0';
    end if;
  end process;
end architecture Behavioral;
