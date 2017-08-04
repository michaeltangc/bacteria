local function create_model(cfg, files)
    local name = 'conv7pool7'

    local criterion = nn.ClassNLLCriterion():cuda()

    local net = nn.Sequential()

    -- spatial conv: (nInputPlane, nOutputPlane, kW, kH, stride, stride, padW, padH)
    local conv1 = nn.SpatialConvolution(3,64, 3,3, 1,1, 1,1)
    conv1.name = 'conv1'
    net:add(conv1)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(64, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv2 = nn.SpatialConvolution(64,64, 3,3, 1,1, 1,1)
    conv2.name = 'conv2'
    net:add(conv2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(64, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())
    
    local conv3 = nn.SpatialConvolution(64,128, 3,3, 1,1, 1,1)
    conv3.name = 'conv3'
    net:add(conv3)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(128, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv4 = nn.SpatialConvolution(128,128, 3,3, 1,1, 1,1)
    conv4.name = 'conv4'
    net:add(conv4)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(128, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv5 = nn.SpatialConvolution(128,256, 3,3, 1,1, 1,1)
    conv5.name = 'conv5'
    net:add(conv5)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(256, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv6 = nn.SpatialConvolution(256,256, 3,3, 1,1, 1,1)
    conv6.name = 'conv6'
    net:add(conv6)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(256, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv7 = nn.SpatialConvolution(256,256, 3,3, 1,1, 1,1)
    conv7.name = 'conv7'
    net:add(conv7)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(256, cfg.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())


    -- Classifier
    net:add(nn.Reshape(2304, true))
    -- 1 FC layer for final classification
    local fc1 = nn.Linear(2304, 1024)
    fc1.name = 'fc1'
    net:add(fc1)
    net:add(nn.ReLU())
    net:add(nn.Dropout(0.5))
    local fc2 = nn.Linear(1024,512)
    fc2.name = 'fc2'
    net:add(fc2)
    net:add(nn.ReLU())
    net:add(nn.Dropout(0.5))
    local fc3 = nn.Linear(512, cfg.class_count) -- 2048 = 32 * 8 * 8
    fc3.name = 'fc3'
    net:add(fc3)
    net:add(nn.LogSoftMax())
    return net, criterion
end

return create_model
