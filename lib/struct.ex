defmodule Crawler.Struct do
    @derive Jason.Encoder

    @moduledoc """
        The struct of products with jason encoder enabled to turn it into a json file
    """

    defstruct name: nil, url: nil, price: nil, currency: "EUR", product_id: nil, amount: nil, boxes: nil, in_stock: nil
end
