
library ieee;
use ieee.std_logic_1164.all;

entity edge_latch is
    port (
        sys_clk : in std_logic;
        D_in : in std_logic;
        D_out : out std_logic
        );
end entity;

architecture behavior of edge_latch is
signal last_D : std_logic;
begin
process (sys_clk) is
begin
if falling_edge(sys_clk) then
D_out <= D_in xor last_D;
last_D <= D_in;
end if;
end process;
end architecture;