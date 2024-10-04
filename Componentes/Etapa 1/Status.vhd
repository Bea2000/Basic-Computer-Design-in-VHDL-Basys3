library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Status is
    Port ( c : in STD_LOGIC;
           z : in STD_LOGIC;
           n : in STD_LOGIC;
           result : out STD_LOGIC_VECTOR (2 downto 0);      -- env�a z,n,c a CU
           clock    : in  std_logic;                        -- Se�al del clock (reducido).
           clear    : in  std_logic;                        -- Se�al de reset.
           load     : in  std_logic);                        -- Se�al de carga.
end Status;

architecture Behavioral of Status is

signal z_reg : std_logic := '0'; -- Se�ales del registro. Parten en 0.
signal c_reg : std_logic := '0'; -- Se�ales del registro. Parten en 0.
signal n_reg : std_logic := '0'; -- Se�ales del registro. Parten en 0.

begin

reg_prosses : process (clock, clear)        -- Proceso sensible a clock y clear.
        begin
          if (clear = '1') then    -- Si clear = 1
            z_reg <= '0';         -- Carga 0 en z
            c_reg <= '0';         -- Carga 0 en c
            n_reg <= '0';         -- Carga 0 en n
          elsif (rising_edge(clock)) then   -- Si flanco de subida de clock.
            if (load = '1') then            -- Siempre ser� 1
                z_reg <= z;              -- Carga z
                n_reg <= n;              -- Carga n
                c_reg <= c;              -- Carga c
            end if;
          end if;
        end process;
        
result <= z_reg & n_reg & c_reg; -- Resultado quedar�a definido como result(2) = z, result(1) = n & result(0) = c

end Behavioral;
