!include "x64.nsh"
!include "FileFunc.nsh"
!include "WordFunc.nsh"
!include "FileTimeDiff.nsh"

Icon "CWBlogo.ico"
!define PRODUCT_DIR_REGKEY "Software\cwbearthquake"

Section "MainSection" SEC01
  SetAutoClose true
  ${DisableX64FSRedirection}
  ReadRegStr $INSTDIR HKLM "${PRODUCT_DIR_REGKEY}" ""
  ReadRegStr $0 HKLM "${PRODUCT_DIR_REGKEY}" "InputDir"
  ${Locate} $0 "/L=F /G=0" "main"
SectionEnd

Function main
  ; get host name and file name
  ${WordFindS} $R7 "." "+1{" $R0
  ${WordFindS} $R7 "." "+1}" $R1
  
  FileOpen $1 "$INSTDIR\eventlog\$R1+$R0.log" a
  FileSeek $1 0 END
  ${GetTime} "" "L" $4 $5 $6 $3 $7 $8 $9
  FileWrite $1 "$6-$5-$4 $7:$8:$9, received$\r$\n"
  
  IfFileExists "$INSTDIR\dataPool\$R1" hasfile
  
  do:
    Rename "$R9" "$INSTDIR\dataPool\$R1"
    ${GetTime} "" "L" $4 $5 $6 $3 $7 $8 $9
    FileWrite $1 "$6-$5-$4 $7:$8:$9, move to dataPool$\r$\n"
    
    Exec "$INSTDIR\earthquake.bat $\"$INSTDIR\dataPool\$R1$\""
    ${GetTime} "" "L" $4 $5 $6 $3 $7 $8 $9
    FileWrite $1 "$6-$5-$4 $7:$8:$9, exec earthquake.bat$\r$\n$\r$\n"
    
    Goto done
    
  hasfile:
    ; test if file duplicated
    md5dll::GetMD5File $R9
    Pop $2
    md5dll::GetMD5File "$INSTDIR\dataPool\$R1"
    Pop $3
    StrCmp $2 $3 duplicate
    
    ; test if file expired
    ${FileTimeDiff} $2 $R9 "$INSTDIR\dataPool\$R1"
    IntCmp $2 0 +1 expire
    
    Delete "$INSTDIR\dataPool\$R1"
    Goto do
    
  duplicate:
    Delete $R9
    ${GetTime} "" "L" $4 $5 $6 $3 $7 $8 $9
    FileWrite $1 "$6-$5-$4 $7:$8:$9, Duplicated$\r$\n$\r$\n"
    Goto done
    
  expire:
    Delete $R9
    ${GetTime} "" "L" $4 $5 $6 $3 $7 $8 $9
    FileWrite $1 "$6-$5-$4 $7:$8:$9, Expired$\r$\n$\r$\n"
    
  done:
  
  FileClose $1
  Push $0
FunctionEnd
