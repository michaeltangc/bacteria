require 'lfs'

function createDB_class(fList,train_list_fname,  val_list_fname, outname, use_val, val_step)
    ftrain_list = io.open(train_list_fname, 'w')
    fval_list = io.open(val_list_fname, 'w')
	parent_dir = '/home/ubuntu/bacteria/data/'

    trainDB = {imgPaths={}, labels={}}
    valDB = {imgPaths={}, labels={}}
	prefix = ''
    for i=1,#fList do
        imgLst = fList[i]
		-- prefix = parent_dir .. imgLst:sub(1, imgLst:find('/'))
        if not paths.filep(imgLst) then
            print('ERROR: File does not exist: ' .. imgLst)
            exit(-1)
        end
    
        cnt = 0
        for line in io.lines(imgLst) do
            cnt = cnt+1
            if use_val and cnt == val_step then
                table.insert(valDB.imgPaths, prefix .. line:split(' ')[1])
                table.insert(valDB.labels, line:split(' ')[2])
                fval_list:write(prefix .. line:split(' ')[1] .. ' ' .. line:split(' ')[2] .. '\n')
                cnt = 0
            else
                table.insert(trainDB.imgPaths, prefix .. line:split(' ')[1])
                table.insert(trainDB.labels, line:split(' ')[2])
                ftrain_list:write(prefix .. line:split(' ')[1] .. ' ' .. line:split(' ')[2] .. '\n')
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
    'square224/noise/noise.txt', -- next: white_bg
    'square224_white_bg/bacte/bacte_imgLst.txt',
    'square224_white_bg/gardner/gardner_imgLst.txt',
    'square224_white_bg/lacto/lacto_imgLst.txt',
    'square224_white_bg/noise/noise_imgLst.txt'
}
flist = {'imgLst_square224_class_val01_train.txt',
    'imgLst_square224_class_val01_val.txt'}
createDB_class(flist, 'out_imgLst_square224_class_val01_train.txt', 'out_imgLst_square224_class_val01_val.txt', 'db_square224_class_val01.t7', true, 10)
