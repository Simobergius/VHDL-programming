library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SPI_TestBench is
end entity SPI_TestBench;

architecture top_level of SPI_TestBench is

use work.SPI_SLAVE;

signal SlaveIn : std_logic := '0';
signal SlaveOut : std_logic := '0';
signal SPICLK : std_logic := '0';
signal SCLK : std_logic := '0';
signal ChipE : std_logic := '1';
signal cmd : std_logic_vector (7 downto 0) := B"00000000"; --MSB first
signal SlaveParallelIn : std_logic_vector (7 downto 0) := B"10010001";
signal SlaveParallelOut : std_logic_vector (7 downto 0);
signal count_clk : integer := 0;
signal slave_spi_in : std_logic_vector (7 downto 0) := B"01110110";
signal counter : integer := 0;

begin

SPI_KELLO: process is 
begin
    wait for 1 us;      --1 us = 500kHz
    if ChipE = '0' then
    SPICLK <= NOT SPICLK;
    else
    SPICLK <= '0';
    end if;

end process SPI_KELLO;


SYSTEM_KELLO: process is 
begin
    wait for 500 ns;            --500 ns = 1 MHz
    SCLK <= NOT SCLK;
    
end process SYSTEM_KELLO;

ChangeCMD: process is
begin
    wait until rising_edge(SCLK);
    if counter = 0 then
        wait for 2 us;
    end if;
    
    if counter = 15 OR cmd = B"00000000" then
        
        if cmd = B"00000000" then   --If cmd = 0, skip to next cmd
            cmd <= B"10000000";
            ChipE <= '1';
        elsif cmd = B"10000000" then
            wait for 2 us;
            cmd <= B"01000000";
            ChipE <= '1';
        elsif cmd = B"01000000" then
            wait for 2 us;
            cmd <= B"11000000";
            ChipE <= '1';
        else
            wait for 2 us;
            cmd <= B"00000000";
            ChipE <= '1';
        end if;
    else
        ChipE <= '0';
    end if;

end process ChangeCMD;


SEND_DATA: process is
begin
    wait until rising_edge(SPICLK);
    if counter <= 7 then
        SlaveIn <= cmd(counter);
    else
        SlaveIn <= slave_spi_in(counter - 8);
    end if;
    
    if counter < 15 then
    counter <= counter + 1;
    end if;
    
    wait until rising_edge(SCLK);
     if counter = 15 then
     wait for 2 us;
        counter <= 0;
    end if;
    
end process;

Joku : entity SPI_SLAVE
    port map (
        SI  => SlaveIn,
        SO  => SlaveOut,
        SCLK    => SPICLK,
        sys_clk => SCLK,
        ENABLE  => ChipE,
        parallel_data_in => SlaveParallelIn,
        parallel_data_out => SlaveParallelOut
    );

end architecture;