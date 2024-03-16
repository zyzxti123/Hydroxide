local methods = {}

local function handleSpecialString(value, indentation)
    local output = {}
	local index = 1
	local char = string.sub(value, index, index)
	local indentStr

	while char ~= "" do

		if char == '"' then
			output[index] = '\\"'
		elseif char == "\\" then
			output[index] = "\\\\"
		elseif char == "\n" then
			output[index] = "\\n"
		elseif char == "\t" then
			output[index] = "\\t"
		elseif string.byte(char) > 126 or string.byte(char) < 32 then
			output[index] = string.format("\\%d", string.byte(char))
		else
			output[index] = char
		end

		index = index + 1
		char = string.sub(value, index, index)

		if index % 200 == 0 then
			table.move({ '"\n', indentStr, '... "' }, 1, 3, index, output)
			index += 3
		end
	end

	return table.concat(output)
end

local function tableToString(data, root, indents)
    local dataType = type(data)

    if dataType == "userdata" then
        return (typeof(data) == "Instance" and getInstancePath(data)) or userdataValue(data)
    elseif dataType == "string" then
        return ('"%s"'):format(handleSpecialString(data))
    elseif dataType == "table" then
        indents = indents or 1
        root = root or data

        local head = '{\n'
        local elements = 0
        local indent = ('\t'):rep(indents)
        
        for i,v in pairs(data) do
            if i ~= root and v ~= root then
                head = head .. ("%s[%s] = %s,\n"):format(indent, tableToString(i, root, indents + 1), tableToString(v, root, indents + 1))
            else
                head = head .. ("%sOH_CYCLIC_PROTECTION,\n"):format(indent)
            end

            elements = elements + 1
        end
        
        if elements > 0 then
            return ("%s\n%s"):format(head:sub(1, -3), ('\t'):rep(indents - 1) .. '}')
        else
            return "{}"
        end
    end

    return tostring(data)
end

local function compareTables(x, y)
    for i, v in pairs(x) do
        if v ~= y[i] then
            return false
        end
    end

    return true
end

methods.tableToString = tableToString
methods.compareTables = compareTables
methods.handleSpecialString = handleSpecialString

return methods
