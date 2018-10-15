defmodule Crawler.Websites.Lensexpress do
    import Meeseeks.CSS

    @moduledoc """
        Parses lensexpress.ee and turns it into a struct
    """

    @doc """
        `execute` is the function that will execute an amount of functions of returned
        data.
    """
    def execute do
        urls_to_fetch = urls()
        items = Enum.map(urls_to_fetch, fn(url) ->
            "#{url}?limit=50&___store=en"
            |> Crawler.Client.get
            |> parse_html
        end)

        List.flatten(items)
    end

    @doc """
        `urls` is an array of links to fetch and parse data from.
    """
    def urls() do
        [
            "https://www.lensexpress.ee/laatsed/1-paevased.html", # Dailies
            "https://www.lensexpress.ee/laatsed/1-2-week-disposables.html", # Weeklies
            "https://www.lensexpress.ee/laatsed/1-kuused.html", # Monthlies
            "https://www.lensexpress.ee/laatsed/3-6-kuused.html", # Multi Monthlies
            "https://www.lensexpress.ee/laatsed/toorilised-cyl.html", # Toric
            "https://www.lensexpress.ee/laatsed/multifokaalsed.html", # Multifocal
            "https://www.lensexpress.ee/laatsed/varvilised.html", # Colored
            "https://www.lensexpress.ee/laatsed/en-stardikomplektid-1-paevastele-laatsedele.html", # Starter set dailies
            "https://www.lensexpress.ee/laatsed/en-stardikomplektid-1-kuustele-laatsedele.html", # Starter set monthlies
        ]
    end

    @doc """
        `parse_html` is an function that parses the HTML retrieved from `execute` and turns
        it into one struct per contact lens.
    """
    def parse_html({:ok, %Tesla.Env{body: body}}) do
        for product <- Meeseeks.all(body, css("ol#products-list li")) do
            name = Meeseeks.one(product, css("h5.product-name a"))
            special_price = Meeseeks.one(product, css("div.price-box div.special-price span.price"))
            regular_price = Meeseeks.one(product, css("div.price-box span.regular-price"))

            icons = Enum.map(Meeseeks.all(product, css("div.icons_block img")), fn(icon) ->
                Meeseeks.attr(icon, "src")
                |> Path.basename
            end)

            in_stock = Enum.member?(icons, "instock_en_US.png")

            # Name
            %{name: product_name, amount: package_amount, boxes: boxes} = Crawler.Helper.name(Meeseeks.text(name))

            %{amount: price_amount, currency: currency} = case Meeseeks.text(special_price) do
                nil -> Crawler.Helper.parse_money(Meeseeks.text(regular_price))
                specialy ->  Crawler.Helper.parse_money(specialy)
            end

            %{"product_id" => product_id} = Regex.named_captures(~r/(?<product_id>[a-zA-z0-9\-]+?)\.html$/i, Meeseeks.attr(name, "href"))

            %Crawler.Struct{
                name: product_name,
                url: Meeseeks.attr(name, "href"),
                price: price_amount,
                currency: currency,
                amount: package_amount,
                boxes: boxes,
                product_id: product_id,
                in_stock: in_stock
            }
        end
    end
end
