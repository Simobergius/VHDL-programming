library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SPI_SLAVE is
    port(
        SI : in std_logic;
        SO : out std_logic := 'Z';
        SCLK : in std_logic;
        ENABLE : in std_logic;
        sys_clk : in std_logic;
        parallel_data_in : in std_logic_vector(7 downto 0);
        parallel_data_out : out std_logic_vector(7 downto 0) := B"00000000"
        );
        
end entity;

architecture behavior of SPI_SLAVE is

use work.edge_latch;

type commands is (OP_READ, OP_WRITE, OP_READWRITE, OP_READ_OP, OP_NOP);

signal cmd : commands := OP_READ_OP;
signal read_cmd : std_logic := '1';
signal enable_triggered : std_logic := '0';
signal enable_triggered_falling : std_logic := '0';
signal enable_triggered_rising : std_logic := '0';
signal counter : integer := 0;
signal data_in : std_logic_vector(7 downto 0);



begin
    
    process (sys_clk) is
    begin
    if enable_triggered = '1' then
        if ENABLE = '0' then
            enable_triggered_falling <= '1';
            enable_triggered_rising <= '0';
        else
            enable_triggered_falling <= '0';
            enable_triggered_rising <= '1';
        end if;
    end if;
    end process;
    
    process is
    begin
    wait until rising_edge(SCLK);
    if ENABLE = '0' then
        case cmd is
            when OP_READ_OP =>
                -- Read 8 bits from SI port
                if counter = 8 then
                    --Stop reading at eigth bit and plop command into signal
                    if data_in = B"00000000" then 
                        cmd <= OP_NOP;
                    elsif data_in = B"00000001" then
                        cmd <= OP_READ;
                    elsif data_in = B"00000010" then
                        cmd <= OP_WRITE;
                    elsif data_in = B"00000011" then
                        cmd <= OP_READWRITE;
                    else
                        cmd <= OP_NOP;
                    end if;
                else
                    --Read bit from SI port
                    data_in(counter) <= SI;
                end if;
                
            when OP_READ => 
                --Read data
                data_in(counter-8) <= SI;
            when OP_WRITE => NULL;
            when OP_READWRITE => 
                --Read data
                data_in(counter-8) <= SI;
            when OP_NOP => NULL;
        end case;
        -- increment counter
        counter <= counter + 1;
        if counter >= 16 then
            counter <= 0;
            parallel_data_out <= data_in;
        end if;
    else
        counter <= 0;
        cmd <= OP_READ_OP;
    end if;
    end process;
    
    process is
    begin
    wait until falling_edge(SCLK);
    
    case cmd is
        when OP_READ_OP => 
            -- Put Slave Out into high impedance
            SO <= 'Z';
        when OP_READ => 
            -- Put Slave Out into high impedance
            SO <= 'Z';
            
        when OP_WRITE => 
            SO <= parallel_data_in(counter-8);
            
        when OP_READWRITE => 
            SO <= parallel_data_in(counter-8);
        when OP_NOP => 
            -- Put Slave Out into high impedance
            SO <= 'Z';
    end case;
    
    end process;

CSedgedetector : entity edge_latch
    port map(
        sys_clk => sys_clk,
        D_in => ENABLE,
        D_out => enable_triggered
        );

end architecture;