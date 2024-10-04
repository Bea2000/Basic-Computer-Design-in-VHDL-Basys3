library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MuxS is
    Port ( sp : in STD_LOGIC_VECTOR (11 downto 0);
           lit : in STD_LOGIC_VECTOR (11 downto 0);
           b : in STD_LOGIC_VECTOR (11 downto 0);
           dir : out STD_LOGIC_VECTOR (11 downto 0);
           selAdd : in STD_LOGIC_VECTOR (1 downto 0));
end MuxS;

architecture Behavioral of MuxS is

signal mux_result   : std_logic_vector(11 downto 0);

begin

with selAdd select
    mux_result <= lit    when "00",
                  b      when "01",
                  sp     when "10", 
                  UNAFFECTED WHEN "11"; -- Como solo hay 3 entradas, este caso no es considerado
                  
dir  <= mux_result;


end Behavioral;
