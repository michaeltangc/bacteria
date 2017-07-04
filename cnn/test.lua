-- libraries
require 'cunn'
require 'image'
-- scripts
require 'util'

function test(cfg, opt, model, ftest, detail_out, result_out)
    print('detail_out: ' .. detail_out)
    print('result_out: ' .. result_out)

    local dataTest = load_obj(ftest)
    if dataTest == nil then
        print('Error loading dataTest')
        return
    end
    local n_img = table.getn(dataTest.imgPaths)
    local labels, predicts = nil, nil
    if dataTest.labels then
        labels = dataTest.labels
        predicts = torch.Tensor(n_img,1):zero()
    end

    local cnt = {0,0,0,0}
    local fout = nil
    if detail_out and detail_out ~= '' then
        fout = io.open(detail_out, 'w')
    end
    print('Openning detail_out')
    print('fout == nil:')
    print(fout == nil)
    print('predicts == nil:')
    print(predicts == nil)

    -- model:evaluate()
    local batch_size = 4*cfg.batch_size
    for i=1, n_img, batch_size do
        local inputs = torch.FloatTensor(batch_size, 3, 224, 224):fill(1) -- Note: pixel range = [0,1]
        local size = math.min(i+batch_size, n_img+1) - i
        for id = 1, size do
            local curr_img = procInput(dataTest.imgPaths[i+id-1])
            if curr_img == nil then
                print('Error loading img ' .. dataTest.imgPaths[i+id-1])
            end
            inputs[{{id}}] = curr_img
        end
        inputs = inputs:cuda()
        local outputs = model:forward(inputs)
        -- print(outputs:size())
        local _, types = torch.max(outputs, 2)
        if predicts then
            -- print('predicts type:')
            -- print(predicts[{{i,i+size-1}}])
            -- print('types type:')
            -- print(types)
            predicts[{{i,i+size-1}}] = types[{{1,size}}]:double()
        end        
        types = types:reshape(types:size(1))


        for id = 1, size do
            if fout then fout:write(dataTest.imgPaths[i+id-1] .. string.format(': %d (label: %d) (output: %f / %f / %f / %f) \n', types[id], dataTest.labels[i+id-1], outputs[id][1], outputs[id][2], outputs[id][3], outputs[id][4])) end
            cnt[types[id]] = cnt[types[id]] + 1
        end
    end
    if fout then fout:close() end
    
    local score, result = nugent(cnt)
    if result_out and result_out ~= '' then
        print('Openning result_out')
        fout = io.open(result_out, 'a')
        print('fout == nil:')
        print(fout == nil)
    else
        fout = nil
    end
    -- Format: lacto cnt + lacto score + gardner cnt + gardner score + others cnt + other score + total score + result
    if fout then
        fout:write(string.format('%d %d %d %d %d %d %d %s\n', cnt[1], score[1], cnt[2], score[2], cnt[3], score[3], score[4], result))
        if predicts then
            local accuracy = torch.sum(torch.eq(torch.Tensor(labels), predicts)) / n_img
            fout:write(string.format('Accuracy: %f', accuracy))
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

local cfg, opt = dofile('config_5.lua')
-- cfg.batch_size = 16
-- opt.model = 'model_conv5pool5.lua'
-- opt.restored = 'conv5pool5_white_bg/conv5pool5_040000.t7'
-- opt.result_dir = 'conv5pool5_white_bg/result/'
print('Config:')
print(cfg)
print('Options:')
print(opt)

local ftest = opt.ftrain
cutorch.setDevice(opt.gpuid+1)

for i=1,6 do
    local model, weights, gradient, training_stats = load_model(cfg, opt, opt.model, string.format(opt.restore_test, i))
    test(cfg, opt, model, ftest, opt.result_dir .. string.format('result_detail_%d.txt', i), opt.result_dir .. string.format('result_%d.txt', i))
end

-- for i=1,31 do
--     local ftest = string.format('/home/bingbin/bacteria/data/test/testDB/5_900%02d.t7', i)
--     local detail_out = string.format(opt.result_dir .. 'detail/5_900%02d_detail.txt', i)
--     local result_out = string.format(opt.result_dir .. '5_900%02d.txt', i)
--     test(cfg, opt, model, ftest, detail_out, result_out)
-- end
