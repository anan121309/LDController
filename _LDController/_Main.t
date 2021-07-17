function _Main(ldid)
    //
    
    //=====================启动APP
    var temp_0 = StartLDApp(ldid)
    if(temp_0 != "Succ")
        return temp_0
    end
    //=====================启动APP结束
    
    
    
    select(mainTask)
        //=====================任务1
        case 0
        var ret = AutoLogin(ldid)
        if(ret != "Succ")
            return ret
        end
        
        //        //=====================任务2
        //        case 1
        //        var ret = StartLDTow(ldid)
        //        if(ret != "Succ")
        //            return ret
        //        end
        //        
        //        //=====================任务3
        //        case 2
        //        var ret = StartLDThree(ldid)
        //        if(ret != "Succ")
        //            return ret
        //        end
    end
    return "Succ"
end