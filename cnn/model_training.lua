-- libraries
require 'cunn'
require 'optim'
-- scripts
require 'util'
require 'Batcher'

function train(cfg, files)

    local full_dataset = load_obj(files.dataset)
    local training_set = full_dataset.training_set
    local model, criterion, weights, gradient, training_stats = load_model(cfg, files, files.model, files.restore_train)
    if not training_stats then
        training_stats = {loss={}}
    end
    local batcher = Batcher.new(dataTrain, cfg.batch_size, cfg.number_of_channel, cfg.image_height, cfg.image_width)

    local feval = function(params)
        gradient:zero()
        model:training()
        local input, target = batcher:getBatch()
        input = input:cuda()
        local output = model:forward(input)
        local f = criterion:forward(output, target)
        model:backward(input, criterion:backward(output, target))
        return f, gradient, output
    end

    local sgd_state = {learningRate=cfg.learning_rate, weightDecay=cfg.weight_decay, momentum=cfg.momentum}

    -- Training
    local iter_time = os.clock()
    for i=1, cfg.iterations do
        if i % cfg.learning_rate_decay_interval == 0 then
            sgd_state.learningRate = sgd_state.learningRate * cfg.learning_rate_decay_factor
        end

        local f, loss, output = optim.sgd(feval, weights, sgd_state)
        -- print('f:')
        -- print(f)
        -- print('output:')
        -- print(output)
        table.insert(training_stats.loss, loss)
        print(string.format('%d: loss: %f', i, loss[1]))

        if i % cfg.plot == 0 then
            print('Avg time: ' .. (os.clock()-iter_time)/opt.plot)
            iter_time = os.clock()
            plot_stat(snapshot_prefix, training_stats)
        end
        if i % cfg.snapshot == 0 then
            local bnVars = {}
            local bnLayers = model:findModules('nn.SpatialBatchNormalization')
            for i=1, #bnLayers do
                bnVars[i] = {running_mean=bnLayers[i].running_mean, running_var=bnLayers[i].running_var}
            end
            save_obj(string.format('%s_%06d.t7', files.snapshot_prefix, i), {weights=weights, bnVars=bnVars, options=options, stats=training_stats})
        end
    end
    -- Save final model
    save_obj(files.snapshot_prefix .. '.t7', {weights=weights, options=opt, stats=training_stats})
 
end

if #arg < 1 then
    print("Please specify the configuration file as a command line argument")
    os.exit()
end

local cfg, files = dofile(arg[1])
print('Config:')
print(cfg)
print('Files:')
print(files)

cutorch.setDevice(cfg.gpuid+1)
train(cfg, files)
