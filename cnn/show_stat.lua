require 'util'

local cfg, opt = dofile('config.lua')
dir = 'conv5pool5_white_bg/'
restored = dir .. 'conv5pool5.t7'
model_factory = 'model_conv5pool5.lua'
_, _, _, training_stats = load_model(cfg, opt, model_factory, restored)
print(training_stats)
local avg_stats = {}
for i=1,#training_stats.loss,10 do
    local curr_sum = 0
    for j=0,9 do
        curr_sum = curr_sum + training_stats.loss[i+j]
    end
    curr_sum = curr_sum / 10
    table.insert(avg_stats, curr_sum)
end
plot_stat(dir .. 'avg_stat', avg_stats)
