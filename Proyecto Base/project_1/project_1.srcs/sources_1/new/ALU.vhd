-- mucho ojo nuestro computador (o sea la placa) no soporta complemento de 2 !!!! solo unsigned numbers 0, 1, 2, 3, 4... etc.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
    Port ( a        : in  std_logic_vector (15 downto 0);   -- Primer operando.
           b        : in  std_logic_vector (15 downto 0);   -- Segundo operando.
           sop      : in  std_logic_vector (2 downto 0);   -- Selector de la operación.
           c        : out std_logic;                       -- Señal de 'carry'.
           z        : out std_logic;                       -- Señal de 'zero'.
           n        : out std_logic;                       -- Señal de 'nagative'. (durante una resta a era menor que b)
           result   : out std_logic_vector (15 downto 0));  -- Resultado de la operación.
end ALU;

architecture Behavioral of ALU is



-- declaramos que usaremos el adder8
component Adder16 is
    Port ( a  : in  std_logic_vector (15 downto 0);
           b  : in  std_logic_vector (15 downto 0);
           ci : in  std_logic;
           s  : out std_logic_vector (15 downto 0);
           co : out std_logic);
end component;



-- señales
signal alu_result   : std_logic_vector(15 downto 0);

signal adder_result   : std_logic_vector(15 downto 0);
signal ci : std_logic;
signal co : std_logic;
signal adder_b : std_logic_vector(15 downto 0);


signal and_result : std_logic_vector(15 downto 0);
signal or_result : std_logic_vector(15 downto 0);
signal xor_result : std_logic_vector(15 downto 0);
signal not_result : std_logic_vector(15 downto 0);
signal shr_result : std_logic_vector(15 downto 0);
signal shl_result : std_logic_vector(15 downto 0);



begin

-- Sumador/Restador

-- queremos que el ci sea uno cuando el sop sea 001
ci <= sop(0) and not sop(1) and not sop(2);


and_result <= a and b;
or_result <= a or b;
xor_result <= a xor b;
not_result <= not a;





-- muxer adder (creo):
with ci select
adder_b <= b when '0',
not b when '1';

inst_Adder16: Adder16 port map(
        a      => a,
        b      => adder_b,
        ci     => ci,
        s      => adder_result,
        co     => co
    );
                



-- Resultado de la Operación
               
-- pude haber puesto directamente not a!!

with sop select
    alu_result <= adder_result     when "000",
                  adder_result     when "001",
                  and_result                 when "010",
                  or_result                  when "011",
                  xor_result                when "100",
                  not_result                when "101",
                  '0'& a(15 downto 1)        when "110",
                  a(14 downto 0) & '0'       when "111";
                  
result  <= alu_result;



-- Flags c z n

with sop select
    c <=          co     when "000",
                  co     when "001",
                  '0'     when "010",
                  '0'     when "011",
                  '0'     when "100",
                  '0'     when "101",
                  a(0)     when "110",
                  a(15)     when "111";
                  
                  
                  
-- z es uno cuando el resultado es 0
with alu_result select
    z <= '1' when "0000000000000000",
         '0' when others;



with sop select
    n <=          '0'        when "000",
                  not co     when "001",
                  '0'         when "010",
                  '0'         when "011",
                  '0'         when "100",
                  '0'         when "101",
                  '0'         when "110",
                  '0'         when "111";

    
end Behavioral;

