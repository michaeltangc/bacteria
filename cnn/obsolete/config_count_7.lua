local cfg = {
    -- image
    class_count = 10, -- count 0-9
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
    ftrain = '../data/db_square_224_val01_bacte.t7',
    fval = '../data/db_square224_val01_bacte_val.t7',
    restore_train = '',
    restore_test = 'conv7pool7_count_val01_white_bg_bacte/conv7pool7.t7',
    enumerate_models = true,
    lr = 1e-3,
    eps = 1e-7, -- parameter for batch normalization
    snapshot = 1000,
    snapshot_prefix = 'conv7pool7_white_bg_bacte/conv7pool7',
    plot = 200,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    -- Test
    train_accu = true, -- whether for training accuracy
    result_dir = 'conv7pool7_count_val01_white_bg_bacte/', -- Note: always add a trailing '/'
}

return cfg, opt
