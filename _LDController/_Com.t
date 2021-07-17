var dm = array()
function RegCom()
    var dmReg = isregister("dm.dmsoft")
    OutMsg("插件状态:" & dmReg)
    if(!dmReg)
        OutMsg("注册插件:" & regdll(getrcpath("rc:dm.dll"), true))
    end
    var tlReg = isregister("TURING.FISR")
    OutMsg("插件状态:" & tlReg)
    if(!tlReg)
        OutMsg("注册插件:" & regdll(getrcpath("rc:TURING.dll"), true))
    end
end
function CreateDMObject()
    RegCom()
    for(var i = 0; i < 30; i++)
        dm[i] = com("dm.dmsoft")
        var regRet = dm[i].Reg("", "")
        if(regRet)
            dm[i].SetShowErrorMsg(0)
            dm[i].SetDictPwd("211914aaa")
            dm[i].SetDict(0, getrcpath("rc:Gold.txt"))
            dm[i].SetDict(1, getrcpath("rc:Monitor.txt"))
            dm[i].SetDict(2, getrcpath("rc:PropsNum.txt"))
            dm[i].SetDict(3, getrcpath("rc:Fuel.txt"))
            dm[i].SetDict(4, getrcpath("rc:NavigetionGold.txt"))
            dm[i].SetDict(5, getrcpath("rc:PierStatus.txt"))
            dm[i].SetDict(6, getrcpath("rc:Pier_Status_tuohuang.txt"))
            dm[i].SetDict(7, getrcpath("rc:Pier_Status_maoxian.txt"))
            dm[i].SetDict(8, getrcpath("rc:Pier_Status_zhengfu.txt"))
            dm[i].SetDict(9, getrcpath("rc:Pier_Status_tansuo.txt"))
            dm[i].SetDict(10, getrcpath("rc:HomeGold.txt"))
            dm[i].SetDict(11, getrcpath("rc:ShipName.txt"))
            dm[i].SetDict(12, getrcpath("rc:Treasure.txt"))
            dm[i].SetDict(13, getrcpath("rc:UI.txt"))
            dm[i].SetDict(14, getrcpath("rc:航海_兑换_道具卡.txt"))
            dm[i].SetDict(15, getrcpath("rc:ItemName.txt"))
            dm[i].SetDict(16, getrcpath("rc:Num.txt"))
            dm[i].SetDict(17, getrcpath("rc:Assets.txt"))
            dm[i].SetDict(18, getrcpath("rc:背包数字.txt"))
            dm[i].SetDict(19, getrcpath("rc:FishPondStatus.txt"))//打鱼时候中文状态
            dm[i].SetDict(20, getrcpath("rc:Porn_Mul.txt"))//打鱼时候中文状态
            dm[i].SetDict(21, getrcpath("rc:TaskText.txt"))//任务列表字体
        end
    end
    return dm[0].GetMachineCode()
end