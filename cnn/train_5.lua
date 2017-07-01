-- libraries
require 'cunn'
require 'optim'
-- scripts
require 'util'
require 'Batcher'

function train(cfg, opt, model_path, snapshot_prefix, ftrain, fnet)
    local dataTrain = load_obj(ftrain)
    local model, weights, gradient, training_stats = load_model(cfg, opt, model_path, fnet)
    if not training_stats then
        training_stats = {loss={}}
    end
    local batcher = Batcher.new(dataTrain, cfg.batch_size)
    local criterion = nn.ClassNLLCriterion():cuda()

    local feval = function(params)
        gradient:zero()
        model:training()
        local input, target = batcher:getBatch()
        input = input:cuda()
        local output = model:forward(input)
        -- print('input:')
        -- print(input)
        -- print('output:')
        -- print(output)
        local f = criterion:forward(output, target)
        model:backward(input, criterion:backward(output, target))
        return f, gradient, output
    end
 
    local sgd_state = {learningRate=opt.lr, weightDecay=0.0005, momentum=0.9}
    -- Training
    for i=1,60000 do
        if i % 20000 == 0 then
            opt.lr = opt.lr / 10
        end

        local f, loss, output = optim.sgd(feval, weights, sgd_state)
        -- print('f:')
        -- print(f)
        -- print('output:')
        -- print(output)
        table.insert(training_stats.loss, loss)
        print(string.format('%d: loss: %f', i, loss[1]))

        if i%opt.plot == 0 then
            plot_stat(snapshot_prefix, training_stats)
        end
        if i%opt.snapshot == 0 then
            save_obj(string.format('%s_%06d.t7', snapshot_prefix, i), {weights=weights, options=options, stats=training_stats})
        end
    end

    -- Save final model
    save_obj(snapshot_prefix .. '.t7', {weights=weights, options=opt, stats=training_stats})
end

local cfg, opt = dofile('config_5.lua')
print('Config:')
print(cfg)
print('Options:')
print(opt)

cutorch.setDevice(opt.gpuid+1)
train(cfg, opt, opt.model, opt.snapshot_prefix, opt.ftrain, opt.restore)
