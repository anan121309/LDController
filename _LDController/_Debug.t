//开始按钮_点击操作
function _Debug_start_click()
    return true
end
//退出按钮_点击操作
function _Debug_exit_click()
    return true
end
function _DebugPreviewBtn_click()
    ViewDebugData()
end
var ViewDebugDataThread
function ViewDebugData()
    while(true)
        for(var i = 1; i < simulatorNum; i++)
            //        gridsetcontent("IDDatatableTab", i, 0, i, "_Debug")
            //        gridsetcontent("IDDatatableTab", i, 1, GetRowDataTable(i, "id"), "_Debug")
            //        gridsetcontent("IDDatatableTab", i, 2, GetRowDataTable(i, "name"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 3, GetRowDataTable(i, "fatherHwnd"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 4, GetRowDataTable(i, "Hwnd"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 5, GetRowDataTable(i, "isRun"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 6, GetRowDataTable(i, "pid"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 7, GetRowDataTable(i, "ExitSimulator"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 8, GetRowDataTable(i, "ldThread"), "_Debug")
            gridsetcontent("IDDatatableTab", i, 9, GetRowDataTable(i, "dmid"), "_Debug")
        end
        sleep(300)
    end
end
function _Debug_init()
    for(var i = 1; i < simulatorNum; i++)
        var arr = array()
        arr["row"] = i
        arr["ldid"] = GetRowDataTable(i, "id")
        arr["name"] = GetRowDataTable(i, "name")
        arr["fatherHwnd"] = GetRowDataTable(i, "fatherHwnd")
        arr["Hwnd"] = GetRowDataTable(i, "Hwnd")
        arr["isRun"] = GetRowDataTable(i, "isRun")
        arr["pid"] = GetRowDataTable(i, "pid")
        arr["ExitSimulator"] = GetRowDataTable(i, "ExitSimulator")
        arr["ldThread"] = GetRowDataTable(i, "ldThread")
        arr["dmid"] = GetRowDataTable(i, "dmid")
        gridinsertrow("IDDatatableTab", arr, -1, "_Debug")
        gridsetrowheight("IDDatatableTab", i, 25, "_Debug")
    end
    ViewDebugDataThread = threadbegin("ViewDebugData", "")
end
//点击关闭_执行操作
function _Debug_close()
    threadclose(ViewDebugDataThread, 1)
    controlclosewindow("_Debug", 0)
end