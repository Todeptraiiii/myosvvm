library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library osvvm;
use osvvm.CoveragePkg.all;

entity Test2 is
end entity;

architecture tb of Test2 is
  signal Cov1 : CoverageIDType;
  signal Clk  : std_logic := '0';
  signal Data : std_logic_vector(7 downto 0);
  -- biến để nhận giá trị sinh ngẫu nhiên
begin
  -- Clock generator (đơn giản)
  ClkProc: process
  begin
    wait for 5 ns; Clk <= not Clk;
  end process;

  TestProc: process
    variable Val : integer;
  begin
    -- 1) Tạo model coverage
    Cov1 <= NewID("Cov1");  
    wait for 0 ns;            -- cho CoveragePkg cập nhật object :contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}

    -- 2) Định nghĩa bins: 0…255, mỗi giá trị một bin
    AddBins(Cov1, GenBin(0, 255));  -- 256 bins, range từng giá trị :contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}

    -- 3) Vòng lặp random walk cho tới khi cover hết
    for i in 0 to 64  loop
      -- 3.1 Sinh một giá trị còn “hole” trong coverage model
      Val := GetRandPoint(Cov1);  

      -- 3.2 Dùng Val cho stimulus (ví dụ gán vào Data)
    --   Data <= std_logic_vector(to_unsigned(Val, Data’length));

      -- 3.3 Cập nhật coverage: đánh dấu bin Val đã hit
      ICover(Cov1, Val);

      -- 3.4 Dừng khi đã cover 100%
      exit when IsCovered(Cov1);
    end loop;

    -- 4) In báo cáo coverage
    WriteBin(Cov1);        -- in ra tất cả bins và số lần hit
    WriteCovHoles(Cov1);   -- in ra các holes (nếu có)
    wait;
  end process;
end architecture;
