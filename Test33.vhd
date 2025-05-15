-- | Nhóm                                     | Thủ tục / Hàm                                                              | Chức năng chính                                          | Ghi chú dùng                     |
-- | ---------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------- | -------------------------------- |
-- | **Khởi tạo / Seed**                      | `InitSeed(seed : integer)`<br>`InitSeed(seed_str : string)`                | Nạp seed, reset PRNG                                     | Chuỗi được băm CRC‑32 thành seed |
-- |                                          | `GetSeed return integer`                                                   | Trả seed hiện thời                                       | Ghi log để replay                |
-- |                                          | `ResetRandomState` *(2025)*                                                | Quay về đầu luồng (replay trong run)                     | Không đổi seed                   |
-- | **Random nguyên**                        | `RandInt(lo,hi)`                                                           | Số nguyên bao gồm cả lo+hi                               | 32‑bit                           |
-- |                                          | `RandIntExcl(lo,hi,ExcludeVector)`                                         | Sinh trong phạm vi nhưng bỏ giá trị                      | Hỗ trợ “tránh lặp lại”           |
-- |                                          | `RandIntV(IntVector)`                                                      | Chọn một phần tử ngẫu nhiên từ vector giá trị            |                                  |
-- | **Random bit / bool**                    | `RandBit(prob)`                                                            | ‘1’ với xác suất *prob*                                  | `prob` : real 0…1                |
-- |                                          | `RandBool(prob)`                                                           | boolean tương đương                                      | TRUE = ‘1’                       |
-- | **Random std\_logic\_vector / unsigned** | `RandSlv(width)` / `RandUnsigned(width)`                                   | Chuỗi bit tùy chiều dài                                  |                                  |
-- |                                          | `RandSlv(lo,hi)` / `RandUnsigned(lo,hi)`                                   | Sinh giá trị 2^n‑bit trong phạm vi                       |                                  |
-- |                                          | `RandSlvExcl(lo,hi,ExcludeVector)`                                         | … nhưng bỏ những giá trị                                 |                                  |
-- | **Random kiểu thời gian / real**         | `RandReal(lo,hi)`                                                          | Real trong khoảng                                        |                                  |
-- |                                          | `RandTime(lo,hi,unit)`                                                     | Thời gian ngẫu nhiên                                     | unit = fs, ps, ns …              |
-- | **Random mảng (phân phối)**              | `RandIntArray(IntArray, ProbArray)`                                        | Chọn giá trị theo trọng số xác suất                      | ProbArray sum ≤ 1.0              |
-- | **Điều khiển phân phối**                 | `SetRandMode(Mode)`<br>   • `RAND_MODE_UNIFORM`<br>   • `RAND_MODE_BIASED` | Chế độ lấy số *Uniform* (mặc định) hay *Biased* (ít lặp) | Ảnh hưởng một stream             |
-- | **Truy vấn/Debug**                       | `GetRandIndex return integer`                                              | Số lần gọi Rand\* tới nay                                | Hữu ích khi log bug điểm #       |
-- |                                          | `GetRandMax return integer`                                                | Max giá trị PRNG nội (2³²‑1)                             |                                  |
-- | **Xác suất nâng cao**                    | `RandCovered(ID)`                                                          | Lấy giá trị từ Intelligent‑Coverage còn “hole”           | Wrapper: `GetRandBinVal`         |
-- | **Hàm tiện ích khác**                    | `Swap(RandPType, RandPType)`                                               | Hoán đổi trạng thái 2 luồng                              |                                  |
-- |                                          | `CopyState(src,dst)`                                                       | Sao chép PRNG state                                      | Phục vụ snapshot                 |

------------------------------------------------------------------------------------

-- Bài 3 – RandBit với xác suất 25 %
-- Mục tiêu: khẳng định rằng hàm RandBit(0.25) thật sự tạo ra khoảng 25 % bit ‘1’.


------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;


entity Test33 is
end entity;

architecture tb of Test33 is

    constant TB_ID : AlertLogIDType := NewID("Test33");
    constant PROB : real := 0.25;

begin

    test_proc: process
        variable R      : RandomPType;
        variable dInt   : integer := 0;
        variable slv8   : std_logic_vector(7 downto 0);
        variable dSlv40 : std_logic_vector(39 downto 0);
        variable MIN_VAL_V40 : std_logic_vector(39 downto 0) := (others => '0');
        variable MAX_VAL_V40 : std_logic_vector(39 downto 0) := (others => '1');

    begin
        SetTestName("Test33");
        SetLogEnable(TB_ID, PASSED, TRUE);
        SetLogEnable(TB_ID, INFO, TRUE);

        TranscriptOpen;
        SetTranscriptMirror(TRUE);

        wait for 0 ns; wait for 0 ns;
        R.InitSeed(1);

        for i in 1 to 10 loop

        -- Randomization wwith a range + exclude, uncomment to run

        -- dInt := R.RandInt(1, 15, (3, 5, 7)); -- ran dom trong khoang 1 - 15, 3, 5, 7 khong xuat hien
        -- Log(TB_ID, "dInt = " & to_string(dInt), INFO);
        -- AffirmIf(dInt /= 3 and dInt /= 5 and dInt /= 7, "dInt = " & to_string(dInt));
        -- end loop;
        -- -- slv
        -- for i in 1 to 15 loop
        -- slv8 := R.RandSlv(1, 15, (3, 5, 7), 8);
        -- Log(TB_ID, "slv8 = " & to_string(slv8), INFO);


        -- Randomization of a Set, uncomment to run

        -- dInt := R.RandInt((1,3,5,7,9)); -- random trong khoang nay
        -- Log(TB_ID, "dInt = " & to_string(dInt), INFO);

        -- Randomization of a Set + exclude, uncomment to run

        -- dInt := R.RandInt((1,3,5,7,9), (3,7));
        -- Log(TB_ID, "dInt = " & to_string(dInt), INFO);



        -- Larger than Integer Ranges, uncomment to run
        -- dSlv40 := R.RandSlv(40);
        -- dSlv40 := R.RandSLV(MAX_VAL_V40, MAX_VAL_V40);
        -- Log(TB_ID, "dSlv40 = " & to_string(dSlv40), INFO);


        -- Weighted Randomization, uncomment to run
        -- dInt := R.DistValInt(((1,7),(3,2),(5,1))); -- tuong tu voi cac kieu du lieu khac
        -- Log(TB_ID, "dInt = " & to_string(dInt), INFO);

        -- Simple Weighted Randomization, uncomment to run

        -- dInt := R.DistInt((7,2,1));
        -- Log(TB_ID, "dInt = " & to_string(dInt), INFO);

        end loop;

        TranscriptClose;
        -- EndOfTestReports(ExternalErrors => (FAILURE => 0, ERROR => -1, WARNING => 0)) ; 
        EndOfTestSummary(ReportAll => TRUE);
        std.env.stop;

        -- Randomization of a Set


        wait;
    end process;




end architecture;
