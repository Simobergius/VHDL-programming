library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SPI_SLAVE is
    port(
        SI : in std_logic;
        SO :out std_logic;
        SCLK : in std_logic;
        ENABLE : in std_logic;
        sys_clk : in std_logic;
        parallel_data_in : in std_logic_vector(7 downto 0);
        parallel_data_out : out std_logic_vector(7 downto 0)
        );
        
end entity;

architecture behavior of SPI_SLAVE is

use work.edge_latch;

type commands is (OP_READ, OP_WRITE, OP_READWRITE, OP_READ_OP, OP_NOP);

signal reg : std_logic_vector(7 downto 0) := B"00110011";
signal cmd : commands;
signal read_cmd : std_logic := '1';
signal enable_triggered : std_logic := '0';
signal enable_triggered_falling : std_logic := '0';
signal counter : integer := 0;
signal opcode : std_logic_vector(7 downto 0);



begin
    
    enable_trigd : process (sys_clk) is
    begin
    if enable_triggered = '1' then
        if ENABLE = '1' then
            enable_triggered_falling <= '1';
        else
            enable_triggered_falling <= '1';
        end if;
    end if;
    end process;
    
    process is
    begin
    wait until rising_edge(SCLK);
    if enable_triggered_falling = '1' then
        case cmd is
            when OP_READ_OP =>
                -- Read 8 bits from SI port
                if counter = 8 then
                    --Stop reading at eigth bit and plop command into signal
                    if opcode = B"00000000" then 
                        cmd <= OP_NOP;
                    elsif opcode = B"00000001" then
                        cmd <= OP_READ;
                    elsif opcode = B"00000010" then
                        cmd <= OP_WRITE;
                    elsif opcode = B"00000011" then
                        cmd <= OP_READWRITE;
                    else
                        cmd <= OP_NOP;
                    end if;
                    read_cmd <= '0';
                elsif read_cmd = '1' then
                    --Read bit from SI port
                    opcode(counter) <= SI;
                end if;
                
            when OP_READ => NULL;
                
            when OP_WRITE => NULL;
                
            when OP_READWRITE => NULL;
                
            when OP_NOP => NULL;
        end case;
        -- increment counter
        counter <= counter + 1;
    end if;
    end process;
    
    

CSedgedetector : entity edge_latch
    port map(
        sys_clk => sys_clk,
        D_in => ENABLE,
        D_out => enable_triggered
        );

end architecture;