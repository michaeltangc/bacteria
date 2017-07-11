local cfg = {
    -- image
    class_count = 4, -- 3 bacteria + 1 noise
    normalization = {method = 'contrastive', width=7, centering=true, scaling=false},
    augmentation = {vflip=0.25, hflip=0.25, random_scaling=0, aspect_jitter=0},
    color_space = 'rgb',
    batch_size = 16,
    pos_thresh = 0.7,
    neg_thresh = 0.25,
}

local opt = {
    -- Train
    model = 'model_conv7pool7.lua',
    ftrain = '../data/db_square224_class_val01.t7',
    restore_train = '',
    lr = 1e-3,
    eps = 1e-7, -- parameter for batch normalization
    snapshot = 5000,
    snapshot_prefix = 'conv7pool7_class_val01/conv7pool7',
    plot = 400,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    -- Test
    restore_test = '', -- 'conv7pool7_context_bn/conv7pool7_004000.t7',
    enumerate_models = true,
    result_dir = 'conv7pool7_class_val01/', -- Note: always add a trailing '/'
}

return cfg, opt
