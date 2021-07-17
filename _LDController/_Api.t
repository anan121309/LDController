//=============================================================================================
//=============================================================================================
//                               毫秒换算到时间
//=============================================================================================
//=============================================================================================
function MsToTime(ms)
    var h = ms / 3600000
    var _h = ms % 3600000
    var m = _h / 60000 
    var _m = _h % 60000
    var s = _m / 1000
    if(h < 10)
        h = "0" & h
    end
    if(m < 10)
        m = "0" & m
    end
    if(s < 10)
        s = "0" & s
    end
    var time = h & ":" & m & ":" & s
    return time
end
//=============================================================================================
//=============================================================================================
//                               窗口循环多点找色
//
//		描述:
//			循环多点找色,找到返回坐标,时间过后则返回array(-1,-1)
//
//		参数:
//			first_color    色彩描述
//			offset_color   多点找色
//			time           循环秒数
//			Click          是否单击
//
//		返回值:
//			array(x坐标,y坐标)
//
//=============================================================================================
//=============================================================================================
function _LoopFindColor(ldid, x1, y1, x2, y2, f, o, &x, &y, time, click)
    var tryCount = 0
    while(true)
        //判断退出命令是否执行
        if(GetIdDataTable(ldid, "ExitSimulator"))
            return false
        end
        //判断是否状态异常
        if(StatusTryAction(ldid))
            var dmid = GetIdDataTable(ldid, "dmid")
            if(dm[dmid].FindMultiColor(x1, y1, x2, y2, f, o, 0.9, 0, x, y))
                if(click)
                    Click(ldid, x, y)
                end
                return true
            end
            if(tryCount++ > time)
                return false
            end
        end
        sleep(1000)
    end 
end
//=============================================================================================
//=============================================================================================
//                               窗口多点找色
//
//		描述:
//			找到返回坐标,未找到返回array(-1,-1)
//
//		参数:
//			first_color    色彩描述
//			offset_color   多点找色
//			Click          是否单击
//
//		返回值:
//			array(x坐标,y坐标)
//
//=============================================================================================
//=============================================================================================
function _FindColor(ldid, x1, y1, x2, y2, f, o, &x, &y, click)
    //判断退出命令是否执行
    if(GetIdDataTable(ldid, "ExitSimulator"))
        return false
    end
    //判断是否状态异常
    if(StatusTryAction(ldid))
        var dmid = GetIdDataTable(ldid, "dmid")
        if(dm[dmid].FindMultiColor(x1, y1, x2, y2, f, o, 0.9, 0, x, y))
            if(click)
                Click(ldid, x, y)
            end
            return true
        end
    end
    return false
end
//=============================================================================================
//=============================================================================================
//                               窗口循环找图
//
//		描述:
//			循环找图,找到返回坐标,时间过后则返回array(-1,-1)
//
//		参数:
//			pic            图片路径
//			deltaColor     色偏
//			time           循环秒数
//			Click          是否单击
//
//		返回值:
//			array(x坐标,y坐标)
//
//=============================================================================================
//=============================================================================================
function _LoopFindPic(ldid, x1, y1, x2, y2, pic, &x, &y, time, click)
    var tryCount = 0
    while(true)
        //判断退出命令是否执行
        if(GetIdDataTable(ldid, "ExitSimulator"))
            return false
        end
        //判断是否状态异常
        if(StatusTryAction(ldid))
            var dmid = GetIdDataTable(ldid, "dmid")
            //        criticalenter(ReadImageCriticalHandle)
            var fendRet = dm[dmid].FindPic(x1, y1, x2, y2, pic, 303030, 0.7, 0, x, y)
            //        criticalleave(ReadImageCriticalHandle)
            if(fendRet >= 0)
                if(click)
                    Click(ldid, x, y)
                end
                return true
            end
            if(tryCount++ > time)
                return false
            end
        end
        sleep(1000)
    end 
end
//=============================================================================================
//=============================================================================================
//                               找图
//
//		描述:
//			找图,找到返回坐标,未找到则返回array(-1,-1)
//
//		参数:
//			mode           找图模式 tc为tc自带找图 dm为调用大漠找图
//			pic            图片路径
//			deltaColor     色偏
//			Click          是否单击
//
//		返回值:
//			array(x坐标,y坐标)
//
//=============================================================================================
//=============================================================================================
function _FindPic(ldid, x1, y1, x2, y2, pic, &x, &y, click)
    //判断退出命令是否执行
    if(GetIdDataTable(ldid, "ExitSimulator"))
        return false
    end
    if(StatusTryAction(ldid))
        var dmid = GetIdDataTable(ldid, "dmid")
        //    criticalenter(ReadImageCriticalHandle)
        var findRet = dm[dmid].FindPic(x1, y1, x2, y2, pic, 303030, 0.7, 0, x, y)
        //    criticalleave(ReadImageCriticalHandle)
        if(findRet >= 0)
            if(click)
                Click(ldid, x, y)
            end
            return true
        end
    end
    return false
end
//根据字库识字
function _Ocr(ldid, dictIndex, exact, x1, y1, x2, y2, color, sim)
    var dmid = GetIdDataTable(ldid, "dmid")
    criticalenter(OCRCriticalHandle[dmid])
    dm[dmid].UseDict(dictIndex)//切换字库
    dm[dmid].SetExactOcr(exact)//启动精确识别
    var retStr = dm[dmid].Ocr(x1, y1, x2, y2, color, sim)
    criticalleave(OCRCriticalHandle[dmid])
    return retStr
end
//根据字库找字
function _FindStr(ldid, dictIndex, exact, x1, y1, x2, y2, str, color, sim, &x, &y)
    var dmid = GetIdDataTable(ldid, "dmid")
    criticalenter(OCRCriticalHandle[dmid])
    dm[dmid].UseDict(dictIndex)//切换字库
    dm[dmid].SetExactOcr(exact)//启动精确识别
    var retIndex = dm[dmid].FindStr(x1, y1, x2, y2, str, color, sim, x, y)
    criticalleave(OCRCriticalHandle[dmid])
    return retIndex
end
//根据模型识字
function _OcrX(ldid, x1, y1, x2, y2, modelPath, sim)
    criticalenter(OCRXCriticalHandle)
    dllcall(getrcpath("rc:WmCode.dll"), "Long", "LoadWmFromFile", "char *", modelPath, "char *", "211914")
    dllcall(getrcpath("rc:WmCode.dll"), "Boolean", "SetWmOption", "long *", 3, "long *", 1)
    dllcall(getrcpath("rc:WmCode.dll"), "Boolean", "SetWmOption", "long *", 6, "long *", sim)
    var dmid = GetIdDataTable(ldid, "dmid")
    dm[dmid].Capture(x1, y1, x2, y2, sysPath & "OcrTemp.bmp")
    var ocrRet
    dllcall(getrcpath("rc:WmCode.dll"), "Boolean", "GetImageFromFile", "char *", sysPath & "OcrTemp.bmp", "pchar *", ocrRet)
    criticalleave(OCRXCriticalHandle)
    traceprint(ocrRet)
    return ocrRet
end
function StatusTryAction(ldid)
    //    if(OCR(ldid, 481, 282, 811, 344) == "状态异常")
    //        ExitSimulator(array(ldid, "状态异常,重新登陆."))
    //    end
    return true
end
function _FindColorEx(ldid, x1, y1, x2, y2, f, o)
    var retArr = array()
    var dmid = GetIdDataTable(ldid, "dmid")
    var result = dm[dmid].FindMultiColorEx(x1, y1, x2, y2, f, o, 0.97, 1)
    var len = dm[dmid].GetResultCount(result)
    for(var i = 0; i < len; i++)
        var x, y
        dm[dmid].GetResultPos(result, i, x, y)
        retArr[i] = array(x, y)
    end
    return retArr
end
//=============================================================================================
//=============================================================================================
//                               窗口截图
//
//		描述:
//			截图
//
//		返回值:
//			图片路径
//
//=============================================================================================
//=============================================================================================
function Screencap(ldid)
    var w, h
    if(ldid == "" || ldid == null)
        return getrcpath("rc:LD.jpg")
    end
    windowgetsize(ldInfo[ldid]["fatherHwnd"], w, h)
    //    var dmid = GetIdDataTable(ldid, "dmid")
    //    if(dmid != null)
    //        if(dm[dmid].Capture(1, 35, w - 37, h - 1, sysPath & "temp.bmp"))
    //            return sysPath & "temp.bmp"
    //        end
    //    end
    return getrcpath("rc:LD.jpg")
end
//=============================================================================================
//=============================================================================================
//                               通过特征码定位内存地址
//
//		描述:
//			截图
//
//		返回值:
//			图片路径
//
//=============================================================================================
//=============================================================================================
function FindRamAddr(ldid, featrueCode)
    //    var tempStr
    //    var len = strlen(featrueCode)
    //    for(var i = 0; i < len; i++)
    //        tempStr = tempStr & strsub(featrueCode, i, i + 2) & " "
    //        i++
    //    end
    //    var processHandle = information(ldInfo[ldid]["pid"], 2) 
    //    traceprint(processHandle)
    //    traceprint(tempStr)
    //    var addr = findbytearray(processHandle, tempStr, #4FC000, #ffffffff)
    //    return addr
end
//=============================================================================================
//=============================================================================================
//                               查找结果字符串转数组
//
//					找图,如果未找到就返array(-1,-1),找到返回坐标数组
//=============================================================================================
//=============================================================================================
function PosStrToArr(posArr)
    strsplit(posArr, "|", posArr)
    var len = arraysize(posArr)
    for(var i = 0; i < len; i++)
        strsplit(posArr[i], ",", posArr[i])
    end
    return posArr
end
//=============================================================================================
//=============================================================================================
//                                        冒泡排序
//=============================================================================================
//=============================================================================================
function BubbleSort(arr)
    var n       //存放数组a中元素的个数
    var i      //比较的轮数
    var j     //每轮比较的次数
    var buf  //交换数据时用于存放中间数据
    n = arraysize(arr) 
    for(i = 0; i < n - 1; i++)  //比较n-1轮
        for(j = 0; j < n - 1 - i; j++)  //每轮比较n-1-i次,
            if(arr[j] < arr[j + 1])
                buf = arr[j]
                arr[j] = arr[j + 1]
                arr[j + 1] = buf
            end
        end
    end
    return arr
end
//读取配置
function _ReadConfig(h1, h2)
    criticalenter(configCriticalHandle)
    var configPath = sysgetprocesspath() & "Config.ini"
    var fileValue = filereadini(h1, h2, configPath)
    criticalleave(configCriticalHandle)
    return fileValue
end
//读取配置
function _WriteConfig(h1, h2, value)
    criticalenter(configCriticalHandle)
    var configPath = sysgetprocesspath() & "Config.ini"
    var fileValue = filewriteini(h1, h2, value, configPath)
    criticalleave(configCriticalHandle)
    return fileValue
end
function ClientToScreenRect(ldid, &x1, &y1, &x2, &y2)
    var fatherHwnd = GetIdDataTable(ldid, "fatherHwnd")
    var xPos, yPos
    windowgetpos(fatherHwnd, xPos, yPos)
    x1 = x1 + xPos + 1
    y1 = y1 + yPos + 35
    x2 = x2 + xPos + 1
    y2 = y2 + yPos + 35
end
//
//	剪切板操作
//
function SetClipboard(ldid, str)
    criticalenter(clipboardCriticalHandle)
    windowactivate(GetIdDataTable(ldid, "fatherHwnd"))
    setclipboard(str)
    criticalleave(clipboardCriticalHandle)
end
function GetClipboard(ldid)
    criticalenter(clipboardCriticalHandle)
    windowactivate(GetIdDataTable(ldid, "fatherHwnd"))
    var ret = getclipboard()
    criticalleave(clipboardCriticalHandle)
    return ret
end