A_Instructions = {
    SP = 0,
    LCL = 1,
    ARG = 2,
    THIS = 3,
    THAT = 4,
    SCREEN = 16384,
    KBD = 24576
}

C_instrictions = {
    comp = {
        ['0'] = '101010',
        ['1'] = '111111',
        ['-1'] = '111010',
        D = '001100',
        A = '110000',
        ['!D'] = '001101',
        ['!A'] = '110001',
        ['-D'] = '001111',
        ['-A'] = '110011',
        ['D+1'] = '011111',
        ['A+1'] = '110111',
        ['D-1'] = '001110',
        ['A-1'] = '110010',
        ['D+A'] = '000010',
        ['D-A'] = '010011',
        ['A-D'] = '000111',
        ['D&A'] = '000000',
        ['D|A'] = '010101'
    },
    dest = {
        [''] = '000',
        ['M'] = '001',
        ['D'] = '010',
        ['DM'] = '011',
        ['A'] = '100',
        ['AM'] = '101',
        ['AD'] = '110',
        ['ADM'] = '111',
        ['MD'] = '011'
    },
    jump = {
        [''] = '000',
        JGT = '001',
        JEQ = '010',
        JGE = '011',
        JLT = '100',
        JNE = '101',
        JLE = '110',
        JMP = '111'
    }
}
function To16bitbinary(number)
    local bits = '0'
    for i = 14, 0, -1 do
        if number > 2 ^ i - 1 then
            number = number - 2 ^ i
            bits = bits .. '1'
        else
            bits = bits .. '0'
        end
    end
    return bits
end

function Convert_Ainstruction(a)
    --Check if R0-15, Ainstruction, Address, or Variable
    if tonumber(string.sub(a, 2, -1)) then
        return To16bitbinary(tonumber(string.sub(a, 2, -1)))
    else if tonumber(string.sub(a, 3, -1)) and string.sub(a, 2, 2) == 'R' then
            return To16bitbinary(tonumber(string.sub(a, 3, -1)))
        else
            for key, values in pairs(A_Instructions) do
                if string.sub(a, 2, -1) == key then
                    return To16bitbinary(values)
                end
            end
            A_Instructions[string.sub(a, 2, -1)] = V_Values + 1
            V_Values = V_Values + 1
            return To16bitbinary(A_Instructions[string.sub(a, 2, -1)])
        end
    end
end

function Convert_Cinstruction(a)
    --Split the instruction into 3 parts: the comp_parts, dest_parts, and jump_parts
    local comp_parts = ''
    local dest_parts = ''
    local jump_parts = ''
    for i = 1, #a do
        if string.sub(a, i, i) == ';' then
            jump_parts = string.sub(a, i + 1, -1)
            comp_parts = string.sub(a, 1, i - 1)
        end
        if string.sub(a, i, i) == '=' then
            dest_parts = string.sub(a, 1, i - 1)
            comp_parts = string.sub(a, i + 1, -1)
        end
    end
    Bits = { '111' }
    for key1, value1 in pairs(C_instrictions) do
        -- key1: dest,comp,jump
        for key2, value2 in pairs(C_instrictions[key1]) do
            if key1 == 'dest' then
                if key2 == dest_parts then
                    Bits[3] = value2
                end
            else if key1 == 'comp' then
                    if key2 == comp_parts then
                        local no = '0' .. value2
                        Bits[2] = no
                    else if key2 == string.gsub(comp_parts, 'M', 'A') then
                            local no = '1' .. value2
                            Bits[2] = no
                        end
                    end
                else if key1 == 'jump' then
                        if key2 == jump_parts then
                            Bits[4] = value2
                        end
                    end
                end
            end
        end
    end
    Completed_Bits = ''
    for i = 1, 4 do
        Completed_Bits = Completed_Bits .. Bits[i]
    end
    return Completed_Bits
end

require "lfs"

File_output_name = string.sub(arg[2], 1, -4) .. 'hack'
lfs.chdir(arg[1])
--remove 0D

File = io.open(arg[2], 'rb')
Parsed = string.gsub(File:read('*a'), "\r\n", "\n")
File:close()

--Create the Dothack file
Dothack = io.open(File_output_name, 'w')
Dothack:write(Parsed)
Dothack:close()

--lines
PureInstructions = ''
Dothack = io.open(File_output_name, 'r')
Lines = Dothack:lines()
for line in Lines do
    if line ~= '' and string.sub(line, 1, 2) ~= '//' then
        for i = 1, #line do
            if string.sub(line, i, i) ~= ' ' then
                if string.sub(line, i, i + 1) == '//' then
                    break
                end
                PureInstructions = PureInstructions .. string.sub(line, i, i)
            end
        end
        PureInstructions = PureInstructions .. '\n'
    end
end
PureInstructions = string.sub(PureInstructions, 1, -2)
-- print(PureInstructions)
Dothack:close()

Dothack = io.open(File_output_name, 'w')
Dothack:write(PureInstructions)
Dothack:close()

--Adds line numbers and labels to Ainstructions
Dothack = io.open(File_output_name, 'r')
Lines = Dothack:lines()
Line_number = 0
V_Values = 15
for line in Lines do
    if string.sub(line, 1, 1) ~= '(' then
        Line_number = Line_number + 1
    else
        A_Instructions[string.sub(line, 2, -2)] = Line_number
    end
end
Dothack:close()

Machinecode = ''

--Assembles to Machinecode
Dothack = io.open(File_output_name, 'r')
Lines = Dothack:lines()
for line in Lines do
    if string.sub(line, 1, 1) == '@' then
        Machinecode = Machinecode .. Convert_Ainstruction(line) .. '\n'
    else if string.sub(line, 1, 1) ~= '(' then
            Machinecode = Machinecode .. Convert_Cinstruction(line) .. '\n'
        end
    end
end
Machinecode = string.sub(Machinecode, 1, -2)
Dothack:close()
Dothack = io.open(File_output_name, 'w')
Dothack:write(Machinecode)
Dothack:close()
