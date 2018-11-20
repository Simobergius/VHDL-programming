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
--<<<<<<< Updated upstream
--signal cmd : std_logic_vector (7 downto 0) := B"00000000"; --MSB first
--=======
signal cmd : std_logic_vector (7 downto 0) := B"00000000";
-->>>>>>> Stashed changes
signal SlaveParallelIn : std_logic_vector (7 downto 0) := B"10010001";
signal SlaveParallelOut : std_logic_vector (7 downto 0);
signal count_clk : integer := 0;
signal done : std_logic := '0';
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
    wait for 250 ns;            --500 ns = 1 MHz
    SCLK <= NOT SCLK;
    count_clk <= count_clk + 1;
    if count_clk >= 20 then         
        if cmd = B"00000000" then
           cmd <= B"10000000";
           count_clk <= count_clk - 1;
        else
        ChipE <= '0';           --Start operation
        end if;
    end if;
<<<<<<< HEAD
    if (prev_ChipE XOR ChipE) = '1' then
        -- ChipE changed
        if ChipE = '0' then
            -- Falling edge of ChipE
            -- Write first bit of cmd
            SlaveIn <= cmd(7 - counter);
            counter := counter + 1;
        else
            --Rising edge of ChipE
            counter := 0;
=======
>>>>>>> parent of 55125b4... Hopeful TB update
    if counter = 16 AND SPICLK = '0' then
        ChipE <= '1';
        count_clk <= 0;
        --Cycle command to the next one
        if cmd = B"10000000" then
            cmd <= B"01000000";
        elsif cmd = B"01000000" then
            cmd <= B"11000000";
        else
            cmd <= B"00000000";
        end if;
    end if;
end process SYSTEM_KELLO;



SEND_DATA: process is
begin
    wait until rising_edge(SPICLK);
  
    if counter <= 7 then
        SlaveIn <= cmd(counter);
    else
        SlaveIn <= slave_spi_in(counter - 8);
    end if;
<<<<<<< HEAD
    if (SPICLK XOR prev_SPICLK) = '1' then
        --SPICLK changed state
        if SPICLK = '0' then
            -- SPICLK falling edge
            if counter <= 7 then
                -- write next bit of cmd
                SlaveIn <= cmd(7 - counter);
            else
                --Write next bit of data_in
                if counter < 16 then
                    SlaveIn <= slave_spi_in(7 - (counter - 8));
                end if;
            end if;
            counter := counter + 1;
        end if;
    end if;
    prev_ChipE := ChipE;
    prev_SPICLK := SPICLK;
--    wait until rising_edge(SPICLK);
--    if counter <= 7 then
--        SlaveIn <= cmd(counter);
--    else
--        SlaveIn <= slave_spi_in(counter - 8);
--    end if;
-- 
    if counter = 17 then
        counter := 0;
        done <= '1';
=======
>>>>>>> parent of 55125b4... Hopeful TB update
 
    counter <= counter + 1;

SEND_DATA: process (SPICLK, ChipE) is
variable counter : integer := 0;
variable prev_ChipE : std_logic := '1';
variable prev_SPICLK : std_logic := '0';
begin
    
    if (prev_ChipE XOR ChipE) = '1' then
        -- ChipE changed
        if ChipE = '0' then
            -- Falling edge of ChipE
            -- Write first bit of cmd
            SlaveIn <= cmd(counter);
            counter := counter + 1;
        end if;
    end if;
    
    if (SPICLK XOR prev_SPICLK) = '1' then
        --SPICLK changed state
        if SPICLK = '0' then
            -- SPICLK falling edge
            -- write next bit of cmd
            if counter <= 7 then
                SlaveIn <= cmd(counter);
            else
                SlaveIn <= slave_spi_in(counter - 8);
            end if;
            counter := counter + 1;
        end if;
    end if;
    prev_ChipE := ChipE;
    prev_SPICLK := SPICLK;
    wait until rising_edge(SPICLK);
    if counter <= 7 then
        SlaveIn <= cmd(counter);
    else
        SlaveIn <= slave_spi_in(counter - 8);
    end if;
 

    if counter = 15 then
        counter <= 0;
        done <= '1';
    end if;
end process;

process is 
begin
    wait until falling_edge(SPICLK);
    
    if counter = 50 then
        done <= '1';
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