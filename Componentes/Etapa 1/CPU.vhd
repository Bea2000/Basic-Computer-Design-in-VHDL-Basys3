library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity CPU is
    Port (
           clock : in STD_LOGIC;
           clear : in STD_LOGIC;
           ram_address : out STD_LOGIC_VECTOR (11 downto 0);
           ram_datain : out STD_LOGIC_VECTOR (15 downto 0);
           ram_dataout : in STD_LOGIC_VECTOR (15 downto 0);
           ram_write : out STD_LOGIC;
           rom_address : out STD_LOGIC_VECTOR (11 downto 0);
           rom_dataout : in STD_LOGIC_VECTOR (35 downto 0);
           dis : out STD_LOGIC_VECTOR (15 downto 0));
end CPU;

architecture Behavioral of CPU is

signal result: std_logic_vector(15 downto 0);  -- Señales del resultado.
signal a: std_logic_vector(15 downto 0);  -- Señales de a.
signal b: std_logic_vector(15 downto 0);  -- Señales de b.
signal n: STD_LOGIC;  -- Señal de n.
signal z: STD_LOGIC;  -- Señal de z.
signal c: STD_LOGIC;  -- Señal de c.
-- cu_result (9) = enableA
-- cu_result (8) = enableB
-- cu_result (7 downto 6) = selA
-- cu_result (5 downto 4) = selB
-- cu_result (3 downto 1) = selALU
-- cu_result (0) = loadPC
signal cu_result: std_logic_vector(9 downto 0); --señales del CU menos w
signal reg_A: std_logic_vector(15 downto 0);  -- Señales del regA.
signal reg_B: std_logic_vector(15 downto 0);  -- Señales del regB.
signal status_reg: std_logic_vector(2 downto 0);  -- Señales del status.

component ALU is
    Port ( a        : in  std_logic_vector (15 downto 0);   -- Primer operando.
           b        : in  std_logic_vector (15 downto 0);   -- Segundo operando.
           sop      : in  std_logic_vector (2 downto 0);   -- Selector de la operación.
           c        : out std_logic;                       -- Señal de 'carry'.
           z        : out std_logic;                       -- Señal de 'zero'.
           n        : out std_logic;                       -- Señal de 'nagative'. (durante una resta a era menor que b)
           result   : out std_logic_vector (15 downto 0));  -- Resultado de la operación.
end component;

component Status is
    Port ( c : in STD_LOGIC;
           z : in STD_LOGIC;
           n : in STD_LOGIC;
           result : out STD_LOGIC_VECTOR (2 downto 0);
           clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic;                        -- Señal de reset.
           load     : in  std_logic);                        -- Señal de carga.
end component;

component CU is
    Port ( datain : in STD_LOGIC_VECTOR (19 downto 0);
           status: in STD_LOGIC_VECTOR (2 downto 0);
           result : out STD_LOGIC_VECTOR (10 downto 0));
end component;

component MuxA is
    Port (
           reg : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           a : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component MuxB is
    Port ( reg : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           rom : in STD_LOGIC_VECTOR (15 downto 0);
           ram : in STD_LOGIC_VECTOR (15 downto 0);
           b : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component PC is
    Port ( datain : in STD_LOGIC_VECTOR (11 downto 0);
           load : in STD_LOGIC;
           clear : in STD_LOGIC;
           clock : in STD_LOGIC;
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           dataout : out STD_LOGIC_VECTOR (11 downto 0));
end component;

component RegA is
    Port ( clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic;                        -- Señal de reset.
           load     : in  std_logic;                        -- Señal de carga.
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           datain   : in  std_logic_vector (15 downto 0);   -- Señales de entrada de datos.
           dataout  : out std_logic_vector (15 downto 0));  -- Señales de salida de datos.
end component;

component RegB is
    Port ( clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic;                        -- Señal de reset.
           load     : in  std_logic;                        -- Señal de carga.
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           datain   : in  std_logic_vector (15 downto 0);   -- Señales de entrada de datos.
           dataout  : out std_logic_vector (15 downto 0));  -- Señales de salida de datos.
end component;

begin

ram_address  <= rom_dataout(11 downto 0);
ram_datain  <= result;
dis <= reg_A (7 downto 0) & reg_B (7 downto 0);

inst_ALU: ALU port map(
           a => a, 
           b => b,
           sop => cu_result(3 downto 1),
           c => c,
           z => z,
           n => n,
           result => result
       );

inst_Status: Status port map (
           c => c,
           z => z,
           n => n,
           result => status_reg,
           clock => clock,
           clear => clear,
           load => '1' --siempre se carga (en flancos de subida)
       );
       

-- cu_result (9) = enableA
-- cu_result (8) = enableB
-- cu_result (7 downto 6) = selA
-- cu_result (5 downto 4) = selB
-- cu_result (3 downto 1) = selALU
-- cu_result (0) = loadPC
inst_CU: CU port map ( 
           datain => rom_dataout(35 downto 16), --los opcodes estan a la izquierda de los bits recibidios por rom
           result(10 downto 2) => cu_result(9 downto 1),
           result (1) => ram_write, -- w
           result (0) => cu_result(0), --loadPC
           status => status_reg
      );

int_MuxA: MuxA port map (
           reg => reg_A,
           sel => cu_result(7 downto 6), --selA
           a => a
    );
    
int_MuxB: MuxB port map (
           reg => reg_B,
           sel => cu_result(5 downto 4), --selB
           rom => rom_dataout (15 downto 0), --los literales estan a la derecha de los bits recibidios por rom
           ram => ram_dataout,
           b => b
    );

inst_PC: PC port map ( 
           datain => rom_dataout (11 downto 0), --las direcciones están a la derecha de los bits recibidios por rom
           load => cu_result(0), --loadPC
           clear => clear,
           clock => clock,
           up   => '1',   -- es un sumador
           down => '0',                  
           dataout => rom_address
    );

inst_RegA: RegA port map ( 
           clock  => clock,
           clear  => '0',
           load   => cu_result(9), --enableA
           up     => '0', --no es sumador
           down   => '0', --no es restador
           datain  => result,
           dataout => reg_A
    );

inst_RegB: RegB port map ( 
           clock  => clock,
           clear  => '0',
           load   => cu_result(8), --enableB
           up     => '0', --no es sumador 
           down   => '0', --no es restador
           datain  => result,
           dataout => reg_B
    );

end Behavioral;

