require 'lfs'

function createDB(imgLst, outname)
    if not paths.filep(imgLst) then
        print('ERROR: File does not exist: ' .. imgLst)
        exit(-1)
    end

    imgDB = {imgPaths={}, labels={}}
    for line in io.lines(imgLst) do
        table.insert(imgDB.imgPaths, line:split(' ')[1])
        table.insert(imgDB.labels, line:split(' ')[2])
    end
    print('Total: ' .. table.getn(imgDB.imgPaths) .. ' images in DB')

    -- Save DB obj
    local f = torch.DiskFile(outname, 'w')
    f:writeObject(imgDB)
    f:close()
end

createDB('square224_white_bg/imgLst_square224_white_bg.txt', 'db_square224_white_bg.t7')
