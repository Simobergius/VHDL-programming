library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SPI_SLAVE is
    port(
        SI : in std_logic;
        SO :out std_logic;
        SCLK : in std_logic;
        ENABLE : in std_logic;
        sys_clk : in std_logic
        );
        
end entity;

architecture behavior of SPI_SLAVE is

use work.edge_latch;

signal reg : std_logic_vector(7 downto 0) := B"00110011";
signal cmd : std_logic_vector(7 downto 0);
signal read_cmd : std_logic := '1';
signal enable_triggered : std_logic := '0';




begin
    --
    process (sys_clk) is
    begin
    if enable_triggered = '1' then
        if ENABLE = '1' then
            read_cmd <= '1';
        else
            read_cmd <= '0';
        end if;
    end if;
    end process;
    
    process is
    variable counter : integer := 0;
    begin
    wait until rising_edge(SCLK);
    if read_cmd = '1' then
        cmd(counter) <= SI and read_cmd;
        -- increment counter
        counter := counter + 1;
        if counter = 7 then
            read_cmd <= '0';
        end if;
    else
        counter := 0;
    end if;
    
    end process;
    
    

CSedgedetector : entity edge_latch
    port map(
        sys_clk => sys_clk,
        D_in => ENABLE,
        D_out => enable_triggered
        );

end architecture;