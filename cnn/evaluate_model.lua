-- libraries
require 'cunn'
require 'image'
require 'lfs'
require 'paths'
-- scripts
require 'util'
require 'result_high_level_interpretation_function'

function evaluate_model(cfg, files, model, evaluation_dataset, eval_result_detail_out_path, eval_result_overview_out_path)
    print('Detailed results: ' .. (eval_result_detail_out_path or 'nil'))
    print('Overview results: ' .. (eval_result_overview_out_path or 'nil'))

    local image_count = table.getn(evaluation_dataset.image_paths)
    local labels, predicts = nil, nil
    local label_comparison_enabled = false

    if evaluation_dataset.labels then
        label_comparison_enabled = true
        labels = evaluation_dataset.labels
        predicts = torch.Tensor(image_count,1):zero()
        -- cross tabulation: first index (i) = real label, second index = prediction from model
        class_cross_table = torch.Tensor(cfg.class_count, cfg.class_count):zero()
        -- for i = 1,cfg.class_count do
        --     class_cross_table[i] = {}
        --     for j = 1,cfg.class_count do
        --         class_cross_table[i][j] = 0
        --     end
        -- end
    end

    local cnt = {}
    for i = 1,cfg.class_count do cnt[i] = 0; end
    local fout = nil
    if eval_result_detail_out_path and eval_result_detail_out_path ~= '' then
        fout = io.open(eval_result_detail_out_path, 'w')
    end
    print('Compute accuracy: ' .. tostring(predicts ~= nil))

    model:evaluate()
    for i=1, image_count do
        local input = procInput(evaluation_dataset.image_paths[i], cfg):cuda()
        local outputs = model:forward(input:reshape(1,cfg.number_of_channel,input:size(2), input:size(3)))
        local _, class = torch.max(outputs, 2)
        class = class[1][1]

        if label_comparison_enabled then
            predicts[i] = class
            class_cross_table[labels[i]][predicts[i]] = class_cross_table[labels[i]][predicts[i]] + 1
        end        
        cnt[class] = cnt[class] + 1

        if fout then

            local classes_predictions_text = tostring(outputs[1][1])
            for i = 1, cfg.number_of_channel - 1 do
                classes_predictions_text = classes_predictions_text .. ' / ' .. tostring(outputs[1][i + 1])
            end
            if not labels == nil then
                fout:write(evaluation_dataset.image_paths[i] .. string.format(': %d (label: %d) (output (classes): ' .. classes_predictions_text .. ') (input:mean(): %f) \n', class, labels[i], input:mean()))
            else
                fout:write(evaluation_dataset.image_paths[i] .. string.format(': %d (output: ' .. classes_predictions_text .. ') (input:mean(): %f) \n', class, input:mean()))
            end
        end
        
    end
    if fout then
        fout:close();
        print('Written to detail_out')
    end
    
    local score, result = high_level_interpretation(cnt)
    if eval_result_overview_out_path and eval_result_overview_out_path ~= '' then
        fout = io.open(eval_result_overview_out_path, 'w')
        print('Written to result Overview\n')
    else
        fout = nil
    end


    -- Format: lacto cnt + lacto score + gardner cnt + gardner score + others cnt + other score + total score + result
    if fout then

        ---------- Obsolete: Potential problem -------------
        if cfg.is_class then
            fout:write(string.format('\nLacto cnt: %d (%d) / Gardner cnt: %d (%d) / Bacte cnt: %d (%d)\n Total score: %d / Result: %s\n', cnt[1], score[1], cnt[2], score[2], cnt[3], score[3], score[4], result))
        end
        ----------------------------------------------------
        if label_comparison_enabled then
            local accuracy = torch.sum(torch.eq(torch.Tensor(labels), predicts)) / image_count
            fout:write(string.format('Accuracy: %f\n', accuracy))


            fout:write('Cross-tabulation (rows [y-axis]: real labels, columns [x-axis]: predictions, probability: P(Predict = X | Label = Y)) \n')
            local row_sums = tensor.sum(class_cross_table, 2)
            for j = 1,cfg.class_count do
                fout:write(string.format('%15s', string.format('Class %d', j))
            end
            for i = 1,cfg.class_count do
                fout:write(string.format('%15s', string.format('Class %d', i))
                
                for j = 1,cfg.class_count do
                    fout:write(string.format('%15s' , string.format('%.3f%% %d', class_cross_table[i][j] / row_sum[i][1] * 100, class_cross_table[i][j]))
                end
                fout:write('\n')
            end
        end
        fout:close()
    end
    return
end

function procInput(fname, cfg)
    local loaded_image = image.load(fname)

    if loaded_image:size(2) ~= cfg.image_height or loaded_image:size(3) ~= cfg.image_width then
        loaded_image = image.scale(loaded_image, cfg.image_width, cfg.image_height)
    end
    
    -- Subtract mean
    for c = 1,cfg.number_of_channel do
        loaded_image[c] = loaded_image[c]:add(-loaded_image[c]:mean())
    end
    return loaded_image
end



if #arg < 2 then
    print("Please specify the configuration file and evaluation mode as command line arguments.")
    os.exit()
end

local cfg, files = dofile(arg[1])
print('Config:')
print(cfg)
print('Files:')
print(files)

cutorch.setDevice(cfg.gpuid+1)

-- if opt.train_accu and opt.val_accu then
--     print('ERROR: Please specify only ONE dataset for accuracy.')
--     os.exit()
-- end

evaluation_mode = 0
if arg[2] == 'val' then
    evaluation_mode = 1
elseif arg[2] == 'train' then
    evaluation_mode = 0
end

if not paths.dirp(files.evaluation_result_output_dir) then
    lfs.mkdir(files.evaluation_result_output_dir)
end

if evaluation_mode == 0 or evaluation_mode == 1 then
    -- Accuracy on training or validation data
    local evaluation_dataset_path = files.dataset
    local evaluation_dataset

    if files.enumerate_models then
        -- Enumerate all models in opt.model_dir
        for f in paths.iterfiles(files.model_dir) do
            if f:find('t7') and f:find('_') then
                local model, weights, gradient, training_stats = load_model(cfg, files, files.model, files.model_dir .. f)
                local suffix = f:sub(f:find('_')+1, f:find('%.')-1)
                if evaluation_mode == 0 then
                    suffix = 'train_' .. suffix
                    evaluation_dataset = load_obj(evaluation_dataset_path).training_set
                else
                    suffix = 'val_' .. suffix
                    evaluation_dataset = load_obj(evaluation_dataset_path).validation_set
                end
                if not evaluation_dataset then
                    print('Error loading evaluation dataset (dataset not found)')
                    return
                end
                local eval_result_out_path = files.evaluation_result_output_dir .. string.format('result_overview_%s.txt', suffix) 
                local eval_result_detail_out_path = files.evaluation_result_output_dir .. string.format('result_detail_%s.txt', suffix) 
                evaluate_model(cfg, files, model, evaluation_dataset, eval_result_detail_out_path, eval_result_out_path)
            end
        end

    else
        -- Use only the model specified by opt.restore_rest
        local model, weights, gradient, training_stats = load_model(cfg, files, files.model, files.model_dir .. files.model_to_be_evaluated)
        local suffix

        if evaluation_mode == 0 then
            suffix = 'train' .. suffix
            evaluation_dataset = load_obj(evaluation_dataset_path).training_set
        else
            suffix = 'val' .. suffix
            evaluation_dataset = load_obj(evaluation_dataset_path).validation_set
        end

        local eval_result_out_path = files.evaluation_result_output_dir .. string.format('result_overview_%s.txt', suffix)
        local eval_result_detail_out_path = files.evaluation_result_output_dir .. string.format('result_detail_%s.txt', suffix)
        evaluate_model(cfg, files, model, evaluation_dataset, eval_result_detail_out_path, eval_result_out_path)
    end

else
    -- Accuracy on testing data
    local model, weights, gradient, training_stats = load_model(cfg, opt, opt.model, opt.model_dir .. opt.restore_test)
    local evaluation_dataset_path = files.testing_dataset
    
    local evaluation_dataset = load_obj(evaluation_dataset_path).validation_set

    local suffix = 'test'
    local eval_result_out_path = files.evaluation_result_output_dir .. string.format('result_overview_%s.txt', suffix)
    local eval_result_detail_out_path = files.evaluation_result_output_dir .. string.format('result_detail_%s.txt', suffix)
    evaluate_model(cfg, files, model, evaluation_dataset, eval_result_detail_out_path, eval_result_out_path)

    -- for i=1,31 do
    --     local evaluation_dataset = string.format('/home/bingbin/bacteria/data/test/pass2_only/testDB/5_900%02d.t7', i)
    --     local detail_out = string.format(opt.result_dir .. 'test_detail_5_900%02d_detail.txt', i)
    --     local result_out = string.format(opt.result_dir .. 'test_5_900%02d.txt', i)
    --     test(cfg, opt, model, ftest, detail_out, result_out)
    -- end
end
