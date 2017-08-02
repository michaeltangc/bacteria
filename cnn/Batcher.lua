require 'image'

local Batcher = torch.class('Batcher')

function Batcher:__init(batcher_mode, dataset, batch_size, number_of_channel, image_height, image_width)
    -- Batcher mode: 0 - on-demand loading, 1 - preload
    self._mode = batcher_mode
    self._image_paths = dataset.image_paths
    self._labels = dataset.labels
    self._batch_size = batch_size
    self._number_of_channel = number_of_channel
    self._image_height = image_height
    self._image_width = image_width
    self._image_count = table.getn(self._image_paths)
    self._current_image_index = 1
    self._rand_perm = torch.randperm(self._image_count)

    if batcher_mode == 1 then
        print("Preloading images")
        self._data_cache = torch.FloatTensor(4 * batch_size, self._number_of_channel, self._image_height, self._image_width):zero()
        self._labels_cache = torch.Tensor(4 * batch_size):zero()

        self._image_preload = torch.FloatTensor(4 * self._image_count, self._number_of_channel, self._image_height, self._image_width):zero()
        for i = 1, self._image_count do
            local loaded_image = image.load(self._image_paths[i], self._number_of_channel, 'float')

            -- scale image if necessary
            if loaded_image:size(2) ~= self._image_height or loaded_image:size(3) ~= self._image_width then
                loaded_image = image.scale(loaded_image, self._image_width, self._image_height)
            end
            
            -- Subtract mean
            for c = 1,self._number_of_channel do
                loaded_image[c] = loaded_image[c]:add(-loaded_image[c]:mean())
            end
            self._image_preload[{{i*4-3},{},{},{}}] = loaded_image
            self._image_preload[{{i*4-2},{},{},{}}] = image.hflip(loaded_image)
            self._image_preload[{{i*4-1},{},{},{}}] = image.vflip(loaded_image)
            self._image_preload[{ {i*4}, {},{},{}}] = image.hflip(image.vflip(loaded_image))
        end 
    end
end

function Batcher:getNextBatchIndexes()
    if self._current_image_index + self._batch_size - 1 > self._image_count then
        -- restart batcher
        self._current_image_index = 1
        self._rand_perm = torch.randperm(self._image_count)
    end
    local indexes = self._rand_perm[{{self._current_image_index, self._current_image_index + self._batch_size - 1}}]
    self._current_image_index = self._current_image_index + self._batch_size

    return indexes
end

function Batcher:getBatch()
    local image_indexes = self:getNextBatchIndexes()
    return self:_processBatchByIndexes(image_indexes)
end

function Batcher:_processBatchByIndexes(image_indexes)
    local image_batch_count = image_indexes:numel()

    if self._mode == 0 then

        local data = torch.FloatTensor(4 * image_batch_count, self._number_of_channel, self._image_height, self._image_width):zero()
        local labels = torch.Tensor(4 * image_batch_count):zero()

        for i = 1, image_batch_count do
            local loaded_image = image.load(self._image_paths[image_indexes[i]], self._number_of_channel, 'float')
            -- print('Batcher: imgPath: ' .. self._image_paths[image_indexes[i]])

            -- scale image if necessary
            if loaded_image:size(2) ~= self._image_height or loaded_image:size(3) ~= self._image_width then
                loaded_image = image.scale(loaded_image, self._image_width, self._image_height)
            end
            
            -- Subtract mean
            for c = 1,self._number_of_channel do
                loaded_image[c] = loaded_image[c]:add(-loaded_image[c]:mean())
            end
            data[{{i*4-3},{},{},{}}] = loaded_image
            data[{{i*4-2},{},{},{}}] = image.hflip(loaded_image)
            data[{{i*4-1},{},{},{}}] = image.vflip(loaded_image)
            data[{{i*4},  {},{},{}}] = image.hflip(image.vflip(loaded_image))
            labels[{{i*4-3, i*4}}] = self._labels[image_indexes[i]]
            -- print('label #' .. i .. ': ' .. self._labels[image_indexes[i]])
        end
     
        return data, labels
        -- return loaded_image, torch.Tensor({self._imdb[image_indexes[1]].label}
    elseif self._mode == 1 then
        for i = 1, image_batch_count do
            self._data_cache[{{i*4-3, i*4},{},{},{}}] = self._image_preload[{{image_indexes[i]*4-3, image_indexes[i]*4},{},{},{}}]
            -- self._data_cache[{{i*4-2},{},{},{}}] = self._image_preload[image_indexes[i]*4-2]
            -- self._data_cache[{{i*4-1},{},{},{}}] = self._image_preload[image_indexes[i]*4-1]
            -- self._data_cache[{{i*4},  {},{},{}}] = self._image_preload[image_indexes[i]*4]
            self._labels_cache[{{i*4-3, i*4}}] = self._labels[image_indexes[i]]
            -- print('label #' .. i .. ': ' .. self._labels[image_indexes[i]])
        end
     
        return self._data_cache, self._labels_cache
    end
end
