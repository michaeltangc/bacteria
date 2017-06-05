-- libraries
require 'cunn'
require 'optim'
-- scripts
require 'util'
require 'Batcher'

function test(model_path, ftest)
    local dataTest = load_obj(ftest)
    local model, weights, gradient, training_stats = load_model(cfg, opt, model_path, fnet)
    local batcher = Batcher.new(dataTest, cfg.batch_size)
    -- local criterion = nn.ClassNLLCriterion():cuda()

    local feval = function(params)
        gradient:zero()
        local input, target = batcher:getBatch()
        input = input:cuda()
        local output = model:forward(input)
        local f = criterion:forward(output, target)
        model:backward(input, criterion:backward(output, target))
        return f, gradient
    end
 
    local cnt = {0,0,0,0}
    for i=1,batcher._n_img, cfg.batch_size do
        local inputs = torch.Tensor(64, 3, 224, 224):fill(1) -- Note: pixel range = [0,1]
        local size = math.min(i+cfg.batch_size-1, batcher._n_img) - i
        inputs[{{1,size}}] = dataTest.data[{{i,i+size-1}}]
        local outputs = model:forward(inputs)
        local _, indices = torch.max(outputs, 2)
        for cls in indices do
            cnt[cls] = cnt[cls] + 1
        end

    end

    -- Save final model
    save_obj(snapsho_prefix .. '.t7', {weights=weights, options=opt, stats=training_stats})
end

local cfg, opt = dofile('config.lua')
print(cfg)
print(opt)

train(cfg, opt, opt.model, opt.snapshot_prefix, opt.ftrain, opt.restore)
