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
    snapshot_prefix = '', --'conv7pool7_class_val01/conv7pool7',
    plot = 400,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    -- Test
    train_accu = false, -- if for trainining accuracy
    val_accu = true,
    is_class = true,
    restore_test = '', -- won't be used if enumerate_model == true,
    enumerate_models = true,
    result_dir = 'from_GPU/', -- Note: always add a trailing '/'
}

return cfg, opt
