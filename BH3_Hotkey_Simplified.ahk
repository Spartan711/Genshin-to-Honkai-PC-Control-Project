;---------------------------------------------------------------------------------------------------------------------------------------------------------------
;Version 0.1.0
;---------------------------------------------------------------------------------------------------------------------------------------------------------------

;【函数】该段用于设置界面状态栏，请勿删改
Disable( )
{
    WinGet, id, ID, A
    menu := DLLCall( "user32\GetSystemMenu", "UInt", id, "UInt", 0)
    DLLCall( "user32\DeleteMenu", "UInt", menu, "UInt", 0xF060, "UInt", 0x0)
    WinGetPos ,x, y, w, h, ahk_id %id%
    WinMove, ahk_id %id%,, %x%, %y%, %w%, % h-1
    WinMove, ahk_id %id%,, %x%, %y%, %w%, % h+1
}

;【GUI】说明界面
Gui, Start: Font, s12, 新宋体
Gui, Start: Margin , X, Y
Gui, Start: + Theme
Gui, Start: Add, Text, x+3, ; 集体缩进
Gui, Start: Add, Text,, F1:                     暂停/启用
Gui, Start: Add, Text,, F3:                     查看说明
Gui, Start: Add, Text,, 左Alt+左键:             正常左键
Gui, Start: Add, Text,, 左键:                   普攻/吼姆跳
Gui, Start: Add, Text,, 中键:                   管理视角跟随
Gui, Start: Add, Text,, 鼠标:                   视角控制
Gui, Start: Add, Link,, 源码查看:               <a href="https://github.com/Spartan711/Genshin-to-Honkai-PC-Control-Project/blob/main/BH3_Hotkey.ahk">传送门</a>
Gui, Start: Add, Text,, 
Gui, Start: Add, Text,, 其它键位请在游戏设置界面内自行更改
Gui, Start: Add, Text,, 
Gui, Start: Add, Button, xn w333, 开启
Gui, Start: Show, xCenter yCenter, 设置说明
Disable( )
Suspend, On
Return

;【标签】“开启”按钮的执行语句，注意其特殊的命名格式
StartButton开启:
MsgBox, 4,, 是否以管理员身份运行该程序？
IfMsgBox, Yes
{
    RegWrite, REG_SZ, HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers,%A_AhkPath%, ~ RUNASADMIN
    RegWrite, REG_SZ, HKCR\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers,%A_AhkPath%, ~ RUNASADMIN
} 
Else
{
    RegDelete, HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers,%A_AhkPath%, ~ RUNASADMIN
    RegDelete, HKCR\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers,%A_AhkPath%, ~ RUNASADMIN
}
Suspend, Off
Gui, Start: Destroy
SetTimer, AutoFadeMsgbox, -3000 ; [可调校数值] 使消息弹窗仅存在一段时间(ms)
MsgBox, 0, 提示, 程序进入运行状态,可在游戏内按F1键停用`n（PS：当前对话框将于3秒后自动消失）
SetTimer, AutoFadeMsgbox, Off
Return

;【标签】让对话框自动消失
AutoFadeMsgbox:
DLLCall( "AnimateWindow", UInt, WinExist( "提示 ahk_class #32770"), Int, 500, UInt, 0x90000)
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

;【宏条件】检测崩坏3游戏窗口，使程序仅在崩坏3游戏运行时生效
#IfWinActive ahk_exe BH3.exe

;【常量】对管理鼠标控制功能的全局常量进行赋值
Global Toggle_MouseFunction := 0

;【常量】对管理视角跟随功能的全局常量进行赋值
Global Status_MButton := 0

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

;【函数】该段用于管理输入法，请勿删改
SwitchIME(dwLayout)
{
    HKL := DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
    ControlGetFocus, ctl, A
    SendMessage, 0x50, 0, HKL, %ctl%, A
}

;【热键】暂停/启用程序——若想正常使用鼠标请按该键或按住ALT键
F1::
Suspend, Toggle
WinSet, AlwaysOnTop, Off, A
If (Toggle_MouseFunction)
{
    Toggle_MouseFunction := !Toggle_MouseFunction
    SetTimer, ViewControl, Off
    InputReset()
}
SwitchIME(0x04090409) ; 切换至"中文(中国) 简体中文-美式键盘"
;SendInput, #{Space} ; [未启用命令行] 微软拼音用户可用该命令
If (A_IsSuspended)
    ToolTip, 暂停中, 0, 999 ; [可调校数值]
Else
{
    ToolTip, 已启用, 0, 999 ; [可调校数值]
    Sleep 210 ; [可调校数值]
    ToolTip
}
Return

;【热键】重启程序以呼出操作说明界面
F3::
Suspend, Off
If (Toggle_MouseFunction)
{
    Toggle_MouseFunction := !Toggle_MouseFunction
    SetTimer, ViewControl, Off
    InputReset()
}
Reload 
Return

;【热键】对Win+Tab快捷键的支持命令
#Tab::
If (!A_IsSuspended)
{
    Suspend, On
    WinSet, AlwaysOnTop, Off, A
    If (Toggle_MouseFunction)
    {
        Toggle_MouseFunction := !Toggle_MouseFunction
        SetTimer, ViewControl, Off
        InputReset()
    }
    SwitchIME(0x04090409) ; 切换至"中文(中国) 简体中文-美式键盘"
    ;SendInput, #{Space} ; [未启用命令行] 微软拼音用户可用该命令
    If (A_IsSuspended)
        ToolTip, 暂停中, 0, 999 ; [可调校数值]
    Sleep 99 ; [可调校数值]
}
SendInput, #{Tab}
Return

;【热键】对Alt+Tab快捷键的支持命令
LAltTab()
{
    If GetKeyState("Tab", "P")
    {
        If (!A_IsSuspended)
        {
            Suspend, On
            WinSet, AlwaysOnTop, Off, A
            If (Toggle_MouseFunction)
            {
                Toggle_MouseFunction := !Toggle_MouseFunction
                SetTimer, ViewControl, Off
                InputReset()
            }
            SwitchIME(0x04090409) ; 切换至"中文(中国) 简体中文-美式键盘"
            ;SendInput, #{Space} ; [未启用命令行] 微软拼音用户可用该命令
            If (A_IsSuspended)
                ToolTip, 暂停中, 0, 999 ; [可调校数值]
            Sleep 99 ; [可调校数值]
        }
        SendInput, !{Tab}
    }
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

;【函数】重置光标
CoordReset()
{
    If WinActive("ahk_exe BH3.exe")
    {
        CoordMode, Window
        WinGetPos, X, Y, Width, Height, ahk_exe BH3.exe ; 获取崩坏3游戏窗口参数（同样适用于非全屏）
        MouseMove, Width/2, Height/2, 0 ; [建议保持数值] 使鼠标回正，居中于窗口
    }
}

;【函数】视角跟随
ViewControl()
{
    If WinActive("ahk_exe BH3.exe")
    {
        MouseGetPos, x1, y1
        Sleep, 10 ; [可调校数值] 设定采集当前光标坐标值的时间间隔(ms)
        MouseGetPos, x2, y2
        If (x1 != x2 or y1 != y2)
        {
            If (!Status_MButton)
            {
                Status_MButton := !Status_MButton
                SendInput, {Click, Down Middle}
            }
        }
        Else
        {
            If (Status_MButton)
            {
                SendInput, {Click, Up Middle}
                Status_MButton := !Status_MButton
            }
        }
    }
}

;【函数】临时视角跟随
ViewControlTemp()
{
    If WinActive("ahk_exe BH3.exe")
    {
        Threshold := 33 ; [可调校数值] 设定切换两种视角跟随模式的像素阈值
        MouseGetPos, x1, y1
        Sleep, 1 ; [可调校数值] 设定采集当前光标坐标值的时间间隔(ms)
        MouseGetPos, x2, y2
        If (abs(x1 - x2) > Threshold or abs(y1 - y2) > Threshold)
        {
            If (!Status_MButton)
            {
                Status_MButton := !Status_MButton
                SendInput, {Click, Down Middle}
            }
        }
        Else If (y1 > y2)
        {
            SendInput, {n Down}
            Sleep, 1
            SendInput, {n Up}
        }
        Else If (y1 < y2)
        {
            SendInput, {m Down}
            Sleep, 1
            SendInput, {m Up}
        }
        Else If (x1 > x2)
        {
            SendInput, {q Down}
            Sleep, 1
            SendInput, {q Up}
        }
        Else If (x1 < x2)
        {
            SendInput, {e Down}
            Sleep, 1
            SendInput, {e Up}
        }
        Else If (x1 > x2 and y1 > y2)
        {
            SendInput, {q Down}{n Down}
            Sleep, 1
            SendInput, {q Up}{n Up}
        }
        Else If (x1 < x2 and y1 > y2)
        {
            SendInput, {e Down}{n Down}
            Sleep, 1
            SendInput, {e Up}{n Up}
        }
        Else If (x1 > x2 and y1 < y2)
        {
            SendInput, {q Down}{m Down}
            Sleep, 1
            SendInput, {q Up}{m Up}
        }
        Else If (x1 < x2 and y1 < y2)
        {
            SendInput, {e Down}{m Down}
            Sleep, 1
            SendInput, {e Up}{m Up}
        }
        Else
        {
            If (Status_MButton)
            {
                SendInput, {Click, Up Middle}
                Status_MButton := !Status_MButton
            }
        }
    }
}

;【函数】输入重置
InputReset()
{
    If (Status_MButton)
    {
        SendInput, {Click, Up Middle}
        Status_MButton := !Status_MButton
    }
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------

;【热键】点击鼠标中键以激活视角跟随
MButton::
If GetKeyState("MButton", "P") ; 通过行为检测防止中键被部分函数唤醒
{
    Toggle_MouseFunction := !Toggle_MouseFunction
    If (Toggle_MouseFunction)
    {
        CoordReset()
        SetTimer, ViewControl, 0 ; [可调校数值] 设定视角跟随命令的每执行时间间隔(ms)
        ToolTip, 视角跟随已激活, 0, 999 ; [可调校数值]
        Sleep 999 ; [可调校数值]
        ToolTip
    }
    Else
    {
        SetTimer, ViewControl, Off
        InputReset()
        ToolTip, 视角跟随已关闭, 0, 999 ; [可调校数值]
        Sleep 999 ; [可调校数值]
        ToolTip
    }
}
Return

;【热键】点按鼠标左键以发动普攻
LButton::
SendInput, {j Down}
If (Toggle_MouseFunction)
{
    If GetKeyState("LButton", "P")
    {
        SetTimer, ViewControl, Off
        InputReset()
        SetTimer, ViewControlTemp, 0
    }
}
KeyWait, LButton
SendInput, {j Up}
If (Toggle_MouseFunction)
{
    SetTimer, ViewControlTemp, Off
    SetTimer, ViewControl, On
}
Return

;【热键】按住键盘左侧ALT以正常使用鼠标左键
LAlt:: ; *!LButton::LButton
SetTimer, LAltTab, 0
Hotkey, LButton, Off
If (Toggle_MouseFunction)
{
    SetTimer, ViewControl, Off
    InputReset()
}
KeyWait, LAlt
SetTimer, LAltTab, Off
Hotkey, LButton, On
If (Toggle_MouseFunction)
    SetTimer, ViewControl, On
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------
;目前就这些，可根据需要自行修改
;---------------------------------------------------------------------------------------------------------------------------------------------------------------