library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.ScoreboardPkg_slv.all;  -- package instance cho std_logic_vector
-- ScoreboardPkg_slv instantiates:
--   ExpectedType  = std_logic_vector
--   ActualType    = std_logic_vector
--   Match         = std_match
--   expected_to_string/actual_to_string = to_hstring
-- :contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}

entity Test3 is
end entity;

architecture tb of Test3 is
  signal SB : ScoreboardIDType;
  signal done : boolean := false;
begin
  tb_proc: process
    variable exp_val, act_val : std_logic_vector(7 downto 0);
    variable push_cnt, chk_cnt, fifo_cnt : integer;
  begin
    -- 1) Khởi tạo scoreboard
    SB <= NewID("SB1");
    wait for 0 ns;

    -- 2) Push expected value X"AA"
    exp_val := x"AA";
    Push(SB, exp_val);

    -- 3) Receive actual = X"AA" và Check
    act_val := x"AA";
    Check(SB, act_val);   -- tự động pop và AffirmIf

    -- 4) In counters
    push_cnt := GetPushCount(SB);
    chk_cnt  := GetCheckCount(SB);
    fifo_cnt := GetFifoCount(SB);
    report
      "PushCount=" & integer'image(push_cnt) &
      " CheckCount=" & integer'image(chk_cnt) &
      " FifoCount=" & integer'image(fifo_cnt)
    severity NOTE;

    wait;
  end process;
end architecture;
