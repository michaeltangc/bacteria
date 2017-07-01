local function create_model(cfg, opt)
    local name = 'conv5pool4'

    local net = nn.Sequential()
    -- spatial conv: (nInputPlane, nOutputPlane, kW, kH, stride, stride, padW, padH)
    local conv1 = nn.SpatialConvolution(3,32, 3,3, 1,1, 1,1)
    conv1.name = 'conv1'
    net:add(conv1)
    net:add(nn.SpatialBatchNormalization(32, opt.eps))
    net:add(nn.ReLU())
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv2 = nn.SpatialConvolution(32,32, 3,3, 1,1, 1,1)
    conv2.name = 'conv2'
    net:add(conv2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(32, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())
    
    local conv3 = nn.SpatialConvolution(32,64, 3,3, 1,1, 1,1)
    conv3.name = 'conv3'
    net:add(conv3)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(64, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv4 = nn.SpatialConvolution(64,96, 3,3, 1,1, 1,1)
    conv4.name = 'conv4'
    net:add(conv4)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(96, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv5 = nn.SpatialConvolution(96,128, 3,3, 1,1, 1,1)
    conv5.name = 'conv5'
    net:add(conv5)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(128, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    -- Classifier
    -- 2 Conv layers for dimension reduction
    local conv6_cls = nn.SpatialConvolution(128,64, 1,1, 1,1, 0,0)
    conv6_cls.name = 'conv6_cls'
    net:add(conv6_cls)
    net:add(nn.ReLU())
    local conv7_cls = nn.SpatialConvolution(64,32, 1,1, 1,1, 0,0)
    conv7_cls.name = 'conv7_cls'
    net:add(conv7_cls)
    net:add(nn.ReLU())
    net:add(nn.Reshape(4*cfg.batch_size, 2048))
    -- 1 FC layer for final classification
    local fc = nn.Linear(2048, 4) -- 4*cfg.batch_size) -- 2048 = 32 * 8 * 8
    fc.name = 'fc'
    net:add(fc)
    net:add(nn.LogSoftMax())

    return net
end

return create_model
