defmodule Crawler.Struct do
    @derive Jason.Encoder
    defstruct name: nil, url: nil, price: nil, currency: "EUR", product_id: nil, amount: nil, boxes: nil, in_stock: nil
end