library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

library osvvm ;
context osvvm.OsvvmContext ;           -- nạp AlertLogPkg, CoveragePkg, RandomPkg

entity tb_eth_cov is
end entity ;

architecture sim of tb_eth_cov is
  --------------------------------------------------------------------
  -- Tham số, hằng
  --------------------------------------------------------------------
  constant CRC_FAIL_RATIO : real := 0.10;
  constant LEN1_MIN : integer :=   64;  constant LEN1_MAX : integer :=  127;
  constant LEN2_MIN : integer :=  128;  constant LEN2_MAX : integer :=  511;
  constant LEN3_MIN : integer :=  512;  constant LEN3_MAX : integer := 1023;
  constant LEN4_MIN : integer := 1024;  constant LEN4_MAX : integer := 1518;

  --------------------------------------------------------------------
  -- Coverage objects
  --------------------------------------------------------------------
  signal LenCov, CrcCov, CrossCov : CoverageIDType;

  --------------------------------------------------------------------
  -- Random generator  (RandomPkg ≥ 2024.x)
  --------------------------------------------------------------------
  shared variable R : RandomPType;     -- khởi tạo bằng InitSeed trong process

  --------------------------------------------------------------------
  -- =======  FUNCTIONS / PROCEDURES  =======
  --------------------------------------------------------------------
  function RandRange(Min, Max : integer) return integer is
  begin
    return Min + integer(R.RandInt(0, Max - Min));
  end function;

  procedure GenPkt_IC(signal LenID : in CoverageIDType;
                      out Len : integer;
                      out CrcBad : integer) is
  begin
    Len := GetRandBinVal(LenID);                       -- nhắm bin thiếu
    CrcBad := (if R.RandBit(CRC_FAIL_RATIO) = '1' then 1 else 0);
  end procedure;

  procedure GenPkt_Uniform(out Len : integer; out CrcBad : integer) is
  begin
    Len := RandRange(LEN1_MIN, LEN4_MAX);
    CrcBad := (if R.RandBit(CRC_FAIL_RATIO) = '1' then 1 else 0);
  end procedure;

  procedure CoverPkt(signal LenID, CrcID, XID : in CoverageIDType;
                     Len : integer; CrcBad : integer) is
  begin
    ICover(LenID, Len);
    ICover(CrcID, CrcBad);
    ICover(XID, (Len, CrcBad));
  end procedure;
begin
  --------------------------------------------------------------------
  -- INIT  – khởi tạo Random seed + mô hình coverage
  --------------------------------------------------------------------
  init_proc : process
  begin
    R.InitSeed(42);                                 -- SEED cố định

    LenCov   <= NewID("LenClass");
    CrcCov   <= NewID("CrcPassFail");
    CrossCov <= NewID("Len×CRC");
    wait for 0 ns;

    -- Length bins – goal 10 mỗi lớp
    AddBins(LenCov, AtLeast=>10, GenBin(LEN1_MIN, LEN1_MAX));
    AddBins(LenCov, AtLeast=>10, GenBin(LEN2_MIN, LEN2_MAX));
    AddBins(LenCov, AtLeast=>10, GenBin(LEN3_MIN, LEN3_MAX));
    AddBins(LenCov, AtLeast=>10, GenBin(LEN4_MIN, LEN4_MAX));

    -- CRC bins 90/10
    AddBins(CrcCov, AtLeast=>90, GenBin(0));  -- CRC_OK
    AddBins(CrcCov, AtLeast=>10, GenBin(1));  -- CRC_BAD

    AddCross(CrossCov, LenCov, CrcCov);

    wait;                                     -- INIT sống suốt sim
  end process;

  --------------------------------------------------------------------
  -- MAIN TESTBENCH
  --------------------------------------------------------------------
  main : process
    variable len        : integer;
    variable bad        : integer;
    variable pkt_uniform: integer := 0;
    variable pkt_ic     : integer := 0;
  begin
    ----------------------------------------------------------------
    -- 1) UNIFORM
    ----------------------------------------------------------------
    loop
      GenPkt_Uniform(len, bad);
      CoverPkt(LenCov, CrcCov, CrossCov, len, bad);
      pkt_uniform := pkt_uniform + 1;
      exit when IsCovered(CrossCov);
    end loop;
    Log(NewID("UNIFORM"), "Uniform pkts = " & integer'image(pkt_uniform), FINAL);

    ----------------------------------------------------------------
    -- 2) RESET để chạy Intelligent Coverage
    ----------------------------------------------------------------
    LenCov   <= NewID("LenClass_IC");
    CrcCov   <= NewID("CrcPassFail_IC");
    CrossCov <= NewID("Len×CRC_IC");
    wait for 0 ns;

    AddBins(LenCov, AtLeast=>10, GenBin(LEN1_MIN, LEN1_MAX));
    AddBins(LenCov, AtLeast=>10, GenBin(LEN2_MIN, LEN2_MAX));
    AddBins(LenCov, AtLeast=>10, GenBin(LEN3_MIN, LEN3_MAX));
    AddBins(LenCov, AtLeast=>10, GenBin(LEN4_MIN, LEN4_MAX));

    AddBins(CrcCov, AtLeast=>90, GenBin(0));
    AddBins(CrcCov, AtLeast=>10, GenBin(1));

    AddCross(CrossCov, LenCov, CrcCov);

    SetWeightMode(LenCov, WEIGHT_REMAINING);
    SetWeightMode(CrcCov, WEIGHT_REMAINING);

    ----------------------------------------------------------------
    -- 3) INTELLIGENT COVERAGE LOOP
    ----------------------------------------------------------------
    loop
      GenPkt_IC(LenCov, len, bad);
      CoverPkt(LenCov, CrcCov, CrossCov, len, bad);
      pkt_ic := pkt_ic + 1;
      exit when IsCovered(CrossCov);
    end loop;

    Log(NewID("IC"), "Intelligent pkts = " & integer'image(pkt_ic), FINAL);
    Log(NewID("IC"), "Speed‑up = " &
        real'image(real(pkt_uniform)/pkt_ic), FINAL);

    ----------------------------------------------------------------
    -- 4) Báo cáo
    ----------------------------------------------------------------
    WriteBin(CrossCov);
    WriteCovHoles(CrossCov);
    ReportAlerts;
    std.env.stop;
  end process;
end architecture ;
