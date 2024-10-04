library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MuxPC is
    Port ( ram : in STD_LOGIC_VECTOR (11 downto 0);
           lit : in STD_LOGIC_VECTOR (11 downto 0);
           data_out : out STD_LOGIC_VECTOR (11 downto 0);
           selPC : in STD_LOGIC);
end MuxPC;

architecture Behavioral of MuxPC is

signal mux_result   : std_logic_vector(11 downto 0);

begin



with selPC select
    mux_result <= lit     when '0',
                  ram     when '1';
                  
data_out  <= mux_result;


end Behavioral;
