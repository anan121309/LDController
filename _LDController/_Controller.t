//=================================================================================
//=================================================================================
//								 系统运行时数据表
//=================================================================================
//=================================================================================
var idDataTable = array()
var rowDataTable = array()
var simulatorNum
//初始化数据表
function InitData()
    GetDncInfo()
    var row = 1
    for(var i = 1; i < lastSimulator + 1; i++)
        if(isarray(ldInfo[i]))
            //以ID存放数据表
            idDataTable[i] = array()
            idDataTable[i]["row"] = row
            idDataTable[i]["name"] = ldInfo[i]["name"]
            idDataTable[i]["fatherHwnd"] = ldInfo[i]["fatherHwnd"]
            idDataTable[i]["Hwnd"] = ldInfo[i]["Hwnd"]
            idDataTable[i]["isRun"] = ldInfo[i]["isRun"]
            idDataTable[i]["pid"] = ldInfo[i]["pid"]
            idDataTable[i]["ExitSimulator"] = false
            idDataTable[i]["ldThread"] = null
            idDataTable[i]["dmid"] = null
            //以行存放数据表
            rowDataTable[row] = array()
            rowDataTable[row]["id"] = i
            rowDataTable[row]["name"] = ldInfo[i]["name"]
            rowDataTable[row]["fatherHwnd"] = ldInfo[i]["fatherHwnd"]
            rowDataTable[row]["Hwnd"] = ldInfo[i]["Hwnd"]
            rowDataTable[row]["isRun"] = ldInfo[i]["isRun"]
            rowDataTable[row]["pid"] = ldInfo[i]["pid"]
            rowDataTable[row]["ExitSimulator"] = false
            rowDataTable[row]["ldThread"] = null
            rowDataTable[row]["dmid"] = null
            row++
        end
    end
    simulatorNum = arraysize(rowDataTable) + 1
end
function GetIdDataTable(id, key)
    return idDataTable[id][key]
end
function GetRowDataTable(row, key)
    return rowDataTable[row][key]
end
function SetData(id, key, value)
    var row = GetIdDataTable(id, "row")
    idDataTable[id][key] = value
    rowDataTable[row][key] = value
end
//=================================================================================
//=================================================================================
//								 无人值守模式
//=================================================================================
//=================================================================================
function LoopStartSimulator()
    controllerStatus = 1
    openPoint = editgettext("LdidEdit")
    var lastTheChoice = GetTheLastChoice()  //获取最后一个选择的模拟器
    mainTask = combogetcursel("TaskSelect") //获取主任务
    if(mainTask == 7)
        mainTask = 0
    end
    while(true)
        _WriteConfig("Controller", "Status", "Runing")
        MsgPrevive("轮换模式中..")
        GetWindowCount()
        //模拟器计次小于最大多开数 且模拟器不为退出状态
        if(openCount < openMax && !simulatorExitStatus)
            //分配ID并启动
            var ldid = GetIdleLDIndex()
            SetData(ldid, "isRun", 1)
            editsettext("LdidEdit", ldid)
            GetDncInfo()
            simulatorStartIng = true
            StartDnc(ldid)
            while(!ldInfo[ldid]["isRun"])
                TableUpdata(ldid, "启动模拟器...")
                GetDncInfo()
                sleep(1000)
            end
            //设置数据
            SetData(ldid, "fatherHwnd", ldInfo[ldid]["fatherHwnd"])
            SetData(ldid, "Hwnd", ldInfo[ldid]["Hwnd"])
            SetData(ldid, "pid", ldInfo[ldid]["pid"])
            TableUpdata(ldid, "开始绑定插件")
            //插件绑定
            var dmid = GetIdleDMIndex()
            TableUpdata(ldid, "获取空闲插件ID为:" & dmid)
            var bindRet
            bindRet = dm[dmid].BindWindowEx(ldInfo[ldid]["hwnd"], bindMode, "windows", "windows", "", 0)
            if(bindRet == 1)
                TableUpdata(ldid, "大漠绑定成功!")
            end
            SetData(ldid, "dmid", dmid)
            //启动配置
            var threadHandle = threadbegin("LD_Startup", ldid)
            SetData(ldid, "ldThread", threadHandle)
            openPoint++
            simulatorStartIng = false
            WriteConfig()
            //休息检测
            if(ldid == lastTheChoice)//最后一个模拟器调用休息函数
                if(mixingModeTask)
                    if(mainTask == 0)
                        mainTask = 6
                    elseif(mainTask == 6)
                        mainTask = 0
                    end
                else
                    Sleep()
                end
            end
        end
        sleep(3000)
    end
end
//=================================================================================
//=================================================================================
//								 手动模式
//=================================================================================
//=================================================================================
var manualLDStartList = array()
function AddManualLDStartList(value)
    var len = arraysize(manualLDStartList)
    manualLDStartList[len++] = value
end
function GetManualLDStartList()
    var ldid, key
    arraygetat(manualLDStartList, 0, ldid, key)
    arraydeletekey(manualLDStartList, key)
    return ldid
end
function GetManualLDStartListLengh()
    return arraysize(manualLDStartList)
end
function ManualStartSimulator()
    OutMsg("控制器线程启动")
    MsgPrevive("手动模式中..")
    controllerStatus = 1
    var idList = manualLDStartList
    var len = GetManualLDStartListLengh()
    mainTask = combogetcursel("TaskSelect")
    for(var i = 0; i < len; i++)
        var ldid = GetManualLDStartList()
        SetData(ldid, "isRun", 1)
        StartDnc(ldid)
        GetDncInfo()
        while(!ldInfo[ldid]["isRun"])
            TableUpdata(ldid, "启动模拟器...")
            GetDncInfo()
            sleep(1000)
        end
        //设置数据
        SetData(ldid, "fatherHwnd", ldInfo[ldid]["fatherHwnd"])
        SetData(ldid, "Hwnd", ldInfo[ldid]["Hwnd"])
        SetData(ldid, "pid", ldInfo[ldid]["pid"])
        //============================插件绑定=======================
        var dmid = GetIdleDMIndex()
        TableUpdata(ldid, "获取空闲插件ID为:" & dmid)
        var bindRet
        bindRet = dm[dmid].BindWindowEx(ldInfo[ldid]["hwnd"], bindMode, "windows", "windows", "", 0)
        if(bindRet == 1)
            TableUpdata(ldid, "大漠绑定成功!")
        end
        SetData(ldid, "dmid", dmid)
        //=======================================================
        var threadHandle = threadbegin("LD_Startup", ldid)
        SetData(ldid, "ldThread", threadHandle)
        OutMsg("雷电ID: " & ldid & " 启动成功")
    end
    controllerStatus = 0
    var ret, idListLen = arraysize(idList)
    while(true)
        var count = 0
        for(var i = 0; i < idListLen; i++)
            if(GetIdDataTable(idList[i + 1], "ldThread") == null)
                count++
            end
            if(count == idListLen)
                OutMsg("控制器线程退出")
                MsgPrevive("手动模式结束..")
                return
            end
        end
        sleep(1000)
    end
end
//=================================================================================
//=================================================================================
//								 模拟器退出
//
//			当try为true是模拟器标记异常,为false时为正常退出!
//=================================================================================
//=================================================================================
function ExitSimulator(param)
    //取得数组参数
    var ldid = param[0]
    var msg = param[1]
    TableUpdata(ldid, "模拟器退出原因: " & msg)
    //设置标志位为退出状态
    simulatorExitStatus = true
    //设置该退出变量为真.图色命令不运行
    SetData(ldid, "ExitSimulator", true)
    //释放线程
    var ldThread = GetIdDataTable(ldid, "ldThread")
    SetData(ldid, "ldThread", null)
    if(msg == "ManualExit")//如果为手动结束则首先关闭进程 如果为自动结束则流畅退出.
        threadclose(ldThread, 1)
    end
    //解绑大漠
    if(GetIdDataTable(ldid, "dmid"))
        TableUpdata(ldid, "解绑插件")
        var dmid = GetIdDataTable(ldid, "dmid")
        var unBindRet
        unBindRet = dm[dmid].UnBindWindow()
        if(unBindRet)
            TableUpdata(ldid, "大漠解绑成功")
        end
        dmRunStatus[dmid] = false
        SetData(ldid, "dmid", null)
    end
    //关闭模拟器
    TableUpdata(ldid, "关闭模拟器")
    CloseDnc(ldid)
    sleep(3000)
    if(msg == "Try")
        TableUpdata(ldid, "状态异常,加入重启队列 原因:" & msg)
        AddTrySimulatorList(ldid)
    end
    //清空数据
    SetData(ldid, "fatherHwnd", null)
    SetData(ldid, "Hwnd", null)
    SetData(ldid, "pid", null)
    SetData(ldid, "ExitSimulator", false)
    SetData(ldid, "isRun", null)
    //UI更新
    TableUpdata(ldid, "")
    OutMsg("雷电ID: " & ldid & "已成功停止.")
    //标志位为false 控制器允许启动
    simulatorExitStatus = false
    threadclose(ldThread, 1)
end
//=================================================================================
//=================================================================================
//								 无人轮换休息
//=================================================================================
//=================================================================================
function Sleep()
    var pastTime = gettickcount()
    var h = editgettext("Timing_h_Edit")
    var m = editgettext("Timing_m_Edit")
    var time = (h * 3600000) + (m * 60000)
    while(true)
        //异常列表不休息
        GetWindowCount()
        if(GetTrySimulatorListLengh() > 0 && openCount < openMax)
            var ldid = GetTrySimulatorList()
            SetData(ldid, "isRun", 1)
            GetDncInfo()
            while(!ldInfo[ldid]["isRun"])
                TableUpdata(ldid, "异常模拟器启动中...")
                GetDncInfo()
                StartDnc(ldid)
                sleep(3000)
            end
            //设置数据
            SetData(ldid, "fatherHwnd", ldInfo[ldid]["fatherHwnd"])
            SetData(ldid, "Hwnd", ldInfo[ldid]["Hwnd"])
            SetData(ldid, "pid", ldInfo[ldid]["pid"])
            //============================插件绑定=======================
            var dmid = GetIdleDMIndex()
            TableUpdata(ldid, "获取空闲插件ID为:" & dmid)
            var bindRet
            bindRet = dm[dmid].BindWindowEx(ldInfo[ldid]["hwnd"], bindMode, "normal", "normal", "", 0)
            if(bindRet == 1)
                TableUpdata(ldid, "大漠绑定成功!")
            end
            SetData(ldid, "dmid", dmid)
            //=======================================================
            var threadHandle = threadbegin("LD_Startup", ldid)
            SetData(ldid, "ldThread", threadHandle)
            TableUpdata(ldid, "启动主线程")
        end
        //traceprint("=========================")
        //traceprint("runTime:" & (gettickcount() - pastTime))
        //traceprint("editTime:" & time)
        sleep(500)
        var ms = gettickcount() - pastTime
        MsgPrevive(MsToTime(time - ms) & " - 后启动下一轮")
        if(ms >= time)
            MsgPrevive("轮换模式中..")
            return
        end
    end
end

//获取空闲雷电
function GetIdleLDIndex()
    while(true)
        if(openPoint > lastSimulator)
            openPoint = 1
        end
        if(isarray(idDataTable[openPoint]))
            var status = GetIdDataTable(openPoint, "isRun")
            var row = GetIdDataTable(openPoint, "row")
            if((status == false || status == null) && openPoint != 0 && gridgetcheckstate("Table", row, 0))//查询不为0或者空闲时模拟器
                return openPoint
            end
        end
        openPoint++
    end
end
//
//获取空闲插件ID
var dmRunStatus = array()
function GetIdleDMIndex()
    for(var i = 0; i < 30; i++)
        if(dmRunStatus[i] != true)
            dmRunStatus[i] = true
            return i
        end
    end
end
function GetWindowCount()
    var winArr = enum("LDPlayerMainFrame", 1)
    if(winArr != "")
        strsplit(winArr, "|", winArr)
        openCount = arraysize(winArr)
    else
        openCount = 0
    end
end
//=================================================================================
//=================================================================================
//								 异常模拟器记录列表
//=================================================================================
//=================================================================================
var tryList = array()
function AddTrySimulatorList(value)
    var len = arraysize(tryList)
    tryList[len++] = value
end
function GetTrySimulatorList()
    var len = arraysize(tryList)
    var ret = tryList[len]
    arraydeletekey(tryList, len)
    return ret
end
function GetTrySimulatorListLengh()
    return arraysize(tryList)
end