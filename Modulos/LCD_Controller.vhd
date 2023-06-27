library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_Controller is
  port (
    clk: in std_logic;
    reset: in std_logic;
    rs: buffer std_logic;
    rw: buffer std_logic;
    enable: buffer std_logic;
    data: buffer std_logic_vector(3 downto 0);
    address: buffer std_logic_vector(7 downto 0)
  );
end entity LCD_Controller;

architecture behavioral of LCD_Controller is
  -- Parámetros de configuración del display
  constant DATA_WIDTH: integer := 4;  -- Ancho de datos de la interfaz (4 bits)
  constant CMD_DELAY: integer := 4;   -- Retardo para comandos (en ciclos de reloj)
  constant DATA_DELAY: integer := 1;  -- Retardo para datos (en ciclos de reloj)

  -- Definición de los estados
  type state_type is (IDLE, SEND_CMD, SEND_DATA, DELAY_CMD, DELAY_DATA);
  signal state: state_type;
  signal count: unsigned(7 downto 0);

  -- Señales internas del módulo
  signal rs_reg, rw_reg, enable_reg: std_logic;
  signal data_reg: std_logic_vector(3 downto 0);
  signal address_reg: std_logic_vector(7 downto 0);

  -- Constantes para comandos y direcciones
  constant CLEAR_DISPLAY: std_logic_vector(7 downto 0) := "00000001";
  constant RETURN_HOME: std_logic_vector(7 downto 0) := "00000010";
  -- Otras constantes de comandos y direcciones...

begin
  process (clk, reset)
  begin
    if reset = '1' then
      state <= IDLE;
      count <= (others => '0');
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          if enable = '1' then
            if rs = '1' then
              state <= SEND_DATA;
            else
              state <= SEND_CMD;
            end if;
          end if;

        when SEND_CMD =>
          rs_reg <= rs;
          rw_reg <= rw;
          enable_reg <= '1';
          data_reg <= data;
          address_reg <= address;
          count <= count + 1;

          if to_integer(count) >= CMD_DELAY then
            enable_reg <= '0';
            count <= (others => '0');
            state <= DELAY_CMD;
          end if;

        when SEND_DATA =>
          rs_reg <= rs;
          rw_reg <= rw;
          enable_reg <= '1';
          data_reg <= data;
          address_reg <= address;
          count <= count + 1;

          if to_integer(count) >= DATA_DELAY then
            enable_reg <= '0';
            count <= (others => '0');
            state <= DELAY_DATA;
          end if;

        when DELAY_CMD =>
          rs_reg <= rs;
          rw_reg <= rw;
          enable_reg <= '0';
          data_reg <= data;
          address_reg <= address;
          count <= count + 1;

          if to_integer(count) >= CMD_DELAY then
            count <= (others => '0');
            state <= IDLE;
          end if;

        when DELAY_DATA =>
          rs_reg <= rs;
          rw_reg <= rw;
          enable_reg <= '0';
          data_reg <= data;
          address_reg <= address;
          count <= count + 1;

          if to_integer(count) >= DATA_DELAY then
            count <= (others => '0');
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

  rs <= rs_reg;
  rw <= rw_reg;
  enable <= enable_reg;
  data <= data_reg;
  address <= address_reg;

end architecture behavioral;