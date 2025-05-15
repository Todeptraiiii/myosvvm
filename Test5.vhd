library ieee; use ieee.std_logic_1164.all;
library osvvm; use osvvm.ScoreboardPkg_slv.all;

entity Test5 is
end entity;

architecture tb of Test5 is
  signal SB : ScoreboardIDType;
begin
  tb_proc3: process
    variable expA, expB, recA, recB : std_logic_vector(7 downto 0);
  begin
    SB <= NewID("TaggedSB");
    wait for 0 ns;

    -- Push hai transaction với tag
    expA := x"11"; Push(SB, "W", expA);    -- tag = "W"
    expB := x"22"; Push(SB, "R", expB);    -- tag = "R"

    -- Nhận out-of-order: trước nhận R, sau W
    recB := x"22"; Check(SB, "R", recB);   -- đúng tag "R"
    recA := x"11"; Check(SB, "W", recA);   -- đúng tag "W"

    report "Tagged check done" severity NOTE;
    wait;
  end process;
end architecture;
