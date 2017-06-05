require 'image'

local Batcher = torch.class('Batcher')

function Batcher:__init(imdb, batch_size)
    self._imdb = imdb
    self._batch_size = batch_size
    self._n_img = table.getn(self._imdb)
    self._curr_img = 1
    self._rand_perm = torch.randperm(self._n_img)
end

function Batcher:getNextIds()
    if self._curr_img + self._batch_size - 1 > self._n_img then
        -- restart batcher
        self._curr_img = 1
        self._rand_perm = torch.randperm(self._n_img)
    end
    local idxs = self._rand_perm[{{self._curr_img, self._curr_img+self._batch_size-1}}]
    self._curr_img = self._curr_img + self._batch_size

    return idxs
end

function Batcher:getBatch()
    local img_idxs = self:getNextIds()
    return self:_processBatch(img_idxs)
end

function Batcher:_processBatch(idxs)
    local n_imgs = idxs:numel()

    local data = torch.FloatTensor(4*n_imgs, 3, 224, 224):zero()
    local labels = torch.Tensor(4*n_imgs):zero()
    for i=1,n_imgs do
        local curr_img = image.load(self._imdb[idxs[i]].imgPath, 3, 'float')
        if curr_img:size(2) ~= 224 then
            curr_img = image.scale(curr_img, 224)
        end
        data[{{i*4-3},{},{},{}}] = curr_img
        data[{{i*4-2},{},{},{}}] = image.hflip(curr_img)
        data[{{i*4-1},{},{},{}}] = image.vflip(curr_img)
        data[{ {i*4}, {},{},{}}] = image.hflip(image.vflip(curr_img))
        labels[{{i*4-3, i*4}}] = self._imdb[idxs[i]].label
    end
 
    return data, labels
    -- return curr_img, torch.Tensor({self._imdb[idxs[1]].label})
end
