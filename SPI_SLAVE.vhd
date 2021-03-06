use work.edge_latch;
library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity SPI is
    port(
        CLK : in std_logic;
        SI : in std_logic;
        SO : out std_logic := 'Z';
        SCLK : in std_logic;
        ENABLE : in std_logic;
        parallel_data_in : in std_logic_vector(7 downto 0);
        parallel_data_out : out std_logic_vector(7 downto 0) := B"00000000";
        debug_state : out std_logic_vector(3 downto 0)
        );
        
end entity;

architecture behavior of SPI is

type commands is (OP_READ, OP_WRITE, OP_READWRITE, OP_READ_OP, OP_NOP);

signal cmd : commands := OP_READ_OP;
signal counter : integer range 0 to 16 := 0;
signal data_in : std_logic_vector(7 downto 0);
signal SCLK_edge : std_logic := '0';


begin

debug_state <= std_logic_vector(to_unsigned(counter, 4));
    process (CLK) is
    variable data_in_local : std_logic_vector (7 downto 0) := B"00000000";
    begin
    if rising_edge(CLK) then
        if SCLK_edge = '1' then
            if SCLK = '1' then
                if ENABLE = '0' then
                    case cmd is
                        when OP_READ_OP =>
                            -- Read 8 cmd bits from SI port
                            -- 
                            if counter < 8 then
                                --Read bit from SI port
                                data_in(7 - counter) <= SI;
                            end if;
                            
                            -- We can determine command here, on 8th rising edge
                            -- but cant use signal because it doesnt update until next
                            -- cycle so use local variable
                            if counter = 7 then
                                data_in_local(7 downto 1) := data_in(7 downto 1);
                                data_in_local(7 - counter) := SI;
                                if data_in_local = B"00000000" then 
                                    cmd <= OP_NOP;
                                    --debug_state <= "00";
                                elsif data_in_local = B"00000001" then
                                    cmd <= OP_READ;
                                    --debug_state <= "01";
                                elsif data_in_local = B"00000010" then
                                    cmd <= OP_WRITE;
                                    --debug_state <= "10";
                                elsif data_in_local = B"00000011" then
                                    cmd <= OP_READWRITE;
                                    --debug_state <= B"11";
                                else
                                    cmd <= OP_NOP;
                                    --debug_state <= B"00";
                                end if;
                                
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
                    
                    if counter >= 15 then
                        -- Use data_in_local here because signal updates only after process finishes
                        data_in_local(7 downto 1) := data_in(7 downto 1);
                        data_in_local(7 - (counter - 8)) := SI;
                        counter <= 0;
                        if cmd = OP_READWRITE or cmd = OP_READ then
                            parallel_data_out <= data_in_local;
                        end if;
                        cmd <= OP_READ_OP;
                    end if;
                else 
                    cmd <= OP_READ_OP;
                    counter <= 0;
                end if;
            else
                if ENABLE = '0' then
                    case cmd is
                        when OP_READ_OP => 
                            -- Put Slave Out into high impedance
                            SO <= 'Z';
                            
                        when OP_READ => 
                            -- Put Slave Out into high impedance
                            SO <= 'Z';
                            
                        when OP_WRITE => 
                            if counter < 16 then
                                SO <= parallel_data_in(7 - (counter-8));
                            end if;
                            
                        when OP_READWRITE => 
                            if counter < 16 then
                                SO <= parallel_data_in(7 - (counter-8));
                            end if;
                            
                        when OP_NOP => 
                            -- Put Slave Out into high impedance
                            SO <= 'Z';
                    end case;
                end if;
            end if;
        end if;
        
        if ENABLE='1' then
            counter <= 0;
            SO <= 'Z';
        end if;
    end if;
    end process;
    
SCLK_edge_detector: entity edge_latch
    port map (
        sys_clk => CLK,
        D_in => SCLK,
        D_OUT => SCLK_edge
    );
    
end architecture;