library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity muxPro is
    Port ( prog : in STD_LOGIC_VECTOR (11 downto 0);
           clear : in STD_LOGIC;
           cpu : in STD_LOGIC_VECTOR (11 downto 0);
           romout : out STD_LOGIC_VECTOR (11 downto 0);
end muxPro;

architecture Behavioral of muxPro is

begin


end Behavioral;
