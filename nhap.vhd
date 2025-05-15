library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

-- OSVVM context nạp toàn bộ gói cần thiết (CoveragePkg, AlertLogPkg, …)
library osvvm ;
context osvvm.OsvvmContext ;

entity nhap is
end entity ;

architecture sim of nhap is
  --------------------------------------------------------------------
  -- Mã hoá trạng thái
  --------------------------------------------------------------------
  constant IDLE : integer := 0;
  constant RUN  : integer := 1;

  signal state_int : integer := IDLE;      -- “FSM” đang kiểm thử
  signal clk       : std_logic := '0';

  --------------------------------------------------------------------
  -- Coverage object
  --------------------------------------------------------------------
  signal FsmCov : CoverageIDType;
begin
  --------------------------------------------------------------------
  -- Clock 10 ns
  clk <= not clk after 5 ns;

  --------------------------------------------------------------------
  -- Khởi tạo Coverage & mô hình transition
  --------------------------------------------------------------------
  INIT : process
  begin
    ----------------------------------------------------------------
    -- 1) NewID
    ----------------------------------------------------------------
    FsmCov <= NewID("FSM_Cov");
    wait for 0 ns;                           -- để ID hoàn tất

    ----------------------------------------------------------------
    -- 2) Add bins: item coverage (tuỳ chọn) + cross 2×2
    ----------------------------------------------------------------
    AddBins(FsmCov, GenBin(IDLE));
    AddBins(FsmCov, GenBin(RUN));
    AddCross(FsmCov, GenBin(IDLE,RUN), GenBin(IDLE,RUN));  -- prev × curr

    ----------------------------------------------------------------
    -- 3) (Tùy chọn) đặt Illegal transition RUN→RUN
    ----------------------------------------------------------------
    -- Comment/Uncomment để thử các chế độ
    AddBins(FsmCov, IllegalBin((RUN, RUN)));
    --SetIllegalMode(FsmCov, ILLEGAL_ON);      -- Alert ERROR (mặc định)
    --SetIllegalMode(FsmCov, ILLEGAL_OFF);     -- im lặng
    --SetIllegalMode(FsmCov, ILLEGAL_FAILURE); -- Alert FAILURE

    wait;       -- kết thúc process INIT
  end process;

  --------------------------------------------------------------------
  -- Thu thập transition coverage bằng TCover
  --------------------------------------------------------------------
  COVER : process(clk)
    variable prev_state : integer := IDLE;
    variable tuple      : integer_vector(1 downto 0);
  begin
    if rising_edge(clk) then
      -- ghi transition prev→curr
      tuple := (prev_state, state_int);
      TCover(FsmCov, tuple);
      prev_state := state_int;
    end if;
  end process;

  --------------------------------------------------------------------
  -- Stimulus: Sinh 10 gói → IDLE→RUN→IDLE,
  --           kèm một pha RUN giữ 3 chu kỳ để tạo RUN→RUN.
  --------------------------------------------------------------------
  STIM : process
    variable pkt_cnt : integer := 0;
  begin
    wait until rising_edge(clk);   -- đồng bộ

    -- Lặp 10 gói
    while pkt_cnt < 10 loop
      -- Nhàn IDLE 2 chu kỳ
      for i in 0 to 1 loop
        state_int <= IDLE;
        wait until rising_edge(clk);
      end loop;

      -- Start packet
      state_int <= RUN;
      wait until rising_edge(clk);

      -- (Tùy chọn) Tạo RUN→RUN illegal giữ thêm chu kỳ
      if pkt_cnt = 3 then          -- chỉ gói thứ 4
        wait until rising_edge(clk);  -- RUN giữ thêm 1 chu kỳ
      end if;

      -- Done
      state_int <= IDLE;
      wait until rising_edge(clk);

      pkt_cnt := pkt_cnt + 1;
    end loop;

    ----------------------------------------------------------------
    -- Kết thúc mô phỏng: In báo cáo
    ----------------------------------------------------------------
    WriteBin(FsmCov);
    WriteCovHoles(FsmCov);          -- liệt kê hole (nếu còn)
    ReportAlerts;
    std.env.stop;
  end process;
end architecture ;
