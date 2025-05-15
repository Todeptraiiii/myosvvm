--| Nhóm                     | Thủ tục / Hàm                                                                                                             | Mục đích chính                                    |
--| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
--| **Log**                  | `Log` (3 overloads)                                                                                                       | In thông điệp, lọc theo `LogType`                 |
--| **Alert**                | `Alert`, `AlertIf`, `AlertIfNot`, `AlertIfEqual/NotEqual`, `AlertIfFilesMatch/NotMatch`, `AlertDiff`                      | Báo lỗi và đếm **FAILURE / ERROR / WARNING**      |
--| **Affirm**               | `AffirmIf`, `AffirmIfEqual/NotEqual`, `AffirmIfFilesMatch/NotMatch`                                                       | “Assert‑pass” – tăng bộ đếm **PASSED**            |
--| **Cấu hình**             | `SetLogEnable`, `SetLogEnableHierarchy`, `SetLogEnableAll`<br>`SetAlertEnable`, `SetAlertStopCount`, `SetAlertLogOptions` | Bật/tắt mức log/alert, đặt ngưỡng dừng, định dạng |
--| **ID & tiện ích**        | `NewID`, `GetAlertCount`, `IsLogEnabled`, `GetTestName/SetTestName`                                                       | Phân cấp VC, truy vấn trạng thái                  |
--| **Báo cáo**              | `ReportAlerts/NonZeroAlerts`, `WriteAlertYaml`, `WriteAlertCsv`, `ReportRequirements`                                     | In/tạo file thống kê cuối test                    |
--| **Requirement tracking** | `ReadSpecification`, `GetReqID`, `SetPassedGoal`, `ReportRequirements`                                                    | Liên kết testcase ↔ tài liệu yêu cầu              |

-----------------------------------------------------------------------

--Bài 7 – Debug khối lớn (Case study)

-- Mục tiêu: Chứng minh “DEBUG tắt = mô phỏng nhanh”, thành thạo bật/tắt log ở cây ID lớn

--Cho entity axi_mux giả lập

--Mỗi cổng con dùng NewID riêng.

--Viết thủ tục TraceBeat(Data, ID) in DEBUG mỗi khi tvalid & tready.

--Bật DEBUG cho một cổng bất kỳ từ testbench.

--Bảo đảm mô phỏng 100 µs chạy < 30 s khi DEBUG tắt, và chậm hơn khi DEBUG bật (đo thời gian).

-----------------------------------------------------------------------




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.AlertLogPkg.all;

entity Test16 is end;

architecture sim of Test16 is
  ------------------------------------------------------------------
  -- ID hierarchy
  ------------------------------------------------------------------
  constant MUX_ID  : AlertLogIDType := NewID("MUX_TOP");
  constant S0_ID   : AlertLogIDType := NewID("SRC0", MUX_ID);
  constant S1_ID   : AlertLogIDType := NewID("SRC1", MUX_ID);
  constant S2_ID   : AlertLogIDType := NewID("SRC2", MUX_ID);
  constant S3_ID   : AlertLogIDType := NewID("SRC3", MUX_ID);

  ------------------------------------------------------------------
  -- Trace procedure (beat‑by‑beat)
  ------------------------------------------------------------------
  procedure TraceBeat( Data : std_logic_vector; ID : AlertLogIDType ) is
  begin
    Log(ID,
        "Beat = " & to_hstring(Data),
        DEBUG);                -- DEBUG level
  end procedure;
begin
  ------------------------------------------------------------------
  -- Traffic generators
  ------------------------------------------------------------------
  SRC0 : process
    variable data : std_logic_vector(31 downto 0) := x"00000000";
  begin
    
    SetLogEnable(S0_ID,DEBUG,TRUE);
    wait for 0 ns;

    for i in 0 to 255 loop
      TraceBeat(data, S0_ID);
      data := std_logic_vector(unsigned(data) + 1);
      wait for 2 ns;
    end loop;
    wait;                       -- giữ process sống
  end process;

  SRC1 : process
    
    variable data : std_logic_vector(31 downto 0) := x"10000000";
  begin

    SetLogEnable(S1_ID,DEBUG,TRUE);
    wait for 0 ns;

    for i in 0 to 255 loop
      TraceBeat(data, S1_ID);
      data := std_logic_vector(unsigned(data) + 1);
      wait for 2 ns;
    end loop;
    wait;
  end process;

  SRC2 : process
    variable data : std_logic_vector(31 downto 0) := x"20000000";
  begin
    SetLogEnable(S2_ID,DEBUG,TRUE);
    wait for 0 ns;
    for i in 0 to 255 loop
      TraceBeat(data, S2_ID);
      data := std_logic_vector(unsigned(data) + 1);
      wait for 2 ns;
    end loop;
    wait;
  end process;

  SRC3 : process
    variable data : std_logic_vector(31 downto 0) := x"30000000";
  begin
    SetLogEnable(S3_ID,DEBUG,TRUE);
    wait for 0 ns;
    for i in 0 to 255 loop
      TraceBeat(data, S3_ID);
      data := std_logic_vector(unsigned(data) + 1);
      wait for 2 ns;
    end loop;
    wait;
  end process;

  ------------------------------------------------------------------
  -- End‑of‑test bookkeeping
  ------------------------------------------------------------------
  FINISH : process
  begin
    wait for 100 us;                     -- thời gian “payload”
    ReportAlerts;
    WriteAlertYaml("alerts.yaml", TimeOut => FALSE);
    std.env.stop;
  end process;
end architecture;
