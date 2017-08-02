local files = {
    -- Training
    model = 'model_conv7pool7.lua',
    dataset = '../data/db_square_224_val01_bacte.t7',
    -- fval = '../data/db_square224_val01_bacte_val.t7',
    restore_train = '',
    snapshot_path_prefix = 'conv7pool7_white_bg_bacte/conv7pool7', --'conv7pool7_class_val01/conv7pool7', --snapshot_prefix

    -- Testing
    model_dir = 'from_GPU/', -- Note: always add a trailing '/'
    restore_test = 'conv7pool7_count_val01_white_bg_bacte/conv7pool7.t7', -- won't be used if enumerate_model == true,
    enumerate_models = true,
    result_dir = 'conv7pool7_count_val01_white_bg_bacte/', -- Note: always add a trailing '/'
}

local cfg = {
    -- image
    class_count = 10, -- count 0-9
    normalization = {method = 'contrastive', width=7, centering=true, scaling=false},
    augmentation = {vflip=0.25, hflip=0.25, random_scaling=0, aspect_jitter=0},
    color_space = 'rgb',
    number_of_channel = 3,
    image_height = 224,
    image_width = 224,
    batch_size = 16,
    pos_thresh = 0.7,
    neg_thresh = 0.25,

    -----Training

    -- SGD parameters
    learning_rate = 1e-3,
    weight_decay = 0.0005,
    momentum = 0.9,

    iterations = 60000,
    learning_rate_decay_interval = 20000,
    learning_rate_decay_factor = 0.1,

    eps = 1e-7, -- parameter for batch normalization
    snapshot = 1000,
    plot = 200,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    
    -- Testing
    train_accu = false, -- if for trainining accuracy
    val_accu = true,
    is_class = true,
}

return cfg, files
