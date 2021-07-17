var ipAddr = "http://mylm911.com:5010"
var localVersion = "3.9.2.0"
var downloadUrl
function ShowGG()
    var G = array()
    G[0] = "\n1.改善捕鱼任务领取流程,现在稳定领取奖励!"
    G[1] = "\n2.取消背包上传数据代码段,需要的私聊我.我再加上!"
    G[2] = "\n3.更改换船BUG"
    G[3] = "\n"
    G[4] = "\n"
    staticsettext("GG", G[0] & G[1] & G[2] & G[3] & G[4] & G[5] & G[6])
end
function Verify()
    threadbegin("VerifyTH", machineCode)
    var serverVersion = GetVersion()
    if(serverVersion != localVersion || serverVersion == "")
        downloadUrl = GetDownload()
        setclipboard(downloadUrl)
        threadbegin("ExitTh", "")
        messagebox("前往下载!\n\n下载地址已复制到剪切板,如果打开浏览器失败,请手动复制到浏览器进行下载!", "检测到一个新版本:")
        cmd(downloadUrl, true)
    end
    //判断剩余时长
    var arr = InquireUserRemainingTime(machineCode)
    if(isarray(arr))
        if(arr["id"] == null || arr["id"] == "")
            threadbegin("ExitTh", "")
            controlshow("MachineCodeEdit", true)
            controlshow("static11", true)
            staticsettext("static13", "请先注册,机器码已复制到剪切板!")
            staticsettext("GG", "")
            editsettext("MachineCodeEdit", machineCode)
            return false
        end
    else
        controlshow("MachineCodeEdit", true)
        controlshow("static11", true)
        staticsettext("static13", "网络环境错误,请检查网络设置!")
        staticsettext("GG", "")
        editsettext("MachineCodeEdit", machineCode)
        threadbegin("ExitTh", "")
        return false
    end
    if(!isdatetime(arr["remainingTime"]))
        threadbegin("ExitTh", "")
        controlshow("MachineCodeEdit", true)
        controlshow("static11", true)
        staticsettext("static13", "数据非法,请勿违规操作!")
        staticsettext("GG", "")
        editsettext("MachineCodeEdit", machineCode)
        return false
    end
    var diffTime = timediff("h", timenow(), arr["remainingTime"])
    if(diffTime < 0)
        threadbegin("ExitTh", "")
        setclipboard(machineCode)
        controlshow("MachineCodeEdit", true)
        controlshow("static11", true)
        staticsettext("static13", "用户时长已不足,机器码已复制到剪切板!")
        staticsettext("GG", "")
        editsettext("MachineCodeEdit", machineCode)
        return false
    else
        user = arr
    end
    var windowTitle = windowgetcaption(windowgetmyhwnd())
    windowsetcaption(windowgetmyhwnd(), windowTitle & " v" & localVersion & " 用户名: " & user["username"] & " 到期时间: " & user["remainingTime"])
    return true
end
function VerifyTH()
    while(1)
        sleep(60000)
        var time = timediff("n", timenow(), user["remainingTime"])
        if(cint(time) < 0)
            WriteConfig()
            CloseProcess()
        end
    end
end
//获取该机器吗用户到期时间
function InquireUserRemainingTime(_machineCode)
    var post_url = ipAddr & "/User/InquireUserRemainingTime"
    var senddata = "{\"user\":{\"machineCode\":\"" & _machineCode & "\"}}"
    var ret
    var post_ret = httpsubmit("post", post_url, senddata, "utf-8", array("Content-Type" = "application/json;charset=utf-8"), ret)
    var retArr = jsontoarray(post_ret)
    return retArr
end
//获取版本号
function GetVersion()
    var post_url = ipAddr & "/File/version"
    var senddata = ""
    var post_ret = httpsubmit("get", post_url, senddata, "utf-8", array(), null)
    return post_ret
end
//获取下载地址
function GetDownload()
    var post_url = ipAddr & "/File/download"
    var senddata = ""
    var post_ret = httpsubmit("get", post_url, senddata, "utf-8", array(), null)
    return post_ret
end
function ExitTh()
    sleep(20000)
    CloseProcess()
    exit()
end