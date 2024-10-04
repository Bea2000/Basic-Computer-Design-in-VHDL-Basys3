library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity SP is
    Port ( sp_out : out STD_LOGIC_VECTOR (11 downto 0);
           incsp : in STD_LOGIC;
           decsp : in STD_LOGIC;
           clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic);                        -- Señal de reset.                        -- Señal de carga.
end SP;

architecture Behavioral of SP is

signal reg : std_logic_vector(11 downto 0) := "111111111111"; -- Señales del registro. Parten en 0.

begin

reg_prosses : process (clock, clear)        -- Proceso sensible a clock y clear.
        begin
          if (clear = '1') then             -- Si clear = 1
            reg <= "111111111111";         -- Carga última dirección en SP
          elsif (rising_edge(clock)) then   -- Si flanco de subida de clock.
            if (incsp = '1') then           -- Si clear = 0,load = 0 y up = 1.
                reg <= reg + 1;             -- Incrementa el registro en 1.
            elsif (decsp = '1') then         -- Si clear = 0,load = 0, up = 0 y down = 1. 
                reg <= reg - 1;             -- Decrementa el registro en 1.          
            end if;
          end if;
        end process;
        
sp_out <= reg;                             -- Los datos del registro salen sin importar el estado de clock.


end Behavioral;
