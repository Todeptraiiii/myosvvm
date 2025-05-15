library ieee; use ieee.std_logic_1164.all;
library osvvm; use osvvm.TbUtilPkg.all;

entity Test7 is end entity;
architecture beh of Test7 is
  signal B : integer_barrier := 0;
begin
  -- Two processes reach barrier at time 0
  p1: process
  begin
    report "P1 before barrier" severity NOTE;
    WaitForBarrier(B);
    report "P1 after barrier"  severity NOTE;
    wait;
  end process;

  p2: process
  begin
    report "P2 before barrier" severity NOTE;
    WaitForBarrier(B, 20 ns);  -- optional timeout
    report "P2 after barrier"  severity NOTE;
    wait;
  end process;

  -- Release barrier at 30 ns by setting B to 2
  ctrl: process
  begin
    wait for 30 ns;
    B <= 3; -- both p1 & p2 unblock
    report "Barrier released" severity NOTE;
    wait;
  end process;
end architecture;
