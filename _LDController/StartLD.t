
//启动雷电游戏中心
function StartLDApp(ldid)
    var f, o, x, y
    
    //找雷电游戏中西
    f = "f0c427-000000|000000-000000|f4c51f-000000|f4c51f-000000"
    o = "f0c427,5|4|000000,1|12|f4c51f,9|12|f4c51f"
    _LoopFindColor(ldid, 349, 144, 366, 162, f, o, x, y, 10, true)
    return "Succ"
end
function AutoLogin(ldid)
    var f, o, x, y
    //这一步是点击登陆
    f = "eeeeee-000000|050606-000000|eeeeee-000000|040505-000000"
    o = "eeeeee,9|0|050606,-1|8|eeeeee,5|9|040505"
    _LoopFindColor(ldid, 1237, 30, 1258, 46, f, o, x, y, 20, true)
    
    //点击账号框
    f = "54565c-000000|292c33-000000|54565c-000000|292c33-000000"
    o = "54565c,3|0|292c33,0|3|54565c,3|4|292c33"
    _LoopFindColor(ldid, 657, 305, 671, 320, f, o, x, y, 20, true)
    
    //输入账号
    _TextInput(ldid, 1213095357)
    
    //点击密码框
    f = "505258-000000|292c33-000000|474a50-000000|292c33-000000"
    o = "505258,5|-1|292c33,-1|2|474a50,4|3|292c33"
    _LoopFindColor(ldid, 572, 355, 601, 370, f, o, x, y, 20, true)
    
    //输入密码
    _TextInput(ldid, 1213095357)
    sleep(1000 * 20)
    return "Succ"
end