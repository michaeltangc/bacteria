require '../../cnn/util'

function create_testDB(imgLst)
    local testDB = {}
    for line in io.lines(imgLst) do
        table.insert(testDB, {imgPath=line})
    end
    save_obj('testDB/' .. imgLst:sub(1,imgLst:find('/')-1) .. '.t7', testDB) -- % is to escape special char
end

for i=2,31 do
    create_testDB(string.format('5_900%02d/test_5_900%02d.txt', i,i))
end

