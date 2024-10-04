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
           rom_dataout : in STD_LOGIC_VECTOR (35 downto 0));
end CPU;

architecture Behavioral of CPU is

signal alu_result: std_logic_vector(15 downto 0);  -- Señales del resultado.
signal a: std_logic_vector(15 downto 0);  -- Señales de a.
signal b: std_logic_vector(15 downto 0);  -- Señales de b.
signal n: STD_LOGIC;  -- Señal de n.
signal z: STD_LOGIC;  -- Señal de z.
signal c: STD_LOGIC;  -- Señal de c.
-- result(0) = loadPC
-- result(3 downto 1) = selALU
-- result(5 down to 4) = selB
-- result(7 downto 6) = selA
-- result(8) = enableB
-- result(9) = enableA
-- result(10) = selDIn
-- result(11) = decSP
-- result(12) = incSP
-- result(14 downto 13) = SelAdd
-- result(15) = selPC
signal cu_result: std_logic_vector(15 downto 0); --señales del CU menos w
signal reg_A: std_logic_vector(15 downto 0);  -- Señales del regA.
signal reg_B: std_logic_vector(15 downto 0);  -- Señales del regB.
signal status_reg: std_logic_vector(2 downto 0);  -- Señales del status.
signal pc_out : STD_LOGIC_VECTOR (11 downto 0);
signal datain : STD_LOGIC_VECTOR (15 downto 0);
signal pc_in: STD_LOGIC_VECTOR (11 downto 0);
signal sp_out: STD_LOGIC_VECTOR (11 downto 0); 

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
           result : out STD_LOGIC_VECTOR (16 downto 0));
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

component Adder is
    Port ( a : in STD_LOGIC_VECTOR (11 downto 0);
           b : in STD_LOGIC_VECTOR (11 downto 0);
           s : out STD_LOGIC_VECTOR (15 downto 0)
           );
end component;

component MuxDataIn is
    Port ( add : in STD_LOGIC_VECTOR (15 downto 0);
           alu : in STD_LOGIC_VECTOR (15 downto 0);
           data : out STD_LOGIC_VECTOR (15 downto 0);
           selDin : in STD_LOGIC);
end component;

component MuxPC is
    Port ( ram : in STD_LOGIC_VECTOR (11 downto 0);
           lit : in STD_LOGIC_VECTOR (11 downto 0);
           data_out : out STD_LOGIC_VECTOR (11 downto 0);
           selPC : in STD_LOGIC);
end component;

component MuxS is
    Port ( sp : in STD_LOGIC_VECTOR (11 downto 0);
           lit : in STD_LOGIC_VECTOR (11 downto 0);
           b : in STD_LOGIC_VECTOR (11 downto 0);
           dir : out STD_LOGIC_VECTOR (11 downto 0);
           selAdd : in STD_LOGIC_VECTOR (1 downto 0));
end component;

component SP is
    Port ( sp_out : out STD_LOGIC_VECTOR (11 downto 0);
           incsp : in STD_LOGIC;
           decsp : in STD_LOGIC;
           clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic);                        -- Señal de reset.
end component;

begin

rom_address <= pc_out; 

inst_ALU: ALU port map(
           a => a, 
           b => b,
           sop => cu_result(3 downto 1),
           c => c,
           z => z,
           n => n,
           result => alu_result
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
       

-- result(0) = loadPC
-- result(3 downto 1) = selALU
-- result(5 down to 4) = selB
-- result(7 downto 6) = selA
-- result(8) = enableB
-- result(9) = enableA
-- result(10) = selDIn
-- result(11) = decSP
-- result(12) = incSP
-- result(14 downto 13) = SelAdd
-- result(15) = selPC
inst_CU: CU port map ( 
           datain => rom_dataout(35 downto 16), --los opcodes estan a la izquierda de los bits recibidios por rom
           result(16 downto 2) => cu_result(15 downto 1),
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
           datain => pc_in,
           load => cu_result(0), --loadPC
           clear => clear,
           clock => clock,
           up   => '1',   -- es un sumador
           down => '0',                  
           dataout => pc_out
    );
inst_RegA: RegA port map ( 
           clock  => clock,
           clear  => '0',
           load   => cu_result(9), --enableA
           up     => '0', --no es sumador
           down   => '0', --no es restador
           datain  => alu_result,
           dataout => reg_A
    );

inst_RegB: RegB port map ( 
           clock  => clock,
           clear  => '0',
           load   => cu_result(8), --enableB
           up     => '0', --no es sumador 
           down   => '0', --no es restador
           datain  => alu_result,
           dataout => reg_B
    );

inst_Adder: Adder port map(
           a => "000000000001",
           b => pc_out,
           s => datain
    );

inst_MuxDataIn: MuxDataIn port map(
           add => datain,
           alu => alu_result,
           data => ram_datain,
           selDin => cu_result(10)
    );

inst_MuxPC: MuxPC port map(
           ram => ram_dataout(11 downto 0),
           lit => rom_dataout (11 downto 0), --las direcciones están a la derecha de los bits recibidios por rom
           data_out => pc_in,
           selPC => cu_result(15)
    );

inst_MuxS: MuxS port map(
           sp => sp_out,
           lit => rom_dataout (11 downto 0), --las direcciones están a la derecha de los bits recibidios por rom
           b => reg_B(11 downto 0),
           dir => ram_address,
           selAdd => cu_result(14 downto 13)
    );

inst_SP: SP port map(
           sp_out => sp_out,
           incsp => cu_result(12),
           decsp => cu_result(11),
           clock => clock,
           clear => clear
    );

end Behavioral;

