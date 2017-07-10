require 'lfs'

function createDB_val(fList,train_list_fname,  val_list_fname, outname, val_step)
    ftrain_list = io.open(train_list_fname, 'w')
    fval_list = io.open(val_list_fname, 'w')

    -- prefix = '/home/bingbin/bacteria/data/square224/'
    prefix = './square224/'
    trainDB = {imgPaths={}, labels={}}
    valDB = {imgPaths={}, labels={}}
    for i=1,#fList do
        imgLst = fList[i]
        if not paths.filep(imgLst) then
            print('ERROR: File does not exist: ' .. imgLst)
            exit(-1)
        end
    
        cnt = 0
        for line in io.lines(imgLst) do
            cnt = cnt+1
            if cnt == val_step then
                table.insert(valDB.imgPaths, prefix .. line:split(' ')[1])
                table.insert(valDB.labels, line:split(' ')[2])
                if line:find('noise') then
                    fval_list:write(prefix .. line:split(' ')[1] .. ':0\n')
                else
                    fval_list:write(prefix .. line:split(' ')[1] .. ':1\n')
                end
                cnt = 0
            else
                table.insert(trainDB.imgPaths, prefix .. line:split(' ')[1])
                table.insert(trainDB.labels, line:split(' ')[2])
                if line:find('noise') then
                    ftrain_list:write(prefix .. line:split(' ')[1] .. ':0\n')
                else
                    ftrain_list:write(prefix .. line:split(' ')[1] .. ':1\n')
                end
            end
        end
        print('#' .. i .. ': ' .. #trainDB.imgPaths+#valDB.imgPaths .. ' images after adding in ' .. imgLst)
    end

    -- Save DB objs
    local f = torch.DiskFile(outname, 'w')
    f:writeObject({train=trainDB, val=valDB})
    f:close()
    -- Close out files
    ftrain_list:close()
    fval_list:close()
end

flist = {'square224/Bacteroides/colony/bacte_colony.txt',
    'square224/Gardnerella/colony/gardner_colony.txt',
    'square224/Gardnerella/direct/gardner_direct.txt',
    'square224/Lactobacilli/colony/lacto_colony.txt',
    'square224/Lactobacilli/direct/lacto_direct.txt',
    'square224/noise/noise.txt'}
createDB_val(flist, 'imgLst_square224_val01_train.txt', 'imgLst_square224_val01_val.txt', 'db_square_224_val01.t7', 10)
