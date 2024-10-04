library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MuxDataIn is
    Port ( add : in STD_LOGIC_VECTOR (15 downto 0);
           alu : in STD_LOGIC_VECTOR (15 downto 0);
           data : out STD_LOGIC_VECTOR (15 downto 0);
           selDin : in STD_LOGIC);
end MuxDataIn;

architecture Behavioral of MuxDataIn is

signal mux_result   : std_logic_vector(15 downto 0);

begin



with selDin select
    mux_result <= add     when '1',
                  alu     when '0';
                  
data  <= mux_result;


end Behavioral;
