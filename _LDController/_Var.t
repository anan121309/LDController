var sysPath
var sqlPath
var user
var machineCode
//====================================状态变量================================
var bindMode
var mainTask
var openMax = 1
var openPoint = 0	
var openCount = 0			
var simulatorExitStatus		 //模拟器退出时标志变量
var simulatorStartIng = false
//=====================================临界区句柄变量
var sqlCriticalHandle           //数据库临界区
var ldCmdCriticalHandle         //雷电命令临界区
var configCriticalHandle        //配置临界区
var UICriticalHandle            //UI临界区
var ReadImageCriticalHandle     //读取图片临界区
var orderNumberCriticalHandle			//图灵临界区
var OCRXCriticalHandle   
var InputCargoListCriticalHandle    //输入产品清单临界区句柄
var clipboardCriticalHandle         //剪切板临界区句柄
var OCRCriticalHandle = array()
function Init_Var()
    ldCmdCriticalHandle = criticalcreate()
    sqlCriticalHandle = criticalcreate()
    configCriticalHandle = criticalcreate()
    UICriticalHandle = criticalcreate()
    ReadImageCriticalHandle = criticalcreate()
    orderNumberCriticalHandle = criticalcreate()
    OCRXCriticalHandle = criticalcreate()
    InputCargoListCriticalHandle = criticalcreate()
    clipboardCriticalHandle = criticalcreate()
    //创建30个不同的临界区,多dm Object 互不干扰!
    for(var i = 0; i < 30; i++)
        OCRCriticalHandle[i] = criticalcreate()
    end
    sysPath = sysgetprocesspath()
    sqlPath = sysPath & "LDController.db"
    select(combogetcursel("BindModeCombobox"))
        case 0
        bindMode = "gdi"
        case 1
        bindMode = "dx.graphic.opengl"
    end 
end