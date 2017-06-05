-- libraries
require 'cunn'
require 'image'
-- scripts
require 'util'

function test(cfg, opt, model, ftest, detail_out, result_out)
    local dataTest = load_obj(ftest)
    if dataTest == nil then
        print('Error loading dataTest')
        return
    end
    local n_img = table.getn(dataTest)

    local cnt = {0,0,0,0}
    local fout = io.open(detail_out, 'w')
    for i=1, n_img, cfg.batch_size do
        local inputs = torch.FloatTensor(64, 3, 224, 224):fill(1) -- Note: pixel range = [0,1]
        local size = math.min(i+cfg.batch_size-1, n_img) - i
        for id = 1, size do
            local curr_img = procInput(dataTest[i+id-1].imgPath)
            if curr_img == nil then
                print('Error loading img ' .. dataTest[i+id-1].imgPath)
            end
            inputs[{{id}}] = curr_img -- procInput(dataTest[{{i+id-1}}].imgPath)
        end
        inputs = inputs:cuda()
        local outputs = model:forward(inputs)
        local _, indices = torch.max(outputs, 2)
        indices = indices:reshape(indices:size(1))

        for id = 1, size do
            fout:write(dataTest[i+id-1].imgPath .. ': ' .. indices[id] .. '\n')
            cnt[indices[id]] = cnt[indices[id]] + 1
        end
    end
    fout:close()
    
    local score, result = nugent(cnt)
    fout = io.open(result_out, 'w')
    -- Format: lacto cnt + lacto score + gardner cnt + gardner score + others cnt + other score + total score + result
    fout:write(string.format('%d %d %d %d %d %d %d %s\n', cnt[1], score[1], cnt[2], score[2], cnt[3], score[3], score[4], result))
    fout:close()
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

local cfg, opt = dofile('config.lua')
print(cfg)
print(opt)
local model, weights, gradient, training_stats = load_model(cfg, opt, opt.model, opt.restore)

for i=2,31 do
    local ftest = string.format('/home/bingbin/bacteria/data/test/testDB/5_900%02d.t7', i)
    local detail_out = string.format('result/5_900%02d_detail.txt', i)
    local result_out = string.format('result/5_900%02d.txt', i)
    test(cfg, opt, model, ftest, detail_out, result_out)
end
