library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Basys3 is
    Port (
        sw          : in   std_logic_vector (15 downto 0); -- No Tocar - Señales de entrada de los interruptores -- Arriba   = '1'   -- Los 16 swiches.
        btn         : in   std_logic_vector (4 downto 0);  -- No Tocar - Señales de entrada de los botones       -- Apretado = '1'   -- 0 central, 1 arriba, 2 izquierda, 3 derecha y 4 abajo.
        led         : out  std_logic_vector (15 downto 0); -- No Tocar - Señales de salida  a  los leds          -- Prendido = '1'   -- Los 16 leds.
        clk         : in   std_logic;                      -- No Tocar - Señal de entrada del clock              -- 100Mhz.
        seg         : out  std_logic_vector (7 downto 0);  -- No Tocar - Salida de las señales de segmentos.
        an          : out  std_logic_vector (3 downto 0);  -- No Tocar - Salida del selector de diplay.
        tx          : out  std_logic;                      -- No Tocar - Señal de salida para UART Tx.
        rx          : in   std_logic                       -- No Tocar - Señal de entrada para UART Rx.
          );
end Basys3;

architecture Behavioral of Basys3 is

-- Inicio de la declaración de los componentes.

component Clock_Divider -- No Tocar
    Port (
        clk         : in    std_logic;
        speed       : in    std_logic_vector (1 downto 0);
        clock       : out   std_logic
          );
    end component;
    
component Display_Controller -- No Tocar
    Port (  
        dis_a       : in    std_logic_vector (3 downto 0);
        dis_b       : in    std_logic_vector (3 downto 0);
        dis_c       : in    std_logic_vector (3 downto 0);
        dis_d       : in    std_logic_vector (3 downto 0);
        clk         : in    std_logic;
        seg         : out   std_logic_vector (7 downto 0);
        an          : out   std_logic_vector (3 downto 0)
          );
    end component;
    
component Debouncer -- No Tocar
    Port (
        clk         : in    std_logic;
        signal_in      : in    std_logic;
        signal_out     : out   std_logic
          );
    end component;
            

component ROM -- No Tocar
    Port (
        clk         : in    std_logic;
        write       : in    std_logic;
        disable     : in    std_logic;
        address     : in    std_logic_vector (11 downto 0);
        dataout     : out   std_logic_vector (35 downto 0);
        datain      : in    std_logic_vector(35 downto 0)
          );
    end component;

component RAM -- No Tocar
    Port (  
        clock       : in    std_logic;
        write       : in    std_logic;
        address     : in    std_logic_vector (11 downto 0);
        datain      : in    std_logic_vector (15 downto 0);
        dataout     : out   std_logic_vector (15 downto 0)
          );
    end component;
    
component Programmer -- No Tocar
    Port (
        rx          : in    std_logic;
        tx          : out   std_logic;
        clk         : in    std_logic;
        clock       : in    std_logic;
        bussy       : out   std_logic;
        ready       : out   std_logic;
        address     : out   std_logic_vector(11 downto 0);
        dataout     : out   std_logic_vector(35 downto 0)
        );
    end component;
    
component CPU is
    Port (
           clock : in STD_LOGIC;
           clear : in STD_LOGIC;
           ram_address : out STD_LOGIC_VECTOR (11 downto 0);
           ram_datain : out STD_LOGIC_VECTOR (15 downto 0);
           ram_dataout : in STD_LOGIC_VECTOR (15 downto 0);
           ram_write : out STD_LOGIC;
           rom_address : out STD_LOGIC_VECTOR (11 downto 0);
           rom_dataout : in STD_LOGIC_VECTOR (35 downto 0));
    end component;
    
component Timer is
    Port ( clk : in STD_LOGIC;
           clear   : in STD_LOGIC;
           seconds : out STD_LOGIC_VECTOR (15 downto 0);
           mseconds: out STD_LOGIC_VECTOR (15 downto 0);
           useconds: out STD_LOGIC_VECTOR (15 downto 0));
           
end component;

component RegDis is
    Port ( clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic;                        -- Señal de reset.
           load     : in  std_logic;                        -- Señal de carga.
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           ram_datain   : in  std_logic_vector (15 downto 0);   -- Señales de entrada de datos.
           display  : out std_logic_vector (15 downto 0));  -- Señales de salida de datos.
end component;

component RegLED is
    Port ( clock    : in  std_logic;                        -- Señal del clock (reducido).
           clear    : in  std_logic;                        -- Señal de reset.
           load     : in  std_logic;                        -- Señal de carga.
           up       : in  std_logic;                        -- Señal de subida.
           down     : in  std_logic;                        -- Señal de bajada.
           ram_datain   : in  std_logic_vector (15 downto 0);   -- Señales de entrada de datos.
           led  : out std_logic_vector (15 downto 0));  -- Señales de salida de datos.
end component;
-- Fin de la declaración de los componentes.

-- Inicio de la declaración de señales.

signal clock            : std_logic;                     -- Señal del clock reducido.
            
signal dis_a            : std_logic_vector(3 downto 0);  -- Señales de salida al display A.    
signal dis_b            : std_logic_vector(3 downto 0);  -- Señales de salida al display B.     
signal dis_c            : std_logic_vector(3 downto 0);  -- Señales de salida al display C.    
signal dis_d            : std_logic_vector(3 downto 0);  -- Señales de salida al display D.

signal dis              : std_logic_vector(15 downto 0); -- Señales de salida totalidad de los displays.

signal d_btn            : std_logic_vector(4 downto 0);  -- Señales de botones con anti-rebote.

signal write_rom        : std_logic;                     -- Señal de escritura de la ROM.
signal pro_address      : std_logic_vector(11 downto 0); -- Señales del direccionamiento de programación de la ROM.
signal rom_datain       : std_logic_vector(35 downto 0); -- Señales de la palabra a programar en la ROM.

signal clear            : std_logic;                     -- Señal de limpieza de registros durante la programación.

signal cpu_rom_address  : std_logic_vector(11 downto 0); -- Señales del direccionamiento de lectura de la ROM.
signal rom_address      : std_logic_vector(11 downto 0); -- Señales del direccionamiento de la ROM.
signal rom_dataout      : std_logic_vector(35 downto 0); -- Señales de la palabra de salida de la ROM.

signal write_ram        : std_logic;                     -- Señal de escritura de la RAM.
signal ram_address      : std_logic_vector(11 downto 0); -- Señales del direccionamiento de la RAM.
signal ram_datain       : std_logic_vector(15 downto 0); -- Señales de la palabra de entrada de la RAM.
signal ram_dataout      : std_logic_vector(15 downto 0); -- Señales de la palabra de salida de la RAM.

signal muxin_s          : std_logic_vector(15 downto 0); -- Señal del timer a la muxIn
signal muxin_m          : std_logic_vector(15 downto 0); -- Señal del timer a la muxIn
signal muxin_u          : std_logic_vector(15 downto 0); -- Señal del timer a la muxIn
signal mux_in_out      : std_logic_vector(15 downto 0); -- Señales de la palabra de salida de la RAM.

signal demux_dis        : std_logic;
signal demux_led        : std_logic;

signal lcd              : std_logic_vector(10 downto 0);


-- Fin de la declaración de los señales.

begin

dis_a  <= dis(15 downto 12);
dis_b  <= dis(11 downto 8);
dis_c  <= dis(7 downto 4);
dis_d  <= dis(3 downto 0);
                    
-- Muxer del address de la ROM.          
with clear select
    rom_address <= cpu_rom_address when '0',
                   pro_address when '1';
                   
-- Mux IN
with ram_address select
    mux_in_out <= muxin_s when "000000000100",
                   muxin_m when "000000000101",
                   muxin_u when "000000000110",
                   "00000000000" & d_btn(4 downto 0) when "000000000011",
                   sw when "000000000001",
                   ram_dataout when others;

-- Demux OUT
-- Los registros reciben señal 1 dependiendo de lo elegido por la señal write_ram del demuxer

with ram_address select
    demux_dis <=  write_ram when "000000000010",
                 '0' when others;

with ram_address select
    demux_led <= write_ram when "000000000000",
                 '0' when others;
                   
-- Inicio de declaración de instancias.

-- Instancia de la CPU.        
inst_CPU: CPU port map(
    clock       => clock,
    clear       => clear,
    ram_address => ram_address,
    ram_datain  => ram_datain(15 downto 0),
    ram_dataout => mux_in_out,
    ram_write   => write_ram,
    rom_address => cpu_rom_address,
    rom_dataout => rom_dataout
    );

-- Instancia de la memoria RAM.
inst_ROM: ROM port map(
    clk         => clk,
    disable     => clear,
    write       => write_rom,
    address     => rom_address,
    dataout     => rom_dataout,
    datain      => rom_datain
    );

-- Instancia de la memoria ROM.
inst_RAM: RAM port map(
    clock       => clock,
    write       => write_ram,
    address     => ram_address,
    datain      => ram_datain,
    dataout     => ram_dataout
    );
    
 -- Intancia del divisor de la señal del clock.
inst_Clock_Divider: Clock_Divider port map(
    speed       => "00",                    -- Selector de velocidad: "00" full, "01" fast, "10" normal y "11" slow. 
    clk         => clk,                     -- No Tocar - Entrada de la señal del clock completo (100Mhz).
    clock       => clock                    -- No Tocar - Salida de la señal del clock reducido: 25Mhz, 8hz, 2hz y 0.5hz.
    );
    
 -- No Tocar - Intancia del controlador de los displays de 8 segmentos.    
inst_Display_Controller: Display_Controller port map(
    dis_a       => dis_a,                   -- No Tocar - Entrada de señales para el display A.
    dis_b       => dis_b,                   -- No Tocar - Entrada de señales para el display B.
    dis_c       => dis_c,                   -- No Tocar - Entrada de señales para el display C.
    dis_d       => dis_d,                   -- No Tocar - Entrada de señales para el display D.
    clk         => clk,                     -- No Tocar - Entrada del clock completo (100Mhz).
    seg         => seg,                     -- No Tocar - Salida de las señales de segmentos.
    an          => an                       -- No Tocar - Salida del selector de diplay.
	);
    
-- No Tocar - Intancias de los Debouncers.    
inst_Debouncer0: Debouncer port map( clk => clk, signal_in => btn(0), signal_out => d_btn(0) );
inst_Debouncer1: Debouncer port map( clk => clk, signal_in => btn(1), signal_out => d_btn(1) );
inst_Debouncer2: Debouncer port map( clk => clk, signal_in => btn(2), signal_out => d_btn(2) );
inst_Debouncer3: Debouncer port map( clk => clk, signal_in => btn(3), signal_out => d_btn(3) );
inst_Debouncer4: Debouncer port map( clk => clk, signal_in => btn(4), signal_out => d_btn(4) );

-- No Tocar - Intancia del ROM Programmer.           
inst_Programmer: Programmer port map(
    rx          => rx,                      -- No Tocar - Salida de la señal de transmición.
    tx          => tx,                      -- No Tocar - Entrada de la señal de recepción.
    clk         => clk,                     -- No Tocar - Entrada del clock completo (100Mhz).
    clock       => clock,                   -- No Tocar - Entrada del clock reducido.
    bussy       => clear,                   -- No Tocar - Salida de la señal de programación.
    ready       => write_rom,               -- No Tocar - Salida de la señal de escritura de la ROM.
    address     => pro_address(11 downto 0),-- No Tocar - Salida de señales del address de la ROM.
    dataout     => rom_datain               -- No Tocar - Salida de señales palabra de entrada de la ROM.
        );
        
inst_Timer: Timer port map(
   clk      => clk,
   clear    => clear,
   seconds  => muxin_s(15 downto 0),
   mseconds => muxin_m(15 downto 0),
   useconds => muxin_u(15 downto 0)     
);

inst_RegDis: RegDis port map(
       clock             => clk,                       -- Señal del clock (reducido).
       clear             => clear,                        -- Señal de reset.
       up                => '0',                        -- Señal de subida.
       down              => '0',                        -- Señal de bajada.
       load              => demux_dis,
       ram_datain        => ram_datain(15 downto 0),   -- Señales de entrada de datos.
       display           => dis(15 downto 0)  -- Señales de salida de datos.
 );
 
 inst_RegLED: RegLED port map(
       clock             => clk,                       -- Señal del clock (reducido).
       clear             => clear,                        -- Señal de reset.
       up                => '0',                        -- Señal de subida.
       down              => '0',                        -- Señal de bajada.
       load              => demux_led,
       ram_datain        => ram_datain(15 downto 0),   -- Señales de entrada de datos.
       led               => led(15 downto 0)  -- Señales de salida de datos.
 );
-- Fin de declaración de instancias.

-- Fin de declaración de comportamientos.
  
end Behavioral;