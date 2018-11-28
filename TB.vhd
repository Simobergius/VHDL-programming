library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SPI_TestBench is
end entity SPI_TestBench;

architecture top_level of SPI_TestBench is

use work.SPI;

signal SlaveIn : std_logic := '0';
signal SlaveOut : std_logic := '0';
signal SPICLK : std_logic := '0';
signal SCLK : std_logic := '0';
signal ChipE : std_logic := '1';
signal cmd : std_logic_vector (7 downto 0) := B"00000000"; --MSB first
signal SlaveParallelIn : std_logic_vector (7 downto 0) := B"10100001";
signal SlaveParallelOut : std_logic_vector (7 downto 0);
signal count_clk : integer := 0;
signal slave_spi_in : std_logic_vector (7 downto 0) := B"01110110";
signal counter : integer := 0;
signal prevChipE : std_logic := '1';
signal prevSPICLK : std_logic := '0';

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
    count_clk <= count_clk + 1;
    
    if count_clk = 36 then
        count_clk <= 0;
    end if;
    
end process SYSTEM_KELLO;




ChangeCMD: process is
begin
    wait until rising_edge(SCLK);
    if counter = 0 then
    end if;
    
    if count_clk = 35 then
        
        if cmd = B"00000000" then   --If cmd = 0, skip to next cmd
            cmd <= B"00000001";
            ChipE <= '0';
        elsif cmd = B"00000001" then
            cmd <= B"00000010";
            ChipE <= '0';
        elsif cmd = B"00000010" then
            cmd <= B"00000011";
            ChipE <= '0';
        else
            cmd <= B"00000000";
            ChipE <= '0';
        end if;
    
    elsif counter > 16 then
        ChipE <= '1';   
    end if;


end process ChangeCMD;

process (ChipE, SPICLK) is
begin
    if prevChipE = '1' AND ChipE = '0' then     --ChipE laskureuna
        if counter <= 7 then
            SlaveIn <= cmd(7 - counter);
        elsif counter < 16 then 
            SlaveIn <= slave_spi_in(7 - (counter - 8));
        end if;
        counter <= counter + 1;
        
    elsif prevChipE = '0' AND ChipE = '1' then  --ChipE nousureuna
        counter <= 0;
    end if;
        
    if prevSPICLK = '1' AND SPICLK = '0' then     --SPICLK laskureuna
        if counter <= 7 then
            SlaveIn <= cmd(7 - counter);
        elsif counter < 16 then
            SlaveIn <= slave_spi_in(7 - (counter - 8));
        elsif counter >= 16 then
            SlaveIn <= '0';
        end if;
        counter <= counter + 1;
    end if;

    prevChipE <= ChipE;
    prevSPICLK <= SPICLK;



end process;




--SEND_DATA: process is
--begin
--    wait until rising_edge(SPICLK);
--    if counter <= 7 then
--        SlaveIn <= cmd(counter);
--    else
--        SlaveIn <= slave_spi_in(counter - 8);
--    end if;
--    
--    if counter < 15 then
--    counter <= counter + 1;
--    end if;
--    
--    wait until rising_edge(SCLK);
--     if counter = 15 then
--     wait for 2 us;
--        counter <= 0;
--    end if;
--    
--end process;

Joku : entity SPI
    port map (
        SI  => SlaveIn,
        SO  => SlaveOut,
        SCLK    => SPICLK,
        ENABLE  => ChipE,
        parallel_data_in => SlaveParallelIn,
        parallel_data_out => SlaveParallelOut
    );

end architecture;