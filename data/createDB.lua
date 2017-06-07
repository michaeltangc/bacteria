require 'lfs'

function createDB(imgLst, outname)
    if not paths.filep(imgLst) then
        print('ERROR: File does not exist: ' .. imgLst)
        exit(-1)
    end

    imgDB = {}
    for line in io.lines(imgLst) do
        table.insert(imgDB, {imgPath=line:split(' ')[1], label=line:split(' ')[2]})
    end
    print('Total: ' .. table.getn(imgDB) .. ' images in DB')

    -- Save DB obj
    local f = torch.DiskFile(outname, 'w')
    f:writeObject(imgDB)
    f:close()
end

createDB('square224/imgLst_square224.txt', 'db_square224.t7')
