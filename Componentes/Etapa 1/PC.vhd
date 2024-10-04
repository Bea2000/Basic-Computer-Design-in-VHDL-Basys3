library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity PC is
    Port ( datain : in STD_LOGIC_VECTOR (11 downto 0);
           load : in STD_LOGIC;
           clear : in STD_LOGIC;
           clock : in STD_LOGIC;
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           dataout : out STD_LOGIC_VECTOR (11 downto 0));
end PC;

architecture Behavioral of PC is

signal pc : std_logic_vector(11 downto 0) := (others => '0'); -- Señales del registro. Parten en 0.

begin

reg_prosses : process (clock, clear)        -- Proceso sensible a clock y clear.
        begin
          if (clear = '1') then             -- Si clear = 1
            pc <= (others => '0');         -- Carga 0 en el registro.
          elsif (rising_edge(clock)) then   -- Si flanco de subida de clock.
            if (load = '1') then            -- Si clear = 0, load = 1.
                pc <= datain;              -- Carga la entrada de datos en el registro.
            elsif (up = '1') then           -- Si clear = 0,load = 0 y up = 1.
                pc <= pc + 1;             -- Incrementa el registro en 1. PC siempre será up
            elsif (down = '1') then         -- Si clear = 0,load = 0, up = 0 y down = 1. 
                pc <= pc - 1;             -- down siempre es 0 por lo que no entra acá       
            end if;
          end if;
        end process;
        
dataout <= pc;   


end Behavioral;
