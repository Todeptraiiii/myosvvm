
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

entity Test4 is
end entity;
-- (Cùng setup như trên)
architecture tb2 of Test4 is
    signal SB : ScoreboardIDType;
  begin
    tb_proc2: process
      variable exp_val, act_val : std_logic_vector(7 downto 0);
    begin
      SB <= NewID("SB2");
      wait for 0 ns;
  
      -- Push expected X"55"
      exp_val := x"55";
      Push(SB, exp_val);
  
      -- Check actual X"77" → sai
      act_val := x"77";
      Check(SB, act_val);   -- AffirmIf sẽ ERROR
  
      wait;
    end process;
  end architecture;
  