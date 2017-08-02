require '../../cnn/util'
require 'lfs'
require 'paths'

function create_testDB(imgLst, db_save_dir)
    local testDB = {imgPaths={}}
    for line in io.lines(imgLst) do
        table.insert(testDB.imgPaths, line)
    end
    imgLst = imgLst:sub(imgLst:find('5_900'), END)
    save_obj(db_save_dir .. imgLst:sub(1,imgLst:find('/')-1) .. '.t7', testDB) -- % is to escape special char
end

parent_dir = 'pass2_only/'
db_save_dir = parent_dir .. 'testDB/'
if not paths.dirp(db_save_dir) then
    lfs.mkdir(db_save_dir)
end

for i=1,31 do
    create_testDB(parent_dir .. string.format('5_900%02d/test_5_900%02d.txt', i,i), db_save_dir)
end

