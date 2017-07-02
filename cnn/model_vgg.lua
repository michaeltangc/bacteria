local function create_model(cfg, opt)
    local name = 'vgg'

    local net = nn.Sequential()
    -- spatial conv: (nInputPlane, nOutputPlane, kW, kH, stride, stride, padW, padH)
    -- Conv1
    local conv1_1 = nn.SpatialConvolution(3,64, 3,3, 1,1, 1,1)
    conv1_1.name = 'conv1_1'
    net:add(conv1_1)
    net:add(nn.SpatialBatchNormalization(64, opt.eps))
    net:add(nn.ReLU())
    local conv1_2 = nn.SpatialConvolution(64,64, 3,3, 1,1, 1,1)
    conv1_2.name = 'conv1_2'
    net:add(conv1_2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(64, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())
    
    -- Conv2
    local conv2_1 = nn.SpatialConvolution(64,128, 3,3, 1,1, 1,1)
    conv2_1.name = 'conv2_1'
    net:add(conv2_1)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(128, opt.eps))
    local conv2_2 = nn.SpatialConvolution(128,128, 3,3, 1,1, 1,1)
    conv2_2.name = 'conv2_2'
    net:add(conv2_2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(128, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    -- Conv3
    local conv3_1 = nn.SpatialConvolution(128,256, 3,3, 1,1, 1,1)
    conv3_1.name = 'conv3_1'
    net:add(conv3_1)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(256, opt.eps))
    local conv3_2 = nn.SpatialConvolution(256,256, 3,3, 1,1, 1,1)
    conv3_2.name = 'conv3_2'
    net:add(conv3_2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(256, opt.eps))
    local conv3_3 = nn.SpatialConvolution(256,256, 3,3, 1,1, 1,1)
    conv3_3.name = 'conv3_3'
    net:add(conv3_3)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(256, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    -- Conv4
    local conv4_1 = nn.SpatialConvolution(256,512, 3,3, 1,1, 1,1)
    conv4_1.name = 'conv4_1'
    net:add(conv4_1)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(512, opt.eps))
    local conv4_2 = nn.SpatialConvolution(512,512, 3,3, 1,1, 1,1)
    conv4_2.name = 'conv4_2'
    net:add(conv4_2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(512, opt.eps))
    local conv4_3 = nn.SpatialConvolution(512,512, 3,3, 1,1, 1,1)
    conv4_3.name = 'conv4_3'
    net:add(conv4_3)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(512, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())

    -- Conv5
    local conv5_1 = nn.SpatialConvolution(512,512, 3,3, 1,1, 1,1)
    conv5_1.name = 'conv5_1'
    net:add(conv5_1)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(512, opt.eps))
    local conv5_2 = nn.SpatialConvolution(512,512, 3,3, 1,1, 1,1)
    conv5_2.name = 'conv5_2'
    net:add(conv5_2)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(512, opt.eps))
    local conv5_3 = nn.SpatialConvolution(512,512, 3,3, 1,1, 1,1)
    conv5_3.name = 'conv5_3'
    net:add(conv5_3)
    net:add(nn.ReLU())
    net:add(nn.SpatialBatchNormalization(512, opt.eps))
    net:add(nn.SpatialMaxPooling(2,2, 2,2, 1,1):ceil())


    -- Classifier
    -- Reshape
    -- net:add(nn.Reshape(4*cfg.batch_size, 4096))
    -- 1 FC layer for final classification
    -- local fc = nn.Linear(4096, 4) -- 4*cfg.batch_size) -- 2048 = 32 * 8 * 8
    -- fc.name = 'fc'
    -- net:add(fc)
    -- net:add(nn.LogSoftMax())

    -- FC layers
    net:add(nn.Reshape(4*cfg.batch_size, 32768))
    local fc6 = nn.Linear(32768, 4096)
    fc6.name = 'fc6'
    net:add(fc6)
    net:add(nn.ReLU())
    net:add(nn.Dropout(0.5))
    local fc7 = nn.Linear(4096, 4096)
    fc7.name = 'fc7'
    net:add(fc7)
    net:add(nn.ReLU())
    net:add(nn.Dropout(0.5))
    local fc8 = nn.Linear(4096, 4)
    fc8.name = 'fc8'
    net:add(fc8)
    net:add(nn.LogSoftMax())

    return net
end

return create_model
