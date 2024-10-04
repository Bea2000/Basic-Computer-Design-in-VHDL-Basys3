library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MuxA is
    Port (
           reg : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           a : out STD_LOGIC_VECTOR (15 downto 0));
end MuxA;

architecture Behavioral of MuxA is

signal mux_result   : std_logic_vector(15 downto 0);

begin



with sel select
    mux_result <= "0000000000000000"     when "00", -- A=0
                  "0000000000000001"     when "01", -- A=1
                  reg                when "10",     -- recibe valor A del Registro
                  UNAFFECTED WHEN "11";             -- Como solo hay 3 entradas, este caso no es considerado
                  
a  <= mux_result;

end Behavioral;
