--[[
This script generates the training and validation dataset based on the command line input

This assumes that the script is run as following:
th xxx.lua <output_dataset_name> <training_proportion> <image_list> ...

where PATH_PREFIX is appended to each image's path
--]]

require 'lfs'

SEPARATOR = '=='
DATASET_DIR = 'datasets'
PATH_PREFIX = ''

function generate_dataset_from_image_list_with_holdout_validation(image_lists, output_database_name, training_proportion)
    table_training = {image_paths={}, labels={}}
    table_validation = {image_paths={}, labels={}}

    for i=1,#image_lists do
        image_list_path = image_lists[i]
        if not paths.filep(image_list_path) then
            print('The following image list file does not exist: ' .. image_list_path)
            os.exit()
        end

        full_count = 0
        training_count = 0
        for line in io.lines(image_list_path) do
            full_count = full_count + 1

            if training_count / full_count > training_proportion then
                -- add to validation set
                table.insert(table_validation.image_paths, PATH_PREFIX .. line:split(SEPARATOR)[1])
                table.insert(table_validation.labels, line:split(SEPARATOR)[2])
            else
                table.insert(table_training.image_paths, PATH_PREFIX .. line:split(SEPARATOR)[1])
                table.insert(table_training.labels, line:split(SEPARATOR)[2])
                training_count = training_count + 1
            end
        end

        print('List #' .. i .. ': ' .. image_list_path .. ' Total of ' .. full_count .. ' images added to dataset (Training: ' .. training_count .. ' Validation:' .. (full_count - training_count) .. ')')
    end

    -- Save dataset (table) object
    full_dataset = {training_set = table_training, validation_set = table_validation}

    local dataset_file = torch.DiskFile(DATASET_DIR .. '/' .. output_database_name, 'w')
    dataset_file:writeObject(full_dataset)
    dataset_file:close()
    print("Writing dataset successful.")
end

if #arg < 3 then
    print("Usage: th xxx.lua <output_dataset_name> <training_proportion> <image_list> ...")
    os.exit()
end

file_list = {}
for i = 3, #arg do
    table.insert(file_list, arg[i])
end
generate_dataset_from_image_list_with_holdout_validation(file_list, arg[1], tonumber(arg[2]))