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

type commands is (OP_READ, OP_WRITE, OP_READWRITE, OP_READ_OP, OP_NOP);

signal cmd : commands := OP_READ_OP;
signal counter : integer := 0;
signal data_in : std_logic_vector(7 downto 0);



begin
    
    process is
    begin
    wait until rising_edge(SCLK);
    if ENABLE = '0' then
        case cmd is
            when OP_READ_OP =>
                -- Read 8 cmd bits from SI port
                if counter < 8 then
                    --Read bit from SI port
                    data_in(7 - counter) <= SI;
                end if;
                
            when OP_READ => 
                --Read data
                if counter < 16 then
                    data_in(7 - (counter-8)) <= SI;
                end if;
            when OP_WRITE => NULL;
            when OP_READWRITE => 
                --Read data
                if counter < 16 then
                    data_in(7 - (counter-8)) <= SI;
                end if;
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
    end if;
    end process;
    
    process is
    begin
    wait until falling_edge(SCLK);
    if ENABLE = '0' then
        case cmd is
            when OP_READ_OP => 
                -- Put Slave Out into high impedance
                SO <= 'Z';
                
                if counter >= 8 then
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
                end if;
                
            when OP_READ => 
                -- Put Slave Out into high impedance
                SO <= 'Z';
                
            when OP_WRITE => 
                if counter < 16 then
                    SO <= parallel_data_in(counter-8);
                end if;
                
            when OP_READWRITE => 
                if counter < 16 then
                    SO <= parallel_data_in(counter-8);
                end if;
                
            when OP_NOP => 
                -- Put Slave Out into high impedance
                SO <= 'Z';
        end case;
        
        if counter >= 16 then
            cmd <= OP_READ_OP;
        end if;
    else 
        cmd <= OP_READ_OP;
    end if;
    end process;

end architecture;