function LD_Startup(ldid)
    TableUpdata(ldid, "主线程启动")
    var msg = _Main(ldid)
    TableUpdata(ldid, "主线程结束")
    ExitSimulator(array(ldid, msg))
end