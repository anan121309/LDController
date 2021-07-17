//通过管道执行命令结果,禁止执行,带交互的命令,可能会卡死
//cmdstr 	执行的命令
//time_out	命令执行的超时时间,防止卡死
function pipecmd(cmdstr, time_out = 100000)
    var sa
    _SECURITY_ATTRIBUTES(sa)
    sa["nLength"]["value"] = structlen(sa)
    sa["bInheritHandle"]["value"] = true
    //创建管道
    var hRead, hWrite
    if(!CreatePipe(hRead, hWrite, sa, 0)) 
        traceprint(getlasterror(1))
        traceprint("创建管道失败")
        return ""
    end
    var si, pi
    _STARTUPINFOW(si)
    _PROCESS_INFORMATION(pi)
    si["cb"]["value"] = structlen(si)
    si["hStdError"]["value"] = hWrite
    si["hStdOutput"]["value"] = hWrite
    si["wShowWindow"]["value"] = 0
    si["dwFlags"]["value"] = #00000101
    //创建进程 与管道关联
    if(!CreateProcess(0, cmdstr, 0, 0, 1, 0, 0, 0, si, pi))
        traceprint(getlasterror(1))
        traceprint("创建进程失败")
        return ""
    end
    CloseHandle(hWrite)
    var nSize = 1024
    var buffer = new(1024)
    memset(buffer, 0, 1024 + 1)
    var nReadSize = 0
    var string
    var time1 = gettickcount()
    while(ReadFile(hRead, buffer, 1024, nReadSize, 0))
        //内存溢出
        if(nReadSize > 1024)
            break
        end
        //超时
        var time2 = gettickcount()
        if(time2 - time1 > time_out)
            break
        end            
        string = string & addressvalue(buffer, "char *")
        sleep(1, 0)
        memset(buffer, 0, 1024 + 1)
    end
    delete(buffer) //之前漏掉了这处代码,让程序有内存泄漏
    CloseHandle(hRead)
    return string
end
//申请内存地址
function new(nSize)
    var string = array()
    string["str"] = array("char" = nSize + 1, "value" = "")
    return structmalloc(string)
end
//释放内存
function delete(address)
    structfree(address)
end
//重置一段内存中值
function memset(address, value, nSize)
    return dllcall("kernel32.dll", "long", "RtlFillMemory", "long", address, "long", nSize, "long", value)
end
function _SECURITY_ATTRIBUTES(&SECURITY_ATTRIBUTES)
    SECURITY_ATTRIBUTES = array()
    SECURITY_ATTRIBUTES["nLength"] = 	array("long" = 0, "value" = 0)
    SECURITY_ATTRIBUTES["lpSecurityDescriptor"] = 	array("long" = 0, "value" = 0)
    SECURITY_ATTRIBUTES["bInheritHandle"] = 		array("long" = 0, "value" = 0)
end
function _STARTUPINFOW(&STARTUPINFOW)
    STARTUPINFOW = array()
    STARTUPINFOW["cb"] = 			array("long" = 0, "value" = 0)
    STARTUPINFOW["lpReserved"] = 	array("long" = 0, "value" = 0)
    STARTUPINFOW["lpDesktop"] = 	array("long" = 0, "value" = 0)
    STARTUPINFOW["lpTitle"] = 		array("long" = 0, "value" = 0)
    STARTUPINFOW["dwX"] = 			array("long" = 0, "value" = 0)
    STARTUPINFOW["dwY"] = 			array("long" = 0, "value" = 0)
    STARTUPINFOW["dwXSize"] = 		array("long" = 0, "value" = 0)
    STARTUPINFOW["dwYSize"] = 		array("long" = 0, "value" = 0)
    STARTUPINFOW["dwXCountChars"] = array("long" = 0, "value" = 0)
    STARTUPINFOW["dwYCountChars"] = array("long" = 0, "value" = 0)
    STARTUPINFOW["dwFillAttribute"] = array("long" = 0, "value" = 0)
    STARTUPINFOW["dwFlags"] = 		array("long" = 0, "value" = 0)
    STARTUPINFOW["wShowWindow"] = 	array("short" = 0, "value" = 0)
    STARTUPINFOW["cbReserved2"] = 	array("short" = 0, "value" = 0)
    STARTUPINFOW["lpReserved2"] = 	array("long" = 0, "value" = 0)
    STARTUPINFOW["hStdInput"] = 	array("long" = 0, "value" = 0)
    STARTUPINFOW["hStdOutput"] = 	array("long" = 0, "value" = 0)
    STARTUPINFOW["hStdError"] = 	array("long" = 0, "value" = 0)
end
function _PROCESS_INFORMATION(&PROCESS_INFORMATION)
    PROCESS_INFORMATION = array()
    PROCESS_INFORMATION["hProcess"] = 	array("long" = 0, "value" = 0)
    PROCESS_INFORMATION["hThread"] = 	array("long" = 0, "value" = 0)
    PROCESS_INFORMATION["dwProcessId"] = array("long" = 0, "value" = 0)
    PROCESS_INFORMATION["dwThreadId"] = array("long" = 0, "value" = 0)
end
//创建管道
function CreatePipe(&readPipe, &writePipe, &lpPipeAttributes, nSize)
    return dllcall("kernel32.dll", "long", "CreatePipe", "plong", readPipe, "plong", writePipe, "pstruct", lpPipeAttributes, "long", nSize)
end
//创建进程
function CreateProcess(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, &lpStartupInfo, &lpProcessInformation)
    return dllcall("kernel32.dll", "long", "CreateProcessW", "long", lpApplicationName, "wchar *", lpCommandLine, "long", lpProcessAttributes, "long", lpThreadAttributes, "long", bInheritHandles, "long", dwCreationFlags, "long", lpEnvironment, "long", lpCurrentDirectory, "pstruct", lpStartupInfo, "pstruct", lpProcessInformation)
end
//关闭句柄
function CloseHandle(handle)
    return dllcall("kernel32.dll", "long", "CloseHandle", "long", handle)
end
//读文件句柄,可以文件,管理,io这一系列的句柄内容
function ReadFile(hFile, lpBuffer, nNumberOfBytesToRead, &lpNumberOfBytesRead, lpOverlapped = 0)
    return dllcall("kernel32.dll", "long", "ReadFile", "long", hFile, "long", lpBuffer, "long", nNumberOfBytesToRead, "plong", lpNumberOfBytesRead, "long", lpOverlapped)
end