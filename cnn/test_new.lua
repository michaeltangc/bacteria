-- libraries
require 'cunn'
require 'image'
-- scripts
require 'util'
require 'lfs'
require 'paths'

function test(cfg, opt, model, ftest, detail_out, result_out)
    print('detail_out: ' .. (detail_out or 'nil'))
    print('result_out: ' .. (result_out or 'nil'))

    local dataTest = load_obj(ftest)
    if opt.train_accu then
        dataTest = dataTest.train
    end
    if opt.val_accu then
        dataTest = dataTest.val
    end
    if not dataTest then
        print('Error loading dataTest')
        return
    end
    local n_img = table.getn(dataTest.imgPaths)
    local labels, predicts = nil, nil
    if dataTest.labels then
        labels = dataTest.labels
        predicts = torch.Tensor(n_img,1):zero()
    end

    local cnt = {}
    for i = 1,cfg.class_count do cnt[i] = 0; end
    local fout = nil
    if detail_out and detail_out ~= '' then
        fout = io.open(detail_out, 'w')
    end
    print('Compute accuracy: ' .. tostring(predicts ~= nil))

    model:evaluate()
    for i=1, n_img do
        local input = procInput(dataTest.imgPaths[i]):cuda()
        local outputs = model:forward(input:reshape(1,3,input:size(2), input:size(3)))
        local _, class = torch.max(outputs, 2)
        class = class[1][1]
        if predicts then
            predicts[i] = class
        end        

        if fout then
            if labels then
                fout:write(dataTest.imgPaths[i] .. string.format(': %d (label: %d) (output: %f / %f / %f / %f) (input:mean(): %f) \n', class, labels[i], outputs[1][1], outputs[1][2], outputs[1][3], outputs[1][4], input:mean()))
            else
                fout:write(dataTest.imgPaths[i] .. string.format(': %d (output: %f / %f / %f / %f) (input:mean(): %f) \n', class, outputs[1][1], outputs[1][2], outputs[1][3], outputs[1][4], input:mean()))
            end
        end
        cnt[class] = cnt[class] + 1
    end
    if fout then
        fout:close();
        print('Written to detail_out')
    end
    
    local score, result = nugent(cnt)
    if result_out and result_out ~= '' then
        fout = io.open(result_out, 'w')
        print('Written to result_out\n')
    else
        fout = nil
    end
    -- Format: lacto cnt + lacto score + gardner cnt + gardner score + others cnt + other score + total score + result
    if fout then
        if opt.is_class then
            fout:write(string.format('\nLacto cnt: %d (%d) / Gardner cnt: %d (%d) / Bacte cnt: %d (%d)\n Total score: %d / Result: %s\n', cnt[1], score[1], cnt[2], score[2], cnt[3], score[3], score[4], result))
        end
        if predicts then
            local accuracy = torch.sum(torch.eq(torch.Tensor(labels), predicts)) / n_img
            fout:write(string.format('Accuracy: %f\n', accuracy))
        end
        fout:close()
    end
    return
end

function procInput(fname)
    local img = image.load(fname)
    if img:size(2) ~= 224 then
        img = image.scale(img, 224)
    end
    for c = 1,3 do
        img[c] = img[c] - img[c]:mean()
    end
    return img
end

function nugent(cnt)
    local score = {0,0,0,0}
    -- Lacto
    if cnt[1] == 0 then score[1] = 4
    elseif cnt[1] == 1 then score[1] = 3
    elseif cnt[1] <= 4 then score[1] = 2
    elseif cnt[1] <= 30 then score[1] = 1
    end
    -- Gardner
    if cnt[2] > 30 then score[2] = 4
    elseif cnt[2] >= 5 then score[2] = 3
    elseif cnt[2] > 1 then score[2] = 2
    elseif cnt[2] == 1 then score[2] = 1
    end
    -- Bacte
    if cnt[3] >= 5 then score[3] = 2
    elseif cnt[3] > 0 then score[3] = 1
    end
    -- Total
    score[4] = score[1] + score[2] + score[3]
    -- Result
    local result
    if score[4] <= 3 then result = 'Normal'
    elseif score[4] <= 6 then result = 'Intermediate'
    else result = 'BV Infection'
    end
    return score, result
end

local cfg, opt = dofile('config_7.lua')
print('Config:')
print(cfg)
print('Options:')
print(opt)

cutorch.setDevice(opt.gpuid+1)

if opt.train_accu and opt.val_accu then
    print('ERROR: Please specify only ONE dataset for accuracy.')
    os.exit()
end

if not paths.dirp(opt.result_dir) then
    lfs.mkdir(opt.result_dir)
end

if opt.train_accu or opt.val_accu then
    -- Accuracy on training or validation data
    local ftest = opt.ftrain
    if opt.enumerate_models then
        -- Enumerate all models in opt.model_dir
        for f in paths.iterfiles(opt.model_dir) do
            if f:find('t7') and f:find('_') then
                local model, weights, gradient, training_stats = load_model(cfg, opt, opt.model, opt.model_dir .. f)
                local suffix = f:sub(f:find('_')+1, f:find('%.')-1)
                if opt.train_accu then
                    suffix = 'train_' .. suffix
                else
                    suffix = 'val_' .. suffix
                end
                local result_out = opt.result_dir .. string.format('result_%s.txt', suffix) 
                local detail_out = opt.result_dir .. string.format('result_detail_%s.txt', suffix) 
                test(cfg, opt, model, ftest, detail_out, result_out)
            end
        end
    else
        -- Use only the model specified by opt.restore_rest
        local model, weights, gradient, training_stats = load_model(cfg, opt, opt.model, opt.model_dir .. opt.restore_test)
        local suffix
        if opt.train_accu then
            suffix = 'train'
        else
            suffix = 'val'
        end
        local result_out = opt.result_dir .. string.format('result_%s.txt', suffix)
        local detail_out = opt.result_dir .. string.format('result_detail_%s.txt', suffix)
        test(cfg, opt, model, ftest, detail_out, result_out)
    end
else
    -- Accuracy on testing data
    local model, weights, gradient, training_stats = load_model(cfg, opt, opt.model, opt.model_dir .. opt.restore_test)

    for i=1,31 do
        local ftest = string.format('/home/bingbin/bacteria/data/test/pass2_only/testDB/5_900%02d.t7', i)
        local detail_out = string.format(opt.result_dir .. 'test_detail_5_900%02d_detail.txt', i)
        local result_out = string.format(opt.result_dir .. 'test_5_900%02d.txt', i)
        test(cfg, opt, model, ftest, detail_out, result_out)
    end
end
