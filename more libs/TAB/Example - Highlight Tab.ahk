/*
    For the Tab and Tab2 controls that do not use the desktop theme (the
    default), the selected tab can sometimes be difficult to distinguish from
    the other tabs.  In this example, the TAB_HighlightItem function is used to
    highlight the selected tab.  A hightlighed tab is very easy to identify
    because it is a different color than the other tabs.
*/
#NoEnv
#SingleInstance Force
ListLines Off

;-- Tab control styles
TCS_RIGHTJUSTIFY      :=0x0
TCS_SINGLELINE        :=0x0
TCS_EX_FLATSEPARATORS :=0x1
TCS_SCROLLOPPOSITE    :=0x1
TCS_RIGHT             :=0x2
TCS_BOTTOM            :=0x2
TCS_MULTISELECT       :=0x4
TCS_FLATBUTTONS       :=0x8
TCS_FORCEICONLEFT     :=0x10
TCS_FORCELABELLEFT    :=0x20
TCS_HOTTRACK          :=0x40
TCS_VERTICAL          :=0x80
TCS_BUTTONS           :=0x100
TCS_MULTILINE         :=0x200
TCS_FIXEDWIDTH        :=0x400
TCS_RAGGEDRIGHT       :=0x800
TCS_FOCUSONBUTTONDOWN :=0x1000
TCS_OWNERDRAWFIXED    :=0x2000
TCS_TOOLTIPS          :=0x4000
TCS_FOCUSNEVER        :=0x8000

;-- Initialize
MarginX :=10
MarginY :=10

;-- Create GUI
gui -DPIScale
gui Margin,%MarginX%,%MarginY%

;-- Add the tab control
TabStyle :=0
gui Add,Tab2,xm w300 h250 %TabStyle% hWndhTab gSelectedTab vMyTab,A-C|D-F|G-J|K-M|N-Q|R-T|U-Z
gui Font

;-- Increase the height of the tabs so that the tabs are a bit more
;   prominent.
hFont :=Fnt_GetFont(hTab)
TAB_SetItemSize(hTab,1,Fnt_GetFontHeight(hFont)+10)

;-- Reset the tab control
;   This will force the tab control to reposition.  Note: This is not necessary
;   for the Tab and Tab2 controls but it remains for completeness.
GUIControl,,%hTab%

;-- Get the display area
TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)

;-- Adjust for margins
EditX :=DisplayAreaX+MarginX
EditY :=DisplayAreaY+MarginY
EditW :=DisplayAreaW-(MarginX*2)
EditH :=DisplayAreaH-(MarginY*2)

;-- Populate the tabs
gui Tab,A-C
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH% vMyEditAC,
   (ltrim
    1205`tAdam Sandler
    6791`tAl Pacino
    7852`tAngelina Jolie
    5532`tAnne Hathaway
    3600`tArnold Schwarzenegger
    4815`tBen Affleck
    7506`tBill Murray
    4691`tBrad Pitt
    9208`tBradley Cooper
    6440`tBruce Willis
    6294`tCameron Diaz
    9654`tChanning Tatum
    4115`tCharles Chaplin
    7713`tChris Hemsworth
    4414`tClint Eastwood
   )

;-- Collect the text from the first Edit control and then empty the control
;   This text is used later to populate the control after the screen is showing.
GUIControlGet MyEditAC,,MyEditAC
GUIControl,,MyEditAC

gui Tab,D-F
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    9024`tDaniel Craig
    4349`tDaniel Radcliffe
    5398`tDwayne Johnson
    6156`tEdward Norton
    2138`tEmma Stone
    5795`tEmma Watson
   )

gui Tab,G-J
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    3558`tGeorge Clooney
    4425`tHalle Berry
    4413`tHarrison Ford
    4566`tHugh Jackman
    4332`tIan McKellen
    7349`tJack Nicholson
    7772`tJackie Chan
    1785`tJake Gyllenhaal
    7314`tJames Cameron
    9799`tJames McAvoy
    1827`tJennifer Aniston
    6004`tJessica Alba
    7009`tJim Carrey
    8804`tJohnny Depp
    3266`tJulia Roberts
   )

gui Tab,K-M
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    1107`tKate Beckinsale
    5952`tKate Winslet
    3344`tKeanu Reeves
    8697`tKeira Knightley
    8436`tLeonardo DiCaprio
    7299`tLiam Neeson
    2940`tMacaulay Culkin
    1018`tMark Wahlberg
    7715`tMarlon Brando
    8379`tMatt Damon
    1147`tMegan Fox
    2412`tMel Gibson
    4666`tMorgan Freeman
   )

gui Tab,N-Q
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    7708`tNatalie Portman
    6901`tNicolas Cage
    3068`tOrlando Bloom
    5592`tOwen Wilson
    1728`tPeter Jackson
    8429`tPierce Brosnan
    3836`tSandra Bullock
   )

gui Tab,R-T
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    7643`tRachel McAdams
    9188`tRobert De Niro
    5758`tRobert Downey Jr.
    1048`tRowan Atkinson
    2732`tRussell Crowe
    3346`tSamuel L. Jackson
    5501`tScarlett Johansson
    4337`tSean Connery
    3101`tSigourney Weaver
    9449`tSteven Spielberg
    3972`tSylvester Stallone
    2309`tTim Allen
    2148`tTom Cruise
    3583`tTom Hanks
   )

gui Tab,U-Z
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    2395`tVin Diesel
    2777`tWill Ferrell
    4585`tWill Smith
    3176`tZach Galifianakis
   )

;-- End of tabs
gui Tab

;-- Misc. controls
gui Add,Button,xm vReload gReload,%A_Space%Reload...%A_Space%
gui Add,StatusBar

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,AutoSize,%$ScriptName%
gosub UpdateSB

;-- Reload the first Edit control
;   This keeps the control from selecting all text
GUIControl,,MyEditAC,%MyEditAC%

;-- Highlight the first tab
iTab_Selected:=TAB_GetCurSel(hTab)
TAB_HighlightItem(hTab,iTab_Selected)
iTab_LastSelected :=iTab_Selected
return


SelectedTab:
gui Submit,NoHide

;-- Reset and highlight the necessary tabs
if iTab_LastSelected
    TAB_HighlightItem(hTab,iTab_LastSelected,False)

iTab_Selected:=TAB_GetCurSel(hTab)
TAB_HighlightItem(hTab,iTab_Selected)
iTab_LastSelected :=iTab_Selected

gosub UpdateSB
return


GUIEscape:
GUIClose:
ExitApp


Reload:
Reload
return


UpdateSB:
SelectedTab :=TAB_GetCurSel(hTab)
SBText :=""
    . "There are " . TAB_GetItemCount(hTab) . " tabs. "
    . (SelectedTab ? "Tab """ . TAB_GetText(hTab,SelectedTab) . """ is selected.":"No tab is selected.")

SB_SetText(SBText)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%/_Functions
#include TAB.ahk

#include Fnt.ahk
