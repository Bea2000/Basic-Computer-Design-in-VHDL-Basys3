
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MuxB is
    Port ( reg : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           rom : in STD_LOGIC_VECTOR (15 downto 0);
           ram : in STD_LOGIC_VECTOR (15 downto 0);
           b : out STD_LOGIC_VECTOR (15 downto 0));
end MuxB;

architecture Behavioral of MuxB is

signal mux_result   : std_logic_vector(15 downto 0);

begin



with sel select
    mux_result <= "0000000000000000" when "00", -- B=0
                  rom                when "01", -- recibe literal de la ROM
                  reg                when "10", -- recibe valor B guardado en registro
                  ram                when "11"; -- recibe literal guardado en RAM
                  
b  <= mux_result;

end Behavioral;
