library ieee ;
use ieee.std_logic_1164.all ;

library osvvm ;
context osvvm.OsvvmContext ;
use osvvm.ScoreboardPkg_slv.all;

use work.Pkt_Types_Pkg.all ;
use work.Pkg_IDs.all ;

entity tb_mux is end ;

architecture sim of tb_mux is

    component stim_gen is
        port 
        (
        
            dest_out    : out std_logic_vector(1 downto 0);
            data_out    : out data_t
        );
    end component;

    component monitor is
        generic
        (
            SB_ID : ScoreboardIdType
        );
        port 
        (
        
            data_in     : in data_t
        );
    end component;

    component mux_router_stub is
        port 
        (
            dest_in     : in std_logic_vector(1 downto 0);
            data_in     : in data_t;
    
            out0_data   : out data_t;
            out1_data   : out data_t;
            out2_data   : out data_t;
            out3_data   : out data_t
        );
    end component;

  -- Signals
  signal dest_s  : std_logic_vector(1 downto 0);
  signal data_s  : data_t;

  signal o0, o1, o2, o3 : data_t;

begin
  ------------------------------------------------------------------
  -- Stimulus
  stim: stim_gen
    port map 
        (
            dest_out    => dest_s, 
            data_out    => data_s
        );

  ------------------------------------------------------------------
  -- DUT stub
  dut : mux_router_stub
    port map 
        (
            dest_in     => dest_s,
            data_in     => data_s,
            out0_data   => o0,
            out1_data   => o1,
            out2_data   => o2,
            out3_data   => o3
      );

  ------------------------------------------------------------------
  -- Monitors
  mon0 : monitor 
    generic map 
        (
            SB_ID       => SB0_ID
        ) 
    port map 
        (
            data_in     => o0
        );
  mon1 : monitor 
    generic map 
        (
            SB_ID       => SB1_ID
        ) 
    port map 
        (
            data_in     => o1
        );
  mon2 : monitor 
    generic map 
        (
            SB_ID        => SB2_ID
        ) 
    port map 
        (
            data_in     => o2
        );
  mon3 : monitor 
    generic map 
        (
            SB_ID       => SB3_ID
        ) 
    port map 
        (
            data_in     => o3
        );

  ------------------------------------------------------------------
  -- End‑of‑test after last packet
  finish : process
  begin
    SetLogEnable(INFO, TRUE);
    SetLogEnable(PASSED, TRUE);
    wait for 10 ns;
    wait for N_PKTS * 20 ns + 50 ns;

    wait for 10 ns;

    AffirmIf(AllScoreboardsEmpty, "All SB empty", INFO);
    EndOfTestSummary(ReportAll => TRUE);

    std.env.stop;
  end process ;
end architecture ;
