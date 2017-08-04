require 'cunn'
require 'gnuplot'

function load_model(cfg, files, model_blueprint_path, trained_model_path)
    local model_factory = dofile(model_blueprint_path)
    local model, criterion = model_factory(cfg, files)
    model:cuda()

    local training_stats
    local weights, gradient
    if trained_model_path and #trained_model_path ~= 0 then
        print('Model restored from ' .. trained_model_path)
        local restored = load_obj(trained_model_path)
        trianing_stats = restored.stats
        weights, gradient = model:parameters()
        weights = nn.Module.flatten(weights)
        weights:copy(restored.weights)
        -- batch normalization variables
        local bnVars = restored.bnVars
        local bnLayers = model:findModules('nn.SpatialBatchNormalization')
        for i=1, #bnLayers do
            rm = bnVars[i].running_mean
            rv = bnVars[i].running_var
            bnLayers[i].running_mean = rm
            bnLayers[i].running_var = rv
        end
    else
        weights, gradient = model:parameters()
        weights = nn.Module.flatten(weights)
        gradient = nn.Module.flatten(gradient)
    end

    return model, criterion, weights, gradient, training_stats
end

function load_obj(fname)
    local f = torch.DiskFile(fname, 'r')
    local obj = f:readObject()
    f:close()
    return obj
end

function save_obj(fname, obj)
    local f = torch.DiskFile(fname, 'w')
    f:writeObject(obj)
    f:close()
end

function plot_stat(prefix, stats)
    local outname = prefix .. '_progress.png'
    gnuplot.pngfigure(outname)
    gnuplot.title('Loss vs Iter')

    local xs = torch.range(1, #stats.loss)
    gnuplot.plot({'loss', xs, torch.Tensor(stats.loss), '-'})
    gnuplot.axis({0, #stats.loss, 0, 1.5})
    gnuplot.xlabel('iteration')
    gnuplot.ylabel('loss')

    gnuplot.plotflush()
end

function sorted_pairs(t, compare_function)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if compare_function function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if compare_function then
        table.sort(keys, function(a,b) return compare_function(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
