require 'cunn'
require 'gnuplot'

function load_model(cfg, opt, model_path, network_filename)
    local model_factory = dofile(model_path)
    local model = model_factory(cfg, opt)
    model:cuda()

    local training_stats
    local weights, gradient
    if network_filename and #network_filename ~= 0 then
        print('Model restored from ' .. network_filename)
        local restored = load_obj(network_filename)
        trianing_stats = restored.stats
        weights, gradient = model:parameters()
        weights = nn.Module.flatten(weights)
        weights:copy(restored.weights)
    else
        weights, gradient = model:parameters()
        weights = nn.Module.flatten(weights)
        gradient = nn.Module.flatten(gradient)
    end

    return model, weights, gradient, training_stats
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
