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
    model = 'model_vgg.lua',
    ftrain = '../data/db_square224_VM.t7',
    restore_train = '',
    restore_test = 'vgg_small_context/vgg_0%d0000.t7',
    lr = 1e-3,
    eps = 1e-7, -- parameter for batch normalization
    snapshot = 5000,
    snapshot_prefix = 'vgg_small_context/vgg',
    plot = 200,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    -- Test
    result_dir = 'vgg_small_context/', -- Note: always add a trailing '/'
}

return cfg, opt
