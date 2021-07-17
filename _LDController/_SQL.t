function SQL_Create()
    criticalenter(sqlCriticalHandle)
    var ret_arr
    var ret = sqlitesqlarray(sqlPath, "create table CargoList(ID integer primary key autoincrement,LDID varchar(100),key varchar(100),UNIQUE(key))", ret_arr)//创建表 
    if(!ret)
        traceprint(getlasterror(1))
    end
    criticalleave(sqlCriticalHandle)
end
function SQL_GetAll()
    criticalenter(sqlCriticalHandle)
    var ret_arr
    var sql = "select * from CargoList"
    var ret = sqlitesqlarray(sqlPath, sql, ret_arr) 
    if(!ret) 
        traceprint(getlasterror(1))
    end 
    criticalleave(sqlCriticalHandle)
    return ret_arr
end
function SQL_GetOne()
    criticalenter(sqlCriticalHandle)
    var sql = "select * from CargoList limit 1"
    var ret_arr
    var ret = sqlitesqlarray(sqlPath, sql, ret_arr) 
    if(!ret) 
        traceprint(getlasterror(1))
    end 
    criticalleave(sqlCriticalHandle)
    return ret_arr
end
//function SQL_Insert(ldid, name, cannedFishCode)
//    var err
//    var ret = sqlitesqlarray(sqlPath, "insert into MakeCan values(null,\'" & ldid & "\',\'" & name & "\',\'" & cannedFishCode & "\');", null) 
//    if(!ret) 
//        traceprint(getlasterror(err))
//    end 
//end
//function SQL_Update(ldid, cannedFishCode)
//    var err
//    var ret = sqlitesqlarray(sqlPath, "update MakeCan set cannedFishCode=\'" & cannedFishCode & "\' where ldid=\'" & ldid & "\'", null) 
//    if(!ret) 
//        traceprint(getlasterror(err))
//    end 
//end
function SQL_Replace(ldid, key)
    criticalenter(sqlCriticalHandle)
    var sql = "replace into CargoList(LDID, key) values (\"" & ldid & "\", \"" & key & "\");"
    var ret_arr
    var ret = sqlitesqlarray(sqlPath, sql, ret_arr) 
    if(!ret) 
        traceprint(getlasterror(1))
    end 
    criticalleave(sqlCriticalHandle)
end
function SQL_Delete(id)
    criticalenter(sqlCriticalHandle)
    var ret = sqlitesqlarray(sqlPath, "delete from CargoList where id=\'" & id & "\'", null) 
    if(!ret) 
        traceprint(getlasterror(1))
    end 
    criticalleave(sqlCriticalHandle)
end
function SQL_Count() 
    criticalenter(sqlCriticalHandle)
    var countArr = array(array("count(*)" = -1))
    var ret = sqlitesqlarray(sqlPath, "select count(*) from CargoList", countArr) 
    if(!ret) 
        traceprint(getlasterror(1))
    end
    var count = countArr[0]["count(*)"]
    criticalleave(sqlCriticalHandle)
    return count
end