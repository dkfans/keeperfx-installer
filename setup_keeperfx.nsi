; setup_keeperfx.nsi
;
; Script for installation of KeeperFX.

;--------------------------------

  !include "MUI2.nsh"
  !include "nsDialogs.nsh"

;--------------------------------
;Setup program settings

  ;Name and file
  Name "KeeperFX"
  OutFile "keeperfx_setup.exe"
  !define PROGRAM_REGKEY "KeeperFX"

;--------------------------------
;Installation settings

  ;Default installation folder
  InstallDir "$PROGRAMFILES\Open Source\$(programName)"
  InstallDirRegKey HKLM "Software\Open Source\${PROGRAM_REGKEY}" "InstallFilesPath"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;Interface Settings

  !define MUI_ICON ".\graphics\dk-install.ico"
  !define MUI_UNICON ".\graphics\dk-uninstall.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_RIGHT
  !define MUI_HEADERIMAGE_BITMAP ".\graphics\dk_landview_mini.bmp"
  !define MUI_HEADERIMAGE_UNBITMAP ".\graphics\dk_landview_mini.bmp"
  !define MUI_ABORTWARNING

  !define MUI_WELCOMEFINISHPAGE_BITMAP ".\graphics\dk_hornyntrolls_mini.bmp"
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP ".\graphics\dk_hornyntrolls_mini.bmp"

  BrandingText "(c) KeeperFX Team 2008-2012"

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "$(licenseData)"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  ;!insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

  LangString programName ${LANG_ENGLISH} "KeeperFX, free implementation of Dungeon Keeper"

  LangString prepareUninstName ${LANG_ENGLISH} "Preparation of uninstaller"
  LangString commonDataFilesName ${LANG_ENGLISH} "Files crucial for the game execution"
  LangString programUninstallName ${LANG_ENGLISH} "Remove KeeperFX game"
  LangString optionalCampaignsName ${LANG_ENGLISH} "Additional campaigns"
  LicenseLangString licenseData ${LANG_ENGLISH} ".\text\gplv3-en.rtf"

;Language strings - section descriptions
  LangString DESC_conductingTests ${LANG_ENGLISH} "Components required to conduct tests."

;Reserve Files
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
; Initial scripts

  Function .onInit
    InitPluginsDir
  FunctionEnd

  Function un.onInit
  FunctionEnd

;--------------------------------
;Additional setup settings

  SetDateSave on
  SetDatablockOptimize on
  CRCCheck on

;--------------------------------

Section "-$(prepareUninstName)" prepareUninst ; hidden section

  ; write install dir to registry
  WriteRegStr HKLM "Software\Open Source\${PROGRAM_REGKEY}" "InstallFilesPath" "$INSTDIR"

  ; write uninstall strings
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_REGKEY}" "DisplayName" "$(programName)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_REGKEY}" "UninstallString" '"$INSTDIR\uninst-kfx.exe"'

  SetOutPath $INSTDIR
  WriteUninstaller "uninst-kfx.exe"

  CreateDirectory "$SMPROGRAMS\Open Source\$(programName)"
  ;CreateShortCut "$SMPROGRAMS\Open Source\$(programName)\$(programUninstallName).lnk" "$INSTDIR\uninst-kfx.exe"

SectionEnd

Section "un.$(prepareUninstName)"

  DeleteRegKey HKLM "Software\Open Source\${PROGRAM_REGKEY}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_REGKEY}"

  ;Delete "$SMPROGRAMS\Open Source\$(programName)\$(programUninstallName).lnk"
  Delete "$INSTDIR\uninst-kfx.exe"

SectionEnd

;--------------------------------

Section "-$(commonDataFilesName)" commonDataFiles ; hidden section

  SetOverwrite on
  CreateDirectory "$INSTDIR\campgns"
  CreateDirectory "$INSTDIR\creatrs"
  CreateDirectory "$INSTDIR\data"
  CreateDirectory "$INSTDIR\fxdata"
  CreateDirectory "$INSTDIR\ldata"
  CreateDirectory "$INSTDIR\levels"
  CreateDirectory "$INSTDIR\save"
  CreateDirectory "$INSTDIR\scrshots"
  CreateDirectory "$APPDATA\$(programName)"

  SetOutPath "$INSTDIR"
  File "files\MainLib.Dat"

  SetOutPath "$INSTDIR\TestFolder01"
  File "files\TestFolder01\info.txt"

  SetOutPath "$INSTDIR\Testy"
  File "files\Testy\info.txt"

SectionEnd

Section "un.$(commonDataFilesName)"

  Delete "$INSTDIR\MainLib.Dat"

SectionEnd

;--------------------------------

SectionGroup /e "$(conductingTestsName)" conductingTests

Section "$(TestFile01Name)" TestFile01

  SetOutPath "$INSTDIR"
  IfFileExists "$INSTDIR\TestFile01.Dat" AskTestHistoryOverwrite 0
  IfFileExists "$INSTDIR\TestFile03.dat" AskTestHistoryOverwrite 0
  Goto DoTestHistoryOverwrite
  AskTestHistoryOverwrite:
    MessageBox MB_YESNO|MB_ICONQUESTION "TODO?" IDYES DoTestHistoryOverwrite
    SetOverwrite off
  DoTestHistoryOverwrite:
    File "files\TestFile01.Dat"
    File "files\TestFile03.dat"
  SetOverwrite on

  File "files\TestFile01.exe"
  CreateShortCut "$SMPROGRAMS\Open Source\$(programName)\$(TestFile01Name).lnk" "$INSTDIR\TestFile01.exe"

SectionEnd

Section "-$(TestFile02Name)" TestFile02
; DISABLED - probably isn't working

  SetOverwrite on

  SetOutPath "$INSTDIR"
  File "files\TestFile02.exe"
  ;CreateShortCut "$SMPROGRAMS\Open Source\$(programName)\$(TestFile02Name).lnk" "$INSTDIR\TestFile02.exe"

SectionEnd

SectionGroupEnd

;--------------------------------

SectionGroup /e "un.$(conductingTestsName)"

Section "un.$(TestFile01Name)"

  Delete "$SMPROGRAMS\Open Source\$(programName)\$(TestFile01Name).lnk"
  Delete "$INSTDIR\TestFile01.exe"

  IfFileExists "$INSTDIR\TestFolder01\*.ldb" AskHistoryRemove 0
  Goto PartialHistoryRemove
  AskHistoryRemove:
    MessageBox MB_YESNO|MB_ICONQUESTION "TODO?" IDNO NoHistoryRemove
    Delete "$INSTDIR\TestFolder01\*.ldb"
  PartialHistoryRemove:
    Delete "$INSTDIR\TestFile01.Dat"
    Delete "$INSTDIR\TestFile03.dat"
  NoHistoryRemove:

SectionEnd

Section "un.$(TestFile02Name)"

  Delete "$SMPROGRAMS\Open Source\$(programName)\$(TestFile02Name).lnk"
  Delete "$INSTDIR\TestFile02.exe"

SectionEnd

SectionGroupEnd

;--------------------------------

SectionGroup /e "$(preparingTestsName)" preparingTests

Section "$(testWriterName)" testWriter

  SetOverwrite on

  SetOutPath "$INSTDIR"
  File "files\TestWriter.exe"
  CreateShortCut "$SMPROGRAMS\Open Source\$(programName)\$(testWriterName).lnk" "$INSTDIR\keeperfx.exe"

SectionEnd

Section "$(newTestWizName)" newTestWiz

  SetOverwrite on

  SetOutPath "$INSTDIR"
  File "files\NewTestWiz.exe"
  CreateShortCut "$SMPROGRAMS\Open Source\$(programName)\$(newTestWizName).lnk" "$INSTDIR\keeperfx_hvlog.exe"

SectionEnd

Section "$(newQuestnPicName)" newQuestnPic

  SetOverwrite on

  SetOutPath "$INSTDIR\TestFolder02"
  File "files\TestFolder02\TestFile04.jpg"

SectionEnd

SectionGroupEnd

;--------------------------------

SectionGroup /e "un.$(preparingTestsName)"

Section "un.$(testWriterName)"

  Delete "$SMPROGRAMS\Open Source\$(programName)\$(testWriterName).lnk"
  Delete "$INSTDIR\TestWriter.exe"

SectionEnd

Section "un.$(newTestWizName)"

  Delete "$SMPROGRAMS\Open Source\$(programName)\$(newTestWizName).lnk"
  Delete "$INSTDIR\NewTestWiz.exe"

SectionEnd

Section "un.$(newQuestnPicName)"

  Delete "$INSTDIR\TestFolder02\TestFile04.jpg"

SectionEnd

SectionGroupEnd

;--------------------------------

; Uninstaller

Section "un.Uninstall"

  ; Remove folders only if they're empty
  RMDir "$SMPROGRAMS\Open Source\$(programName)"
  RMDir "$SMPROGRAMS\Open Source"

  RMDir "$APPDATA\$(programName)"
  RMDir "$INSTDIR\campgns"
  RMDir "$INSTDIR\creatrs"
  RMDir "$INSTDIR\data"
  RMDir "$INSTDIR\fxdata"
  RMDir "$INSTDIR\ldata"
  RMDir "$INSTDIR\levels"
  RMDir "$INSTDIR\save"
  RMDir "$INSTDIR\scrshots"
  RMDir "$INSTDIR\sound"
  RMDir "$INSTDIR"

SectionEnd

;--------------------------------
;Assign language strings to sections

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${conductingTests} $(DESC_conductingTests)
    !insertmacro MUI_DESCRIPTION_TEXT ${preparingTests} $(DESC_preparingTests)
    !insertmacro MUI_DESCRIPTION_TEXT ${prepareUninst} $(DESC_prepareUninst)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
