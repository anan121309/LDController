//=============================================================================================
//=============================================================================================
//                               读写界面配置
//=============================================================================================
//=============================================================================================
function WriteConfig()
    filewriteini("runing", "openPoint", openPoint, sysPath & "Config.ini")
    filewriteini("intelfase", "Timing_h_Edit", editgettext("Timing_h_Edit"), sysPath & "Config.ini")
    filewriteini("intelfase", "Timing_m_Edit", editgettext("Timing_m_Edit"), sysPath & "Config.ini")
    filewriteini("intelfase", "OpenMaxCombobox", combogetcursel("OpenMaxCombobox"), sysPath & "Config.ini")
    filewriteini("intelfase", "BindModeCombobox", combogetcursel("BindModeCombobox"), sysPath & "Config.ini")
    for(var i = 1; i < lastSimulator + 1; i++)
        filewriteini("intelfase", "TableRow" & i & "SelectStutas", gridgetcheckstate("Table", i, 0), sysPath & "Config.ini")
    end
end
function ReadConfig()
    editsettext("LdidEdit", filereadini("runing", "openPoint", sysPath & "Config.ini"))
    editsettext("Timing_h_Edit", filereadini("intelfase", "Timing_h_Edit", sysPath & "Config.ini"))
    editsettext("Timing_m_Edit", filereadini("intelfase", "Timing_m_Edit", sysPath & "Config.ini"))
    combosetcursel("OpenMaxCombobox", filereadini("intelfase", "OpenMaxCombobox", sysPath & "Config.ini"))
    combosetcursel("BindModeCombobox", filereadini("intelfase", "BindModeCombobox", sysPath & "Config.ini"))
    for(var i = 1; i < lastSimulator + 1; i++)
        gridsetcheckstate("Table", i, 0, filereadini("intelfase", "TableRow" & i & "SelectStutas", sysPath & "Config.ini"))
    end
end
///
///
function QQLinkBtn_click()
    //    webgo("explorer0", "http://wpa.qq.com/msgrd?v=3&uin=1213095357&site=qq&menu=yes")
end
function SetSkin()
    dllcall(getrcpath("rc:SkinH_EL.dll"), "int", "SkinH_AttachEx", "char *", getrcpath("rc:51.she"), "char *", "")
end

function InitConfig()
    CreateDMObject()
    Init_Var()
    InitData()
    GetDncInfo()
    TableVive()
    ReadConfig()
    OpenMaxCombobox_selectchange()
    //===================================================
    var status = _ReadConfig("Controller", "Status")
    if(status == "Runing")
        StopBtn_click()
        sleep(3000)
        StartBtn_click()
    end
    
end
var controllerStatus = 0	//-1退出 0未运行 1运行中 2暂停
var mainThread
function StartBtn_click()
    if(controllerStatus == 0)
        mainThread = threadbegin("LoopStartSimulator", 0)
        controlenable("StartBtn", false)
        controlenable("SuspendBtn", true)
        controlenable("RecoveryBtn", false)
        controlenable("StopBtn", true)
    else
        OutMsg("任务繁忙,控制器已在运行中.")
    end
end
function SuspendBtn_click()
    if(controllerStatus == 1)
        controllerStatus = 2
        threadsuspend(mainThread)
        for(var i = 1; i < simulatorNum; i++)
            var ldThread = GetRowDataTable(i, "ldThread")
            var ldid = GetRowDataTable(i, "id")
            if(ldThread)
                threadsuspend(ldThread)
                traceprint(getlasterror())
                TableUpdata(ldid, "暂停中...")
            end
        end
        controlenable("StartBtn", false)
        controlenable("SuspendBtn", false)
        controlenable("RecoveryBtn", true)
        controlenable("StopBtn", true)
    end
end
function RecoveryBtn_click()
    if(controllerStatus == 2)
        controllerStatus = 1
        threadresume(mainThread)
        for(var i = 1; i < simulatorNum; i++)
            var ldThread = GetRowDataTable(i, "ldThread")
            if(ldThread)
                threadresume(ldThread)
            end
        end
        controlenable("StartBtn", false)
        controlenable("SuspendBtn", true)
        controlenable("RecoveryBtn", false)
        controlenable("StopBtn", true)
    end
end
function StopBtn_click()
    if(controllerStatus != 1)//恢复线程
        RecoveryBtn_click()
    end
    controllerStatus = 0
    if(threadclose(mainThread))
        OutMsg("控制器成功退出!")
    else
        OutMsg("控制器未成功退出!")
    end
    for(var i = 1; i < simulatorNum; i++)
        var isRun = GetRowDataTable(i, "isRun")
        if(isRun)
            var ldid = GetRowDataTable(i, "id")
            threadbegin("ExitSimulator", array(ldid, "ManualExit"))
        end
    end
    controlenable("StartBtn", true)
    controlenable("SuspendBtn", false)
    controlenable("RecoveryBtn", false)
    controlenable("StopBtn", false)
    _WriteConfig("Controller", "Status", "stop")
end

function CloseProcess()
    _WriteConfig("Controller", "Status", "stop")
    var pid = information(windowgetmyhwnd(), 5)
    var processHandle = information(pid, 2)
    closeprocess(processHandle)
end
function TableVive()//表格显示
    for(var i = 1; i < lastSimulator + 1; i++)
        if(isarray(ldInfo[i]))
            var row = array(ldInfo[i]["name"])
            gridinsertrow("Table", row)
            gridsetrowheight("Table", i, 24)
        end
    end
end
function TableUpdata(ldid = null, msg = null)
    criticalenter(UICriticalHandle)
    //    var row = ldInfo[ldid]["index"]
    if(ldid != null)
        var row = GetIdDataTable(ldid, "row")
        if(checkgetstate("TopTitleViewCheck"))
            gdi写字(ldInfo[ldid]["fatherHwnd"], "ID:" & ldid & "   " & msg, 0, 0, 255, 36)
        end
        gridsetcontent("Table", row, 1, msg)
        var logPath = sysPath & "log\\"& ldid & " - Log.txt"
        gridsetrowheight("Table", row, 24)
        filelog(msg & "------" & timenow(), logPath)
    end
    criticalleave(UICriticalHandle)
end
function gdi写字(句柄, 内容, x, y, 颜色 = 255, 字号 = 12)
    if(句柄 != 0)
        内容 = " " & 内容 & "                                                                                                                                                                            "
        var hdc = dllcall("user32.dll", "int", "GetDC", "int", 句柄) //创建场景DC
        var 字体 = dllcall("gdi32.dll", "int", "CreateFontA", "int", 字号, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "int", 0, "char *", "微软雅黑")//创建字体
        var h = dllcall("gdi32.dll", "int", "SelectObject", "int", hdc, "int", 字体) //选入设备场景
        var 背景模式 = dllcall("gdi32.dll", "int", "SetBkMode", "int", hdc, "int", 2) //指定阴影刷子、虚线画笔以及字符中的空隙的填充方式　前一个背景模式的值
        var 前景色 = dllcall("gdi32.dll", "int", "SetTextColor", "int", hdc, "int", 颜色) //设置当前文本颜色。这种颜色也称为“前景色”　文本色的前一个RGB颜色设定。CLR_INVALID表示失败。会设置GetLastError
        //        if(isint(内容))
        dllcall("gdi32.dll", "int", "TextOutA", "int", hdc, "int", x, "int", y, "char *", 内容, "int", 200)
        //        else
        //            dllcall("gdi32.dll", "int", "TextOutA", "int", hdc, "int", x, "int", y, "char *", 内容, "int", strlen(内容) * 2)
        //        end
        dllcall("gdi32.dll", "int", "SetBkMode", "int", hdc, "int", 背景模式)//指定阴影刷子、虚线画笔以及字符中的空隙的填充方式　前一个背景模式的值
        dllcall("gdi32.dll", "int", "SetTextColor", "int", hdc, "int", 前景色) //设置当前文本颜色。这种颜色也称为“前景色”　文本色的前一个RGB颜色设定。CLR_INVALID表示失败。会设置GetLastError
        dllcall("gdi32.dll", "int", "SelectObject", "int", hdc, "int", h)//选入设备场景
        dllcall("gdi32.dll", "int", "DeleteObject", "int", 字体)  //删除对象 用这个函数删除GDI对象，比如画笔、刷子、字体、位图、区域以及调色板等等
        dllcall("user32.dll", "int", "ReleaseDC", "int", 0, "int", hdc) //释放设备场景
    end
end
//多开数量选择
function OpenMaxCombobox_selectchange()
    openMax = combogetcursel("OpenMaxCombobox") + 1
end
//批量全选
function IndexSelectCheck_click()
    var row
    gridgetsize("Table", row, null)
    if(checkgetstate("IndexSelectCheck"))
        for(var i = 1; i < row; i++)
            gridsetcheckstate("Table", i, 0, true)
        end
    else
        for(var i = 1; i < row; i++)
            gridsetcheckstate("Table", i, 0, false)
        end
    end
end
//获取最后一个选择
function GetTheLastChoice()
    var row, lastChoice
    gridgetsize("Table", row, null)
    for(var i = 1; i < row; i++)
        var status = gridgetcheckstate("Table", i, 0)
        if(status)
            lastChoice = i
        end
    end
    lastChoice = GetRowDataTable(lastChoice, "id")
    return lastChoice
end
function MenuShow()
    var  itemArr = array("取消", "启动", "暂停", "恢复", "停止")
    var TPM_RETURNCMD = #0100
    var TPM_RIGHTBUTTON = #0002
    var TPM_LEFTBUTTON = #0000
    var TPM_RIGHTALIGN = #0008   
    var TPM_TOPALIGN = #0000
    var menuHandle = dllcall("user32.dll", "int", "CreatePopupMenu") //创建弹出式菜单
    if(menuHandle == 0)
        return 0
    end
    var len = arraysize(itemArr)
    for(var i = 0; i < len; i++)
        dllcall("user32.dll", "int", "AppendMenuA", "int", menuHandle, "int", 0, "int", i, "char *", itemArr[i])
    end  
    var x, y
    mousegetpoint(x, y)   
    var ret = dllcall("user32.dll", "int", "TrackPopupMenu", "int", menuHandle, "int", TPM_RIGHTALIGN + TPM_TOPALIGN + TPM_LEFTBUTTON + TPM_RIGHTBUTTON + TPM_RETURNCMD, "int", x, "int", y, "int", 0, "int", windowgetmyhwnd(), "int", 0)
    dllcall("user32.dll", "int", "DestroyMenu", "int", menuHandle)
    return ret
end
function WindowTopCheck_click()
    if(checkgetstate("WindowTopCheck"))
        windowsettop(windowgetmyhwnd(), true)
    else
        windowsettop(windowgetmyhwnd(), false)
    end
end
function OutMsg(str)
    criticalenter(UICriticalHandle)
    listaddtext("OutMsgList", str)
    var count = listgetcount("OutMsgList")
    listsetcursel("OutMsgList", count - 1)
    if(listgetcount("OutMsgList") >= 300)
        listdeleteall("OutMsgList")
    end
    criticalleave(UICriticalHandle)
end
function PriviewTime_ontime()
    editsettext("OpenCountEdit", "已开模拟器: (" & openCount & " )")
end
function DebugShowBtn_click()
    controlopenwindow("_Debug", true)
end
var tableSelectRow = 1
function Table_clicked()
    var ldid, row
    ldid = GetRowDataTable(tableSelectRow, "id")
    var hwnd = GetIdDataTable(ldid, "fatherHwnd")
    if(hwnd)
        windowsettop(hwnd, false)
    end
    gridgetselectrange("Table", row, null, null, null)
    ldid = GetRowDataTable(row, "id")
    hwnd = GetIdDataTable(ldid, "fatherHwnd")
    if(row >= 1 && hwnd)
        windowsettop(GetIdDataTable(ldid, "fatherHwnd"), true)
        if(checkgetstate("WindowTopCheck"))
            windowsettop(windowgetmyhwnd(), true)
        end
        tableSelectRow = row
    end
end
function SettingBtn_click()
    controlopenwindow("GameSetting", true)
end
//===========================================================这里是悬浮窗口加载样式
var m_hwnd
var WS_EX_LAYERED = #80000//让窗口有透明属性
var WS_BORDER = #00800000//无边框属性
var WS_CAPTION = #00C00000
var WS_CLIPSIBLINGS = #04000000
var WS_CLIPCHILDREN = #02000000
var TRANSPARENT = 1
//更新窗口扩展风格
function UdateWindowStyleEx(hwnd, Style)
    var  GWL_STYLE = -20
    var style = dllcall("user32.dll", "int", "GetWindowLongA", "int", m_hwnd, "int", GWL_STYLE) 
    dllcall("user32.dll", "int", "SetWindowLongA", "int", m_hwnd, "int", GWL_STYLE, "int", style + Style) 
end
//更新窗口风格
function UdateWindowStyle(hwnd, Style)
    var GWL_STYLE = -16
    var style = dllcall("user32.dll", "int", "GetWindowLongA", "int", m_hwnd, "int", GWL_STYLE) 
    dllcall("user32.dll", "int", "SetWindowLongA", "int", m_hwnd, "int", GWL_STYLE, "int", style + Style) 
end
//透明度
//hwnd:窗口句柄
//color:要透明的颜色
//Alpha:透明度 0-255
//dwFlags:1,color有效;2,Alpha;3color、Alpha都有效
function Transparency(hwnd, color, Alpha, dwFlags)
    return dllcall("user32.dll", "int", "SetLayeredWindowAttributes", "int", hwnd, "int", color, "int", Alpha, "int", dwFlags) 
end
//对窗口的裁剪
function 异型窗体(hwnd)
    //获取窗口要裁剪的范围
    var hr = dllcall("gdi32.dll", "int", "CreateRectRgn", "int", 10, "int", 35, "int", 490, "int", 480) 
    //对窗口进行裁剪,对裁剪过的区域不显示
    var dl = dllcall("user32.dll", "int", "SetWindowRgn", "int", hwnd, "int", hr, "bool", true) 
end
function LoadingWindowStyle(hwnd)
    UdateWindowStyleEx(hwnd, WS_EX_LAYERED)//给窗口增加透明属性
    UdateWindowStyle(hwnd, 0 - WS_BORDER)//把窗口的标题去掉,方便计算坐标
    var ret = Transparency(hwnd, #f0f0f0, 0, 0)//通过指定颜色让窗口透明
    异型窗体(hwnd)//对窗口进行裁剪,把边框裁剪掉达到真正的无边框窗口
end
var mixingModeTask = false
function TaskSelect_selectchange()
    select(combogetcursel("TaskSelect"))
        case 2
        case 6
        mixingModeTask = true
        default
        mixingModeTask = false
    end
end
function button3_click()
    //这里添加你要执行的代码
    var ret = SQL_GetAll()
    traceprint(ret)
    //    SQL_Delete(ret[0]["ID"])
end
function MsgPrevive(msg)
    criticalenter(UICriticalHandle)
    staticsettext("MsgPrevive", msg)
    criticalleave(UICriticalHandle)
end

function _LDController_init()
    SetSkin()
    threadbegin("InitConfig", "")
end

//点击关闭_执行操作
function _LDController_close()
    WriteConfig()
    CloseProcess()
end


//消息路由功能
function _LDController_pretranslatemessage(hwnd, message, wParam, lParam, time, x, y)
    if(hwnd == controlgethandle("Table") && message == 516)//左键双击
        var rowBegin, rowEnd
        select(MenuShow())
            case 0
            case 1//启动
            if(controllerStatus == 0)
                gridgetselectrange("Table", rowBegin, null, rowEnd, null)
                for(var i = rowBegin; i < rowEnd + 1; i++)
                    var ldThread = GetRowDataTable(i, "ldThread")
                    var ldid = GetRowDataTable(i, "id")
                    if(!ldThread)
                        TableUpdata(ldid, "加入启动队列 雷电ID: " & ldid)
                        OutMsg("雷电ID: " & ldid & "成功加入启动队列.")
                        AddManualLDStartList(ldid)
                    end
                end
                mainThread = threadbegin("ManualStartSimulator", null)
            else
                OutMsg("任务繁忙,控制器已在运行中.")
            end
            case 2//暂停
            gridgetselectrange("Table", rowBegin, null, rowEnd, null)
            for(var i = rowBegin; i < rowEnd + 1; i++)
                var ldThread = GetRowDataTable(i, "ldThread")
                var ldid = GetRowDataTable(i, "id")
                if(ldThread)
                    threadsuspend(ldThread)
                    TableUpdata(ldid, "暂停中...")
                    OutMsg("雷电ID: " & ldid & "暂停中..")
                end
            end
            case 3//恢复
            gridgetselectrange("Table", rowBegin, null, rowEnd, null)
            for(var i = rowBegin; i < rowEnd + 1; i++)
                var ldThread = GetRowDataTable(i, "ldThread")
                var ldid = GetRowDataTable(i, "ldThread")
                if(ldThread)
                    OutMsg("雷电ID: " & ldid & "已成功恢复.")
                    threadresume(ldThread)
                end
            end
            case 4//停止
            gridgetselectrange("Table", rowBegin, null, rowEnd, null)
            for(var i = rowBegin; i < rowEnd + 1; i++)
                var ldThread = GetRowDataTable(i, "ldThread")
                if(ldThread)
                    var ldid = GetRowDataTable(i, "id")
                    threadbegin("ExitSimulator", array(ldid, "ManualExit"))
                end
            end
        end
    end
    return false
end

