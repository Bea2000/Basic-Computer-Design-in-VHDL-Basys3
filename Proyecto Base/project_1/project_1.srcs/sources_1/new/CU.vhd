library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CU is
    Port ( datain : in STD_LOGIC_VECTOR (19 downto 0); -- opcode recibido
           status: in STD_LOGIC_VECTOR (2 downto 0);
           result : out STD_LOGIC_VECTOR (16 downto 0)); -- señales de salida
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
-- result(11) = selDIn
-- result(12) = decSP
-- result(13) = incSP
-- result(15 downto 14) = SelAdd
-- result(16) = selPC

signal cu_result   : std_logic_vector(15 downto 0);
signal loadPC   : STD_LOGIC;
signal jgt: STD_LOGIC;
signal jle: STD_LOGIC;

begin

with datain(6 downto 0) select
    cu_result <=  "0000001000100000" when "0000001", --MOV A,B
                  "0000000110000000" when "0000010", --MOV B,A
                  "0000001000010000" when "0000100", --MOV A,Lit
                  "0000000100010000" when "0001000", --MOV B,Lit
                  "0000001000110000" when "0010000", --MOV A,(Dir)
                  "0000000100110000" when "0100000", --MOV B,(Dir)
                  "0000000010000001" when "1000000", --MOV (Dir),A
                  "0000000000100001" when "0000011", --MOV (Dir),B
                  "0010001000110000" when "1110010", --MOV A,(B)
                  "0010000100110000" when "1110100", --MOV B,(B)
                  "0010000010000001" when "1110110", --MOV (B),A
                  "0010000000010001" when "1100110", --MOV (B),Lit
                  "0000001010100000" when "0000101", --ADD A,B
                  "0000000110100000" when "0001001", --ADD B,A
                  "0000001010010000" when "0010001", --ADD A,Lit or INC A (pero Lit=1)
                  "0000000110010000" when "0100001", --ADD B,Lit
                  "0000001010110000" when "1000001", --ADD A,(Dir)
                  "0000000110110000" when "0000111", --ADD B,(Dir)
                  "0010001010110000" when "1111010", --ADD A,(B)
                  "0010000110110000" when "1100100", --ADD B,(B)
                  "0000000010100001" when "0001011", --ADD (Dir)
                  "0000001010100010" when "0010011", --SUB A,B
                  "0000000110100010" when "0100011", --SUB B,A
                  "0000001010010010" when "1000011", --SUB A,Lit or DEC A (pero Lit=1)
                  "0000000110010010" when "0001111", --SUB B,Lit
                  "0000001010110010" when "0010111", --SUB A,(Dir)
                  "0000000110110010" when "0100111", --SUB B,(Dir)
                  "0010001010110010" when "1101000", --SUB A,(B)
                  "0010000110110010" when "1100010", --SUB B,(B)
                  "0000000010100011" when "1000111", --SUB (Dir)
                  "0000001010100100" when "0011111", --AND A,B
                  "0000000110100100" when "0101111", --AND B,A
                  "0000001010010100" when "1001111", --AND A,Lit
                  "0000000110010100" when "0111111", --AND B,Lit
                  "0000001010110100" when "1011111", --AND A,(Dir)
                  "0000000110110100" when "1111111", --AND B,(Dir)
                  "0010001010110100" when "1101010", --AND A,(B)
                  "0010000110110100" when "1100000", --AND B,(B)
                  "0000000010100101" when "0000110", --AND (Dir)
                  "0000001010100110" when "0001010", --OR A,B
                  "0000000110100110" when "0010010", --OR B,A
                  "0000001010010110" when "0100010", --OR A,Lit
                  "0000000110010110" when "1000010", --OR B,Lit
                  "0000001010110110" when "0001110", --OR A,(Dir)
                  "0000000110110110" when "0010110", --OR B,(Dir)
                  "0010001010110110" when "1101100", --OR A,(B)
                  "0010000110110110" when "1011101", --OR B,(B)
                  "0000000010100111" when "0100110", --OR (Dir)
                  "0000001010101000" when "1000110", --XOR A,B
                  "0000000110101000" when "0011110", --XOR B,A
                  "0000001010011000" when "0101110", --XOR A,Lit
                  "0000000110011000" when "1001110", --XOR B,Lit
                  "0000001010111000" when "0111110", --XOR A,(Dir)
                  "0000000110111000" when "1011110", --XOR B,(Dir)
                  "0010001010111000" when "1101110", --XOR A,(B)
                  "0010000110111000" when "1011011", --XOR B,(B)
                  "0000000010101001" when "1111110", --XOR (Dir)
                  "0000001010001010" when "0001100", --NOT A
                  "0000000110001010" when "0010100", --NOT B,A
                  "0000000010001011" when "0100100", --NOT (Dir),A
                  "0010000010001011" when "1011001", --NOT (B),A
                  "0000001010001110" when "1000100", --SHL A
                  "0000000110001110" when "0011100", --SHL B,A
                  "0000000010001111" when "0101100", --SHL (Dir),A
                  "0010000010001111" when "1010111", --SHL (B),A
                  "0000001010001100" when "1001100", --SHR A
                  "0000000110001100" when "0111100", --SHR B,A
                  "0000000010001101" when "1011100", --SHR (Dir),A
                  "0010000010001101" when "1010101", --SHR (B),A
                  "0000000101100000" when "0011000", --INC B
                  "0000000001110001" when "0101000", --INC (Dir)
                  "0010000001110001" when "1010011", --INC (B)
                  "0000000010100010" when "0111000", --CMP A,B
                  "0000000010010010" when "1011000", --CMP A,Lit
                  "0000000010110010" when "1111000", --CMP A,(Dir)
                  "0010000010110010" when "1010001", --CMP A,(B)
                  "0100110000000001" when "1110011", --CALL 
                  "0001000000000000" when "1110101", --RET clock 1
                  "1100000000000000" when "1100101", --RET clock 2
                  "0100100010000001" when "1110111", --PUSH A
                  "0100100000100001" when "1111001", --PUSH B
                  "0001000000000000" when "1111011", --POP 1
                  "0100001000110000" when "1100001", --POP A
                  "0100000100110000" when "1100011", --POP B
                  "0000000000000000" when others; --NOP
                  
                  
result (16 downto 1) <= cu_result;
jgt <= not status(2) and not status(1);
jle <= status(2) or status(1);

-- status(0) = c
-- status(1) = n
-- status(2) = z
with datain(6 downto 0) select
    loadPC <= status(2)     when "1010000",    --JEQ z=1
             '1'            when "0110000",    --JMP 
             not status(2)  when "1110000",    --JNE z=0
             jgt            when "1100111",    --JGT n=0 y z=0
             status(1)      when "1101001",    --JLT n=1
             not status(1)  when "1101011",    --JGE n=0
             jle            when "1101101",    --JLE z=1 o n=1
             status(0)      when "1101111",    --JCR c=1
             '1'            when "1110011",    --CALL
             '1'            when "1100101",    --RET clock 2
             '0'            when others;

result (0) <= loadPC;  --loadPC


end Behavioral;
