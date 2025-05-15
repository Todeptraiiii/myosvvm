library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library osvvm; 
use osvvm.TbUtilPkg.all;
use osvvm.ScoreboardPkg_slv.all;  -- package instance cho std_logic_vector

entity Test6 is end entity;
architecture beh of Test6 is
  signal V    : std_logic_vector(3 downto 0);
  signal ZOH, OH : boolean;
begin
  proc: process
    type tv is array (0 to 4) of std_logic_vector(3 downto 0);
    constant T: tv := ( "0000", "0001", "0011", "0100", "1111" );
  begin
    for i in T'range loop
      V <= T(i);
      wait for 10 ns;
      ZOH <= ZeroOneHot(T(i));
      OH  <= OneHot    (T(i));
      report 
        -- "V=" & T(i) &
        " ZOH=" & boolean'image(ZOH) &
        " OH="  & boolean'image(OH)
        severity NOTE;
    end loop;
    wait;
  end process;
end architecture;
