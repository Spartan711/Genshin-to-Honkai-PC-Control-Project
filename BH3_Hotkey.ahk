﻿;---------------------------------------------------------------------------------------------------------------------------------------------------------------
;Version 0.1.0
;---------------------------------------------------------------------------------------------------------------------------------------------------------------

Disable( ) ; 该段用于设置界面状态栏，请勿删改
{
    WinGet, id, ID, A
    menu := DLLCall( "user32\GetSystemMenu", "UInt", id, "UInt", 0)
    DLLCall( "user32\DeleteMenu", "UInt", menu, "UInt", 0xF060, "UInt", 0x0)
    WinGetPos ,x, y, w, h, ahk_id %id%
    WinMove, ahk_id %id%,, %x%, %y%, %w%, % h-1
    WinMove, ahk_id %id%,, %x%, %y%, %w%, % h+1
}

Gui, Start: Font, s12, 新宋体
Gui, Start: Margin , X, Y
Gui, Start: + Theme
Gui, Start: Add, Text, x+3, ; 集体缩进
Gui, Start: Add, Text,, F1:                     暂停/启用
Gui, Start: Add, Text,, F3:                     查看说明
Gui, Start: Add, Text,, 左Alt+左键:             正常左键
Gui, Start: Add, Text,, 左Shift/右键:           闪避/冲刺
Gui, Start: Add, Text,, Z:                      人偶技
Gui, Start: Add, Text,, Q:                      必杀技
Gui, Start: Add, Text,, E:                      武器技/后崩必杀技
Gui, Start: Add, Text,, 方向键:                 准心控制
Gui, Start: Add, Text,, 中键:                   视角跟随
Gui, Start: Add, Text,, 左键:                   普攻/吼姆跳
Gui, Start: Add, Link,, 源码查看:               <a href="https://github.com/Spartan711/Genshin-to-Honkai-PC-Control-Project/blob/main/BH3_Hotkey.ahk">传送门</a>
Gui, Start: Add, Text,,
Gui, Start: Add, Button, xn w333, 开启
Gui, Start: Show, xCenter yCenter, 设置说明
Disable( )
Suspend, On
Return

StartButton开启:
Suspend, Off
Gui, Start: Destroy
SetTimer, AutoFadeMsgbox, -1200
MsgBox, 0, 提示, 程序已开始运行（在游戏内按F1以停用）
SetTimer, AutoFadeMsgbox, Off
Return

AutoFadeMsgbox:
DLLCall( "AnimateWindow", UInt, WinExist( "提示 ahk_class #32770"), Int, 500, UInt, 0x90000)
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

#IfWinActive ahk_class UnityWndClass ; 【宏条件】检测3D游戏窗口，使程序仅在游戏运行时生效

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

SwitchIME(dwLayout) ; 该段用于管理输入法，请勿删改
{
    HKL := DllCall( "LoadKeyboardLayout", Str, dwLayout, UInt, 1)
    ControlGetFocus, ctl, A
    SendMessage, 0x50, 0, HKL, %ctl%, A
}

F1:: ; 暂停/ 启用程序——若想正常使用鼠标请按该键或按住ALT键
Suspend, Toggle    
WinSet, AlwaysOnTop, Off, A
Send, {Click, Up}{Click, Up Middle}
SwitchIME(0x04090409) ; 切换至"中文(中国) 简体中文-美式键盘"
;Send, #{space} ; [未启用命令行] 微软拼音用户可用该命令
if (A_IsSuspended=1)
    ToolTip, 暂停中, 0, 999 ; 可调校数值
else if (A_IsSuspended=0)
{
    ToolTip, 已启用, 0, 999 ; 可调校数值
    Sleep 210 ; 可调校数值
    ToolTip
}
Return

F3:: ; 重启程序以呼出操作说明界面
Suspend, Off
Reload 
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

*!LButton::LButton ; 按住ALT以正常使用鼠标左键

RButton:: ; 点按鼠标右键以发动闪避/冲刺
SendEvent, {k Down}
KeyWait, RButton
SendEvent, {k Up}
Return

LShift:: ; 按下键盘左侧Shift键以发动闪避/冲刺
SendEvent, {k Down}
KeyWait, LShift
SendEvent, {k Up}
Return

e:: ; 按下键盘E键以发动武器技/ 后崩坏书必杀技，长按E键进入瞄准模式时可通过键盘右侧方向键操控准心
GetKeyState, State, e, P
Send, {u Down}
KeyWait, e
if (State=1)
{
    up::w
    return
}
if (State=1)
{
    down::s
    return
}
if (State=1)
{
    left::a
    return
}
if (State=1)
{
    right::d
    return
}
Send, {u Up}
SendEvent, MButton
Return

q::i ; 按下键盘Q键以发动必杀技（若设置视角跟随会唤醒U键，目前尝试各种block禁用指令无果）

z::l ; 按下键盘Z键以发动人偶技

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

MButton:: ; 点击鼠标中键以激活视角跟随
SendInput, {Click, Up Middle}
Return

MButton Up:: 
SendInput, {Click, Down}
Return

LButton:: ; 点按鼠标左键以发动普攻
Send, {j Down}
KeyWait, LButton
Send, {j Up}
SendInput, {Click, Up Middle}
Loop := True
SetTimer, ViewControl, -99 ; [可调校数值] 设定视角跟随命令的每执行间隔时间(ms)
Return

ViewControl:
if WinActive("ahk_class UnityWndClass")
{
    SendInput, {Click, Down Middle}
    CoordMode, Window
    WinGetPos, X, Y, Width, Height, ahk_class UnityWndClass
    MouseMove, Width/2, Height/2, 0 ; [建议保持数值]
}
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------
;目前就这些，可根据需要自行修改
;---------------------------------------------------------------------------------------------------------------------------------------------------------------