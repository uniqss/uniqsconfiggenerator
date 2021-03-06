local utility = require("utility")

local outputDir = "gen_go"
local goFile = nil

local function writeln(str)
    if str ~= nil then
        goFile:write(str, "\n")
    else
        goFile:write("\n")
    end
end
local function transType(ctype)
    if ctype == "uint32" then
        return "uint32"
    elseif ctype == "string" then
        return "string"
    elseif ctype == "repeated string" then
        return "[]string"
    elseif ctype == "repeated uint32" then
        return "[]uint32"
    elseif ctype == "float" then
        return "float64"
    elseif ctype == "repeated float64" then
        return "[]float"
    else
        print("type unrecogonized:"..ctype)
    end
end
local function getTypeDefault(ctype)
    if ctype == "uint32" then
        return "0"
    elseif ctype == "float" then
        return "0"
    elseif ctype == "string" then
        return "\"\""
    elseif ctype == "repeated string" then
        return "nil"
    elseif ctype == "repeated uint32" then
        return "nil"
    elseif ctype == "repeated float64" then
        return "nil"
    else
        print("type unrecogonized:"..ctype)
    end
end

function JustPrint(xlsxName, sheetName, vecDatas)
    print("###JustPrint  xlsxName:" .. xlsxName)
    print("###JustPrint  sheetName:" .. sheetName)
    return 0
end

function ProcessOneSheetAllData(xlsxName, sheetName, vecDatas)
    print("xlsxName:" .. xlsxName)
    print("sheetName:" .. sheetName)
    -- utility.PrintTable1(vecDatas[1])
    -- utility.PrintTable2(vecDatas);
    return ProcessOneSheet(xlsxName, sheetName, vecDatas[2], vecDatas[3], vecDatas[5])
end

function AfterFunction1(sheetNames)
    utility.PrintTable1(sheetNames)
    return 0
end

function CallGoFormatDirectory(sheetNames)
    utility.PrintTable1(sheetNames)
    
    local filePath = "./"..outputDir.."/"
    
    gofmtCmd = "gofmt.exe -w "..filePath
    os.execute(gofmtCmd)
    print("gofmtCmd:"..gofmtCmd)
    return 0
end

function ProcessOneSheet(xlsxName, sheetName, vecNames, vecTypes, vecDescriptions)
    --[[
    print("xlsxName:" .. xlsxName)
    print("sheetName:" .. sheetName)
    utility.PrintTable1(vecNames)
    utility.PrintTable1(vecTypes)
    utility.PrintTable1(vecDescriptions)
    --]]

    utility.createDirIfNotExists(outputDir)

    -- 取count的最小值
    local count1 = utility.tablelength(vecNames)
    local count2 = utility.tablelength(vecTypes)
    local count3 = utility.tablelength(vecDescriptions)
    local count = math.min(count1, count2)
    count = math.min(count, count3)

    local filePath = "./"..outputDir.."/" ..sheetName..".go"

    goFile = io.open(filePath, "w+")
    if goFile == nil then
        print("filePath:"..filePath.." goFile == nil")
    else
        --print("filePath:"..filePath.." goFile not nil")
    end

    writeln("// Code generated by little bull tool. DO NOT EDIT!!!")
    writeln()
    writeln("package DataTables")
    writeln()
    writeln("type "..sheetName.." struct {")

    for idx=1,count do
        local cname = vecNames[idx]
        local ctype = vecTypes[idx]
        if cname ~= nil and cname ~= "" and ctype ~= nil and ctype ~= "" then
            ctype = transType(ctype)
            local cdesc = vecDescriptions[idx]
            writeln("\t"..utility.CamelCase(cname).." "..ctype.."  `db:\""..cname.."\"` // "..cdesc)
        end
    end
    writeln("}")
    writeln()

    for idx = 1, count do
        --[[
func (m *DT_Hero_Nature_Config) GetQiRate() []uint32 {
	if m != nil {
		return m.QiRate
	}
	return nil
}
        --]]
        local cname = utility.CamelCase(vecNames[idx])
        local ctype = vecTypes[idx]
        if cname ~= nil and cname ~= "" and ctype ~= nil and ctype ~= "" then
            ctype = transType(ctype)
            writeln("func (m *"..sheetName..") Get"..cname.."() "..ctype.." {")
            writeln("\tif m != nil {")
            writeln("\t\treturn m."..cname)
            writeln("\t}")
            writeln("\treturn "..getTypeDefault(vecTypes[idx]))
            writeln("}")
            writeln()
        end
    end
    writeln()

    writeln("type "..sheetName.."_Data struct {")

    writeln("\t"..sheetName.."Items map[uint32]*"..sheetName.."")

    writeln("}")
    writeln()

    writeln("func (dt *"..sheetName.."_Data) MakeMap(){")

    writeln("\tdt."..sheetName.."Items = make(map[uint32]*"..sheetName..")")

    writeln("}")
    writeln()

    writeln("func init() {")
    writeln("\tregister(\""..sheetName.."\", &"..sheetName.."_Data{}, &"..sheetName.."{})")
    writeln("}")
    writeln()

    writeln("func (dt *"..sheetName..")FromData(data []interface{}) {")
    local realIdx = 0
    for idx = 1, count do
        local cname = utility.CamelCase(vecNames[idx])
        local ctype = vecTypes[idx]
        if cname ~= nil and cname ~= "" and ctype ~= nil and ctype ~= "" then
            ctype = transType(ctype)
            if ctype == "uint32" then
                writeln("\tdt."..cname.." = DataTableReadUInt32(data, \""..cname.."\", "..realIdx..", \""..sheetName.."\")")
            elseif ctype == "string" then
                writeln("\tdt."..cname.." = DataTableReadString(data, \""..cname.."\", "..realIdx..", \""..sheetName.."\")")
            elseif ctype == "float" then
                writeln("\tdt."..cname.." = DataTableReadFloat(data, \""..cname.."\", "..realIdx..", \""..sheetName.."\")")
            elseif ctype == "[]uint32" then
                writeln("\tdt."..cname.." = DataTableReadUInt32Arr(data, \""..cname.."\", "..realIdx..", \""..sheetName.."\")")
            elseif ctype == "[]string" then
                writeln("\tdt."..cname.." = DataTableReadStringArr(data, \""..cname.."\", "..realIdx..", \""..sheetName.."\")")
            elseif ctype == "[]float" then
                writeln("\tdt."..cname.." = DataTableReadFloatArr(data, \""..cname.."\", "..realIdx..", \""..sheetName.."\")")
            end
            realIdx = realIdx + 1
        end
    end
    writeln()
    writeln("\tGet"..sheetName.."()."..sheetName.."Items[dt.Id] = dt")
    writeln("}")
    writeln()

    writeln("func Get"..sheetName.."() *"..sheetName.."_Data {")
    writeln("\treturn get(\""..sheetName.."\").(*"..sheetName.."_Data)")
    writeln("}")

    io.close(goFile)

    return 0
end
