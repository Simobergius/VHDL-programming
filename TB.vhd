library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TestBench is
end entity TestBench;

architecture top_level of TestBench is

use work.SPI_SLAVE;

signal SlaveIn : std_logic := '0';
signal SlaveOut : std_logic := '0';
signal SPICLK : std_logic := '0';
signal SCLK : std_logic := '0';
signal ChipE : std_logic := '1';
signal cmd : std_logic_vector (7 downto 0) := B"00001000";
signal SlaveParallelIn : std_logic_vector (7 downto 0);
signal SlaveParallelOut : std_logic_vector (7 downto 0);

begin

SPI_KELLO: process is 
begin
	wait for 1 us;		--1 us = 500kHz
	SPICLK <= NOT SPICLK; 
end process SPI_KELLO;


SYSTEM_KELLO: process is 
begin
	wait for 500 ns;	--500 ns = 1 MHz
	SCLK <= NOT SCLK;
end process SYSTEM_KELLO;


Joku : entity SPI_SLAVE
	port map (
		SI	=> SlaveIn,
		SO	=> SlaveOut,
		SCLK  	=> SPICLK,
		sys_clk => SCLK,
		ENABLE 	=> ChipE,
        parallel_data_in => SlaveParallelIn,
        parallel_data_out => SlaveParallelOut
	);

end architecture;


