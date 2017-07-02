local cfg = {
    -- image
    class_count = 4, -- 3 bacteria + 1 others
    normalization = {method = 'contrastive', width=7, centering=true, scaling=false},
    augmentation = {vflip=0.25, hflip=0.25, random_scaling=0, aspect_jitter=0},
    color_space = 'rgb',
    batch_size = 4,
    pos_thresh = 0.7,
    neg_thresh = 0.25,
    -- training
    train_img_set = '../data/train',
    test_img_set = '../data/test',
    cache = './cache/',
}

local opt = {
    -- Train
    model = 'model_vgg_small.lua',
    ftrain = '../data/db_square224_combined_virtual_GPU.t7',
    restore = 'vgg_small_combined/vgg_010000.t7', -- also for testing
    lr = 1e-3,
    eps = 1e-7, -- parameter for batch normalization
    snapshot = 10000,
    snapshot_prefix = 'vgg_small_combined/vgg',
    plot = 200,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    -- Test
    result_dir = 'vgg_small_combined/', -- Note: always add a trailing '/'
}

return cfg, opt
