library osvvm ; 
context osvvm.OsvvmContext ; 
use osvvm.ScoreboardPkg_int.all ; 

entity TbSB_GetAffirmCount_1 is 
end TbSB_GetAffirmCount_1 ;

architecture GetAffirmCount_1 of TbSB_GetAffirmCount_1 is 

begin

  ControlProc : process
    variable SB : ScoreboardIdType ; 
  begin
    SetTestName("TbSB_GetAffirmCount_1") ; 
    SetLogEnable(PASSED, TRUE) ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ; 
    SB := NewID("SB"); 
    push(SB, 5) ; 
    check(SB, 5) ; 
    log("GetAffirmCount = " & to_string(GetAffirmCount)) ; 
    AffirmIf(GetAffirmCount > 0, "GetAffirmCount = " & to_string(GetAffirmCount));
    
    TranscriptClose ; 
    
--    AffirmIfTranscriptsMatch(VALIDATED_RESULTS_DIR) ; 

    EndOfTestSummary(ReportAll => TRUE) ; 
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

end GetAffirmCount_1 ; 