library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity stepper is
  port (
    clk: in std_logic;       -- clock I/P
    CW_CCW: in std_logic;    -- direction control
    Rst: in std_logic;       -- system reset
    Step_En: in std_logic;   -- step enable
    FS_HS: in std_logic;     -- Half step / Full step control
    W1, W2, W3, W4: out std_logic -- Winding o/ps
  );
end stepper;

architecture behave of stepper is
  type state is (reset, first, second, third, fourth, half1, half2, half3, half4);
  
  signal clk_s: std_logic; -- divided clock signal
  signal Ps_state, Nx_state: state; -- señales de control de estados -present -next
  signal motor: std_logic_vector(3 downto 0);
  
  -- divisor de frecuencia
	component div_frec
		
	port(
		-- Input ports
		clk: in  std_logic;
		Rst: in std_logic;
		Nciclos: in	integer;			-- número de ciclos para la frecuencia deseada
		-- Output ports
		f: out std_logic);
		
	end component;
  
begin


-- divisores de frecuencia 

--Div_frec_400hz: div_frec port map(clk,Rst,62500,clk_s ); 
Div_frec_500hz: div_frec port map(clk,Rst,50000,clk_s );
--  process (clk, Rst)
--  begin
--    if Rst = '0' then
--      div <= (others => '0');
--    elsif clk'event and clk = '1' then
--      div <= div + 1;
--    end if;
--  end process;
--
--  -- Divisor de CLK
--  -- Cambiar el valor entre paréntesis para la velocidad del motor.
--  clk_s <= div(16);
  
  process (clk_s, Rst)
  begin
    if Rst = '0' then
      Ps_state <= reset;
	 elsif rising_edge(clk_s) then
		if Step_En = '1' then
        Ps_state <= Nx_state;
      end if;
    end if;
  end process;
  
  
  -- Maquina de estados

  process (Ps_state, CW_CCW, Step_En, Rst, FS_HS)
  begin
    case Ps_state is
      when reset =>
        Nx_state <= first;
      when first =>
        if FS_HS = '0' then -- FS_HS='1' then HALF STEPs
          if CW_CCW = '1' then
            Nx_state <= second;
          else
            Nx_state <= fourth;
          end if;
        else
          if CW_CCW = '1' then
            Nx_state <= half1;
          else
            Nx_state <= half4;
          end if;
        end if;
      when half1 =>
        if CW_CCW = '1' then
          Nx_state <= second;
        else
          Nx_state <= first;
        end if;
      when second =>
        if FS_HS = '0' then -- FS_HS='1' then HALF STEPs
          if CW_CCW = '1' then
            Nx_state <= third;
          else
            Nx_state <= first;
          end if;
        else
          if CW_CCW = '1' then
            Nx_state <= half2;
          else
            Nx_state <= half1;
          end if;
        end if;
      when half2 =>
        if CW_CCW = '1' then
          Nx_state <= third;
        else
          Nx_state <= second;
        end if;
      when third =>
        if FS_HS = '0' then -- FS_HS='1' then HALF STEPs
          if CW_CCW = '1' then
            Nx_state <= fourth;
          else
            Nx_state <= second;
          end if;
        else
          if CW_CCW = '1' then
            Nx_state <= half3;
          else
            Nx_state <= half2;
          end if;
        end if;
      when half3 =>
        if CW_CCW = '1' then
          Nx_state <= fourth;
        else
          Nx_state <= third;
        end if;
      when fourth =>
        if FS_HS = '0' then -- FS_HS='1' then HALF STEPs
          if CW_CCW = '1' then
            Nx_state <= first;
          else
            Nx_state <= third;
          end if;
        else
          if CW_CCW = '1' then
            Nx_state <= half4;
          else
            Nx_state <= half3;
          end if;
        end if;
      when half4 =>
        if CW_CCW = '1' then
          Nx_state <= first;
        else
          Nx_state <= fourth;
        end if;
      when others =>
        Nx_state <= reset;
    end case;
  end process;

  -- Assigning O/Ps
  W4 <= motor(3);
  W3 <= motor(2);
  W2 <= motor(1);
  W1 <= motor(0);

  process (Ps_state)
  begin
    case Ps_state is
      when reset =>
        motor <= "0000"; -- assigning motor control on/off -- Asignar on/off del motor
      when first =>
        motor <= "1000";
      when half1 =>
        motor <= "1100";
      when second =>
        motor <= "0100";
      when half2 =>
        motor <= "0110";
      when third =>
        motor <= "0010";
      when half3 =>
        motor <= "0011";
      when fourth =>
        motor <= "0001";
      when half4 =>
        motor <= "1001";
      when others =>
        motor <= "0000";
    end case;
  end process;

end behave;