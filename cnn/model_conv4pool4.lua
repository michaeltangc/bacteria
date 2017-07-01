local function create_model(cfg, opt)
    local name = 'conv4pool4'

    local net = nn.Sequential()
    -- spatial conv: (nInputPlane, nOutputPlane, kW, kH, stride, stride, padW, padH)
    local conv1 = nn.SpatialConvolution(3,16, 7,7, 1,1)
    conv1.name = 'conv1'
    net:add(conv1)
    net:add(nn.SpatialBatchNormalization(16, opt.eps))
    net:add(nn.ReLU())
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv2 = nn.SpatialConvolution(16,16, 3,3, 1,1, 1,1)
    conv2.name = 'conv2'
    net:add(conv2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(16, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())
    
    local conv3 = nn.SpatialConvolution(16,16, 3,3, 1,1, 1,1)
    conv3.name = 'conv3'
    net:add(conv3)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(16, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv4 = nn.SpatialConvolution(16,16, 3,3, 1,1, 1,1)
    conv4.name = 'conv4'
    net:add(conv4)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(16, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    local conv5 = nn.SpatialConvolution(16,16, 3,3, 1,1, 1,1)
    conv5.name = 'conv5'
    net:add(conv5)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(16, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    -- Classifier
    -- 1 Conv layers for dimension reduction
    local conv6_cls = nn.SpatialConvolution(16,8, 1,1, 1,1, 0,0)
    conv6_cls.name = 'conv6_cls'
    net:add(conv6_cls)
    net:add(nn.ReLU())
    net:add(nn.Reshape(4*cfg.batch_size, 512))
    -- 1 FC layer for final classification
    local fc = nn.Linear(512, 4) -- 512 = 8 * 8 * 8 -- 13 * 13
    fc.name = 'fc'
    net:add(fc)
    net:add(nn.LogSoftMax())

    return net
end

return create_model
