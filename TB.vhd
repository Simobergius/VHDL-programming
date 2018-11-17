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
signal cmd : std_logic_vector (7 downto 0) := B"00000010";
signal SlaveParallelIn : std_logic_vector (7 downto 0) := B"10010001";
signal SlaveParallelOut : std_logic_vector (7 downto 0);
signal count_clk : integer := 0;
signal done : std_logic := '0';
signal slave_spi_in : std_logic_vector (7 downto 0) := B"01110110";

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
    wait for 250 ns;    --500 ns = 1 MHz
    SCLK <= NOT SCLK;
    count_clk <= count_clk + 1;
    if count_clk = 50 then
        ChipE <= '0';
    end if;
    if done = '1' then
        ChipE <= '1';
    end if;
end process SYSTEM_KELLO;


SEND_DATA: process is
variable counter : integer := 0;
begin
    wait until rising_edge(SPICLK);
    if counter <= 7 then
        SlaveIn <= cmd(counter);
    else
        SlaveIn <= slave_spi_in(counter - 8);
    end if;
 
    if counter = 15 then
        counter := 0;
        done <= '1';
    end if;
    counter := counter + 1;
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