-- | #                     | Thủ tục / Hàm (kiểu trả)                         | Nhiệm vụ chính                         | Ghi chú       | nguồn         |
-- | --------------------- | ------------------------------------------------ | -------------------------------------- | ------------- | ------------- |
-- | **KIỂM TRA KÝ TỰ**    |                                                  |                                        |               |               |
-- | 1                     | `IsUpper(c) → boolean`                           | A‑Z?                                   |               | ([GitHub][1]) |
-- | 2                     | `IsLower(c)`                                     | a‑z?                                   |               | ([GitHub][1]) |
-- | 3                     | `IsWhiteSpace(c)`                                | space / tab / CR LF?                   |               | ([GitHub][1]) |
-- | 4                     | `IsHex(c)`                                       | ‘0’–‘9’, ‘A’–‘F’                       |               | ([GitHub][1]) |
-- | 5                     | `IsHexOrStdLogic(c)`                             | Hex **hoặc** UWLH‑                     | 2022.08       | ([GitHub][1]) |
-- | 6                     | `IsNumber(c)`                                    | ký tự số                               |               | ([GitHub][1]) |
-- | 7                     | `IsNumber(str)`                                  | chuỗi **toàn** số?                     |               | ([GitHub][1]) |
-- | 8                     | `isstd_logic(c)`                                 | ‘U’,‘X’,‘0’…                           |               | ([GitHub][1]) |
-- | **CHUYỂN HOA/THƯỜNG** |                                                  |                                        |               |               |
-- | 9                     | `to_lower(c)`                                    | ‘A’→‘a’                                |               | ([GitHub][1]) |
-- | 10                    | `to_lower(str)`                                  | “HeLLo”→“hello”                        |               |               |
-- | 11                    | `to_upper(c)`                                    | ‘a’→‘A’                                |               |               |
-- | 12                    | `to_upper(str)`                                  | “abc”→“ABC”                            |               |               |
-- | **CHUẨN HOÁ CHUỖI**   |                                                  |                                        |               |               |
-- | 13                    | `RemoveSpace(s,len)` (proc)                      | xóa mọi khoảng trắng trong `s(1..len)` | added 2024.09 |               |
-- | 14                    | `RemoveCrLf(s,len)` (proc)                       | xóa CR/LF cuối, trả `len` mới          | 2025.02 fix   |               |
-- | 15                    | `RemoveCrLf(s) → string`                         | hàm tiện; alias `StripCrLf`            |               |               |
-- | **IN HEX/BIN**        |                                                  |                                        |               |               |
-- | 16                    | `to_hxstring(slv)`                               | hex (và bin nếu có meta)               |               |               |
-- | 17                    | `to_hxstring(unsigned)`                          |                                        |               |               |
-- | 18                    | `to_hxstring(signed)`                            |                                        |               |               |
-- | **GIỚI HẠN SỐ**       |                                                  |                                        |               |               |
-- | 19                    | `to_string_max(int)`                             | nếu ±integer'high → “integer'high”     |               |               |
-- | **CĂN LỀ**            |                                                  |                                        |               |               |
-- | 20                    | `AlignType` (RIGHT, LEFT, CENTER)                | enum dùng cho Justify                  |               |               |
-- | 21                    | `Justify(str, amt, align)`                       | căn lề, pad space                      |               |               |
-- | 22                    | `Justify(str, fill, amt, align)`                 | pad ký tự tùy                          |               |               |
-- | **FILE HỮU DỤNG**     |                                                  |                                        |               |               |
-- | 23                    | `FileExists(path) → boolean`                     | file có sẵn?                           | impure        |               |
-- | **ĐỌC DÒNG/TOKEN**    |                                                  |                                        |               |               |
-- | 24                    | `GetLine(fid, buf, lc, eof, ignoreEmpty)`        | đọc, tự bỏ CR/LF                       |               |               |
-- | 25                    | `SkipWhiteSpace(line, Empty)`                    | bỏ trắng đầu                           |               |               |
-- | 26                    | `SkipWhiteSpace(line)`                           | overload không trả `Empty`             |               |               |
-- | 27                    | `IsWhiteSpaceOrEmpty(line,Empty)`                | xét dòng sau skip                      |               |               |
-- | 28                    | `EmptyOrCommentLine(line,Empty,MLC)`             | xử lý `//` và `/*…*/`                  |               |               |
-- | 29                    | `FindDelimiter(line, delim, Found)`              | tìm ký tự ngăn cách                    |               |               |
-- | 30                    | `ReadUntilDelimiterOrEOL(line,name,delim,valid)` | đọc token tự do                        |               |               |
-- | 31                    | `ReadHexToken(line, slv, strlen)`                | đọc HEX (không skip ws)                |               |               |
-- | 32                    | `ReadBinaryToken(line, slv, strlen)`             | đọc BIN (không skip ws)                |               |               |


-- | Bài                                   | Nội dung & API phải dùng                                                                                                                           | PASS khi                                        |
-- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
-- | **1. Phân loại ký tự**                | Quét chuỗi `"Aa0X?x "`; dùng **IsUpper/Lower/Hex/StdLogic/WhiteSpace/Number** để in nhóm, `AffirmIf` tổng đúng.                                     | Alert ERROR = 0                                 |
-- | **2. Chuyển hoa‑thường**              | Dùng **to\_lower / to\_upper (char+str)** tạo bảng tra.                                                                                            | “AbZ”→“abz”, “hello”→“HELLO”.                   |
-- | **3. RemoveSpace / RemoveCrLf**       | Đọc `" ab c "` → `RemoveSpace`, len=3; chuỗi `"Text\r\n"` → `RemoveCrLf`.                                                                          | Kết quả “abc”, “Text”.                          |
-- | **4. Justify demo**                   | In bảng 3 cột: LEFT, RIGHT, CENTER (width 10) bằng **Justify**.                                                                                    | Căn lề chuẩn (mắt nhìn).                        |
-- | **5. FileExists & GetLine**           | Nếu `vector.hex` tồn tại, mở, dùng **GetLine** đọc từng dòng; đếm dòng.                                                                            | Affirm > 0; nếu không tồn tại Alert(WARN).      |
-- | **6. Skip/Empty/Comment parse**       | Tạo file chứa dòng trắng + `// cmt` + `/* multi */`; sử dụng **SkipWhiteSpace, EmptyOrCommentLine, IsWhiteSpaceOrEmpty** để chỉ giữ dòng code.     | Đếm code = 2.                                   |
-- | **7. FindDelimiter & ReadUntil**      | Với dòng `"item1,item2;rest"` tìm `,` rồi đọc token tới `,` / `;`.                                                                                 | Thu được “item1”, “item2”.                      |
-- | **8. ReadHexToken / ReadBinaryToken** | File `tokens.txt`: `DEAD BEEF 1010 1100`; đọc 2 HEX (slv32), 2 BIN (slv8).                                                                         | slv = x"DEAD", x"BEEF", "10100000", "11000000". |
-- | **9. to\_hxstring + to\_string\_max** | a) In `std_logic_vector'("UU11XX00")` bằng **to\_hxstring** (kèm nhị phân meta).<br>b) Với `integer'high`, **to\_string\_max** không in số cụ thể. | Chuỗi có “integer'high”.                        |
-- | **10. Tích hợp mini‑lexer**           | Viết thủ tục `NextToken` sử dụng **FindDelimiter, SkipWhiteSpace, IsNumber/IsHexOrStdLogic, ReadHexToken** để tách dòng `COUNT = 8'hFF;`.          | Xuất 4 token (`IDENT`, `=`, `HEX`, `;`).        |


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

use std.textio.all;

entity Test35 is
end entity;

architecture tb of Test35 is

    constant TB_ID : AlertLogIDType := NewID("Test35");
    signal string_in : string(1 to 7) := "Aa0X?x ";
    signal string_out : string(1 to 7);

begin

    test_proc : process
        variable cnt_upper      : integer := 0;
        variable cnt_lower      : integer := 0;
        variable cnt_hex        : integer := 0;
        variable cnt_std_logic  : integer := 0;
        variable cnt_white_space : integer := 0;
        variable cnt_number     : integer := 0;
    begin
        SetTestName("Test35");
        SetLogEnable(TB_ID, INFO, TRUE);
        SetLogEnable(TB_ID, PASSED, TRUE);
        TranscriptOpen("check_character.txt");
        SetTranscriptMirror(TRUE);

        wait for 0 ns; wait for 0 ns;
        -- IsUpper
        for i in 1 to string_in'length loop
            if IsUpper(string_in(i)) then
                cnt_upper := cnt_upper + 1;
            end if;
        end loop;
        Print("Kiem tra ky tu in hoa" );
        Log(TB_ID, "So ky tu in hoa: " & to_string(cnt_upper));

        -- IsLower
        wait for 100 ns;
        TranscriptClose;
        std.env.stop;

    end process;
    
    
end architecture;



