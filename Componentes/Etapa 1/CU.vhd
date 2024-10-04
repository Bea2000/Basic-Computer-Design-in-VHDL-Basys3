library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CU is
    Port ( datain : in STD_LOGIC_VECTOR (19 downto 0); -- opcode recibido
           status: in STD_LOGIC_VECTOR (2 downto 0);
           result : out STD_LOGIC_VECTOR (10 downto 0)); -- señales de salida
end CU;

architecture Behavioral of CU is

-- Estructura de result
-- result(0) = loadPC
-- result(1) = w
-- result(4 downto 2) = selALU
-- result(6 down to 5) = selB
-- result(8 downto 7) = selA
-- result(9) = enableB
-- result(10) = enableA

signal cu_result   : std_logic_vector(9 downto 0);
signal loadPC   : STD_LOGIC;

begin

with datain(6 downto 0) select
    cu_result <=  "1000100000" when "0000001", --MOV A,B
                  "0110000000" when "0000010", --MOV B,A
                  "1000010000" when "0000100", --MOV A,Lit
                  "0100010000" when "0001000", --MOV B,Lit
                  "1000110000" when "0010000", --MOV A,(Dir)
                  "0100110000" when "0100000", --MOV B,(Dir)
                  "0010000001" when "1000000", --MOV (Dir),A
                  "0000100001" when "0000011", --MOV (Dir),B
                  "1010100000" when "0000101", --ADD A,B
                  "0110100000" when "0001001", --ADD B,A
                  "1010010000" when "0010001", --ADD A,Lit
                  "0110010000" when "0100001", --ADD B,Lit
                  "1010110000" when "1000001", --ADD A,(Dir)
                  "0110110000" when "0000111", --ADD B,(Dir)
                  "0010100001" when "0001011", --ADD (Dir)
                  "1010100010" when "0010011", --SUB A,B
                  "0110100010" when "0100011", --SUB B,A
                  "1010010010" when "1000011", --SUB A,Lit
                  "0110010010" when "0001111", --SUB B,Lit
                  "1010110010" when "0010111", --SUB A,(Dir)
                  "0110110010" when "0100111", --SUB B,(Dir)
                  "0010100011" when "1000111", --SUB (Dir)
                  "1010100100" when "0011111", --AND A,B
                  "0110100100" when "0101111", --AND B,A
                  "1010010100" when "1001111", --AND A,Lit 
                  "0110010100" when "0111111", --AND B,Lit
                  "1010110100" when "1011111", --AND A,(Dir)
                  "0110110100" when "1111111", --AND B,(Dir)
                  "0010100101" when "0000110", --AND (Dir)
                  "1010100110" when "0001010", --OR A,B
                  "0110100110" when "0010010", --OR B,A
                  "1010010110" when "0100010", --OR A,Lit
                  "0110010110" when "1000010", --OR B,Lit
                  "1010110110" when "0001110", --OR A,(Dir)
                  "0110110110" when "0010110", --OR B,(Dir)
                  "0010100111" when "0100110", --OR (Dir)
                  "1010101000" when "1000110", --XOR A,B
                  "0110101000" when "0011110", --XOR B,A
                  "1010011000" when "0101110", --XOR A,Lit
                  "0110011000" when "1001110", --XOR B,Lit
                  "1010111000" when "0111110", --XOR A,(Dir)
                  "0110111000" when "1011110", --XOR B,(Dir)
                  "0010101001" when "1111110", --XOR (Dir)
                  "1010001010" when "0001100", --NOT A
                  "0110001010" when "0010100", --NOT B,A
                  "0010001011" when "0100100", --NOT (Dir),A
                  "1010001110" when "1000100", --SHL A
                  "0110001110" when "0011100", --SHL B,A
                  "0010001111" when "0101100", --SHL (Dir),A
                  "1010001100" when "1001100", --SHR A
                  "0110001100" when "0111100", --SHR B,A
                  "0010001101" when "1011100", --SHR (Dir),A
                  "0101100000" when "0011000", --INC B
                  "0001110001" when "0101000", --INC (Dir)
                  "0010100010" when "0111000", --CMP A,B
                  "0010010010" when "1011000", --CMP A,Lit
                  "0010110010" when "1111000", --CMP,A,(Dir)
                  "0000000000" when "1010000", --JEQ
                  "0000000000" when "1110000", --JNE
                  "0000000000" when "0110000", --JMP
                  "0000000000" when others;    --NOP
                  
result (10 downto 1) <= cu_result;

with datain(6 downto 0) select
    loadPC <= status(2)     when "1010000",    --JEQ
             '1'            when "0110000",    --JMP
             not status(2)  when "1110000",    --JNE
             '0'            when others;

result (0) <= loadPC;  --loadPC


end Behavioral;
