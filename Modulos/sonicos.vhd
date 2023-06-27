library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity sonicos is
port(clk: in std_logic;
	--sensor
	sensor_disp:out std_logic;
	sensor_eco: in std_logic;

	--distancia
	displayunidades: out std_logic_vector(6 downto 0);
	displaydecenas: out std_logic_vector(6 downto 0)
	
	--digitounidad1: out std_logic_vector(3 downto 0)

	);
	
end sonicos;

architecture Behavioral of sonicos is
	signal cuenta: unsigned(16 downto 0) := (others => '0');
	
	--conversión de unidades
	
	signal centimetros: unsigned(15 downto 0) := (others => '0');
	signal centimetros_unid: unsigned(3 downto 0) := (others => '0');
	signal centimetros_dece: unsigned(3 downto 0) := (others => '0');
	signal sal_unid: unsigned(3 downto 0) := (others => '0');
	signal sal_dece: unsigned(3 downto 0) := (others => '0');
	signal digitounidad: unsigned(3 downto 0) := (others => '0');
	signal digitodecena: unsigned(3 downto 0) := (others => '0');
	
	
	
	--señales del sensor
	
	signal eco_pasado: std_logic := '0';
	signal eco_sinc: std_logic := '0';
	signal eco_nsinc: std_logic := '0';
	
	signal espera: std_logic := '0';
	signal siete_seg_cuenta: unsigned(15 downto 0) := (others => '0');
	
begin
--displays
--trabajo del sensor
	Trigger: process(clk)
	begin
	if rising_edge(clk) then
		if espera='0' then
		
			if cuenta = 500 then
				sensor_disp <= '0';
				espera <= '1';
				cuenta <= (others => '0');
			else
				sensor_disp <= '1';
				cuenta <= cuenta + 1;
			end if;
			
		--distancia
		elsif eco_pasado = '0' and eco_sinc = '1' then
			cuenta <= (others => '0');
			centimetros <=(others =>'0');
			centimetros_unid <= (others => '0');
			centimetros_dece <= (others => '0');
			
		elsif eco_pasado = '1' and eco_sinc = '0' then
			sal_unid <= centimetros_unid;
			sal_dece <= centimetros_dece;
			digitounidad <= sal_unid;
			digitodecena <= sal_dece;
			
		elsif cuenta = 2900-1 then
			if centimetros_unid = 9 then
				centimetros_unid <= (others => '0');
				centimetros_dece <= centimetros_dece + 1;
			else
				centimetros_unid <= centimetros_unid + 1;
			end if;
			centimetros <= centimetros + 1;
			cuenta <= (others => '0');
			
			if centimetros = 3448 then
			espera <= '0';
			end if;
			
		else 
			cuenta <= cuenta+1;
		end if;
			eco_pasado <= eco_sinc;
			eco_sinc <= eco_nsinc;
			eco_nsinc <= sensor_eco;
		end if;
		
		--not(digitounidad) => not(digitounidad1);
	
	end process;
	

	
	--Display Unidades
		Unidades: process(digitounidad)
		begin
			case digitounidad is
				when "0000" => displayunidades <= "0000001"; -- abcdefg
				when "0001" => displayunidades <= "1001111";
				when "0010" => displayunidades <= "0010010";
				when "0011" => displayunidades <= "0000110";
				when "0100" => displayunidades <= "1001100";
		   	when "0101" => displayunidades <= "0100100";
				when "0110" => displayunidades <= "0100000";
				when "0111" => displayunidades <= "0001111";
				when "1000" => displayunidades <= "0000000";
				when "1001" => displayunidades <= "0000100";
				when others => displayunidades <= "1111111";
			end case;
		end process;
		
		
--			--Display Decenas
--		Decenas: process(digitodecena)
--		begin
--			case digitounidad is
--				when "0000" => displaydecenas <= "1000000";
--				when "0001" => displaydecenas <= "1111001";
--				when "0010" => displaydecenas <= "0011001";
--				when "0100" => displaydecenas <= "0010010";
--				when "0101" => displaydecenas <= "0000010";
--				when "0110" => displaydecenas <= "1111000";
--				when "1000" => displaydecenas <= "0000000";
--				when "1001" => displaydecenas <= "0011000";
--				when others => displaydecenas <= "1111111";
--			end case;
--		end process;
		
end Behavioral;
