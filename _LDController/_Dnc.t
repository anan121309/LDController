//为适应ld.exe的命令,除获取模拟器信息此条命令外,其他命令全部改写成基于模拟器序号,序号可由获取模拟器信息此条命令获取
//本人只封装了个人认为比较常用的命令,如果你需要的命令没有,可以自己去扩展,或联系本人QQ:1104573225,欢迎学习交流及定制脚本
var ldInfo = array()	//获取雷电信息函数
var lastSimulator	//最后一个模拟器
var tabInfo = array()
function dncCmd(cmdStr)
    criticalenter(ldCmdCriticalHandle)
    if(dncPath == "")
        GetDncPath()
    end
    cmdStr = dncPath & cmdStr
    var pipRet = pipecmd(cmdStr)
    criticalleave(ldCmdCriticalHandle)
    return pipRet
end
var dncPath = ""
function GetDncPath()
    dncPath = reggetvalue("HKEY_CURRENT_USER\\Software\\ChangZhi2\\dnplayer", "InstallDir") & "dnconsole.exe"
end
function StartDnc(index)
    //&" --resolution 1280,720,240"
    var parma
    parma = " modify --index " & cstring(index) & " --resolution 1280,720,240 --cpu 1 --memory 1024"
    dncCmd(parma)
    parma = " launch --index " & cstring(index)
    dncCmd(parma)
end
function StartApp(index, packName)
    dncCmd(" runapp --index " & cstring(index) & " --packagename " & packName)
end
function GetDncInfo()
    var retarr
    strsplit(dncCmd(" list2"), "\r\n", retarr)
    var len = arraysize(retarr) - 1
    //    for(var i = 1; i < len && (i < cint(user["status"]) + 1); i++)
    for(var i = 1; i < len; i++)
        strsplit(retarr[i], ",", retarr[i])
        var id = retarr[i][0]
        tabInfo[i] = id
        ldInfo[id] = array()
        ldInfo[id]["index"] = i
        ldInfo[id]["id"] = retarr[i][0]
        ldInfo[id]["name"] = retarr[i][1]
        ldInfo[id]["fatherHwnd"] = retarr[i][2]
        ldInfo[id]["hwnd"] = retarr[i][3]
        ldInfo[id]["isRun"] = retarr[i][4]
        ldInfo[id]["pid"] = retarr[i][6]
        //最后一个模拟器
        lastSimulator = id
    end
end
//获取所有雷电是否退出
function GetAllLdIsExit()
    var count
    GetDncInfo()
    for(var i = 0; i < lastSimulator; i++)
        if(isarray(ldInfo[i]))
            if(ldInfo[i]["isRun"])
                count++
            end
        end
    end
    if(count > 0)
        return false
    else
        return true
    end
end
function ReStartDncAndApp(index, packName = "null")
    dncCmd(" action --index " & cstring(index) & " --key call.reboot --value " & packName)
end
function CloseApp(index, packName)
    dncCmd(" killapp --name " & cstring(index) & " --packagename " & packName)
end
function DownCPU(index, value)
    //取值范围0-99  取值为0 表示关闭CPU优化. 这个值越大表示降低CPU效果越好
    dncCmd(" downcpu --index " & cstring(index) & " --rate " & cstring(value))
end
function CopyDnc(dncIndex, copyDncIndex)
    dncCmd(" copy --index " & cstring(dncIndex) & " --from " & cstring(copyDncIndex))
end
function DelDnc(index)
    dncCmd(" remove --index " & cstring(index))
end
function ModifyDncInfo(index)
    var retarr = RandDeviceInfo()
    dncCmd(" modify --index " & cstring(index) & " --manufacturer " & retarr[0] & " --model " & retarr[1] & " --imei " & retarr[2] & " --androidid auto --mac auto")  
end
function CloseDnc(index)
    dncCmd(" quit --index " & cstring(index))
end
function RestoreDnc(index, path)
    dncCmd(" restore --index " & cstring(index) & " --file " & path)
end
function ModifyPosition(index, coordinate)
    dncCmd(" action --index " & cstring(index) & " --key call.locate --value " & coordinate)
end
function _TextInput(index, intputstr)
    dncCmd(" action --index " & cstring(index) & " --key call.input --value " & intputstr)
end
function AndroidPress(index, key)//back/home/menu/volumeup/volumedown 
    dncCmd(" action --index " & cstring(index) & " --key call.keyboard --value " & key)
end
function RandDeviceInfo()
    var imei = -1
    var randomModel = rnd(0, 9)
    var retarr = array()
    select(randomModel)
        case 0//酷派cool1
        imei = array(8, 6, 1, 7, 9, 5, 0, 3)
        retarr[0] = "Coolpad"
        retarr[1] = "C106"
        case 1//小米5
        imei = array(8, 6, 2, 2, 5, 8, 0, 3)
        retarr[0] = "MI"
        retarr[1] = "MI 5"
        case 2//华为荣耀7
        imei = array(8, 6, 7, 6, 8, 9, 0, 2)
        retarr[0] = "Honor"
        retarr[1] = "PLK-TL01H"
        case 3//魅族pro5
        imei = array(8, 6, 7, 9, 0, 5, 0, 2)
        retarr[0] = "MEIZU"
        retarr[1] = "M576"
        case 4//锤子M1
        imei = array(9, 9, 0, 0, 0, 7, 1, 7)
        retarr[0] = "smartisan"
        retarr[1] = "M1"
        case 5//魅族pro6
        imei = array(8, 6, 9, 0, 1, 6, 0, 2)
        retarr[0] = "MEIZU"
        retarr[1] = "M570Q"
        case 6//一加3T
        imei = array(8, 6, 2, 5, 6, 1, 0, 3)
        retarr[0] = "One Plus"
        retarr[1] = "A3010"
        case 7//努比亚Z9mini
        imei = array(8, 6, 6, 7, 6, 9, 0, 2)
        retarr[0] = "nubia"
        retarr[1] = "NX511J"
        case 8//vivo X7
        imei = array(8, 6, 3, 1, 8, 7, 0, 3)
        retarr[0] = "VIVO"
        retarr[1] = "X7"
        case 9//小米4lte
        imei = array(8, 6, 7, 8, 2, 6, 0, 2)
        retarr[0] = "MI"
        retarr[1] = "MI4 LTE"
    end
    var even = array(), EvenBitDigitSum = array()
    var oddSum, evenSum, checkValue, imeiCode, tenDigits, oneDigit
    imeiCode = ""
    for(var i = 8; i < 14; i++)
        imei[i] = rnd(0, 9)
    end
    for(var i = 0; i < 7; i++)
        oddSum = oddSum + imei[i * 2]
        even[i] = imei[i * 2 + 1] * 2
        even[i] = cstring(even[i])
        if(strlen(even[i]) == 2)
            tenDigits = strleft(even[i], 1)
            oneDigit = strright(even[i], 1)
            EvenBitDigitSum[i] = cint(tenDigits) + cint(oneDigit)
        else
            EvenBitDigitSum[i] = cint(even[i])
        end
        evenSum = evenSum + EvenBitDigitSum[i]
    end
    for(var i = 0; i < 14; i++)
        imei[i] = cstring(imei[i])
        imeiCode = imeiCode & imei[i]
    end
    checkValue = strright(cstring(oddSum + evenSum), 1)
    if(checkValue == 0)
        imeiCode = cstring(checkValue)
    else
        checkValue = 10 - cint(checkValue)
    end
    imeiCode = imeiCode & cstring(checkValue)
    if(strlen(imeiCode) == 15)
        retarr[2] = imeiCode
        return retarr
    else
        return RandDeviceInfo()
    end
end
//
//
var ldPath = ""
function ldCmd(cmdStr)
    if(ldPath == "")
        GetLDPath()
    end
    cmdStr = ldPath & cmdStr
    return pipecmd(cmdStr)
end
function GetLDPath()
    ldPath = reggetvalue("HKEY_CURRENT_USER\\Software\\ChangZhi2\\dnplayer", "InstallDir") & "ld.exe"
end
function ClearAppData(index, packName)
    ldCmd(" -s " & cstring(index) & " pm clear " & packName)
end
function Press(index, key)
    ldCmd(" -s " & cstring(index) & " input keyevent " & cstring(key))
end
function Click(index, x, y)
    ldCmd(" -s " & cstring(index) & " input tap " & cstring(x) & " " & cstring(y))
end
function Slide(index, x1, y1, x2, y2)
    ldCmd(" -s " & cstring(index) & " input swipe " & cstring(x1) & " " & cstring(y1) & " " & cstring(x2) & " " & cstring(y2))
end