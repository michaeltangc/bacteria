-- Plot training progress of a model of choice.
-- The progress is averaged over a fixed number (i.g. the variable named 'step') of iterations

require 'util'

if #arg < 3 then
    print("Please specify the configuration file, the model blueprint, the trained model as command line arguments")
    os.exit()
end

local cfg, files = dofile(arg[1])
-- dir = '' -- the directory where your model is placed; ALWAYS add a trailing '/'
-- restored = dir .. '' -- filename of your model (*.t7)
-- model_factory = '' -- filename of your model factory file, e.g. model_*.lua
_, _, _, training_stats = load_model(cfg, opt, arg[2], arg[3])

local avg_stats = {}
step = 10
for i=1,#training_stats.loss,step do
    local curr_sum = 0
    for j=0,step-1 do
        curr_sum = curr_sum + training_stats.loss[i+j]
    end
    curr_sum = curr_sum / step
    table.insert(avg_stats, curr_sum)
end
plot_stat(dir .. 'avg_stat', avg_stats)
