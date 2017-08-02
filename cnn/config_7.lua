local files = {
    -- Training
    model = 'model_blueprints/model_conv7pool7.lua',
    dataset = '../data/datasets/ds_classification.t7',
    restore_train = '',
    snapshot_path_prefix = 'trained_models/c7p7_class/c7p7', --'conv7pool7_class_val01/conv7pool7', --snapshot_prefix

    ---- Evaluation
    
    -- General
    model_dir = 'trained_models/c7p7_class/', -- Note: always add a trailing '/'
    model_to_be_evaluated = 'conv7pool7_060000.t7', -- won't be used if enumerate_model == true,
    enumerate_models = true,
    evaluation_result_output_dir = 'evaluation_results/', -- Note: always add a trailing '/'
    -- Testing specific
    testing_dataset = '/home/bingbin/bacteria/data/test/pass2_only/testDB/5_90001.t7'
}


local cfg = {
    -- image
    class_count = 4, -- 3 bacteria + 1 noise
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

    -- Batcher mode: 0 - on-demand loading, 1 - preload
    batcher_mode = 1, 

    -- SGD parameters
    learning_rate = 1e-3,
    weight_decay = 0.0005,
    momentum = 0.9,

    iterations = 60000,
    learning_rate_decay_interval = 20000,
    learning_rate_decay_factor = 0.1,

    eps = 1e-7, -- parameter for batch normalization
    snapshot = 5000,
    plot = 400,
    gpuid = 0, -- Note: only 1 GPU available on this virtual machine
    
    -- -- Testing
    -- train_accu = false, -- if for trainining accuracy
    -- val_accu = true,
    is_class = true,
}

return cfg, files
