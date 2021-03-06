defmodule Crawler.Websites.Oneasehen do
    import Meeseeks.CSS
    import Meeseeks.XPath

    @moduledoc """
        Parsing HTML from 1a-sehen.de and turns the data into Crawler struct
    """

    @doc """
        `execute` is the function that will execute an amount of functions of returned
        data.
    """
    def execute do
        urls_to_fetch = urls()
        items = Enum.map(urls_to_fetch, fn(url) ->
            url
            |> Crawler.Client.post(%{products_sort: 5, products_per_site: 1000})
            |> parse_html
        end)

        List.flatten(items)
    end

    @doc """
        `urls` is an array of links to fetch and parse data from.
    """
    def urls() do
        [
            "https://www.1a-sehen.de/Kontaktlinsen/Tageslinsen:::494_9_64.html",
            "https://www.1a-sehen.de/Kontaktlinsen/Wochenlinsen:::494_9_65.html",
            "https://www.1a-sehen.de/Kontaktlinsen/Monatslinsen:::494_9_66.html"
        ]
    end

    @doc """
        `parse_html` is an function that parses the HTML retrieved from `execute` and turns
        it into one struct per contact lens.
    """
    def parse_html({:ok, %Tesla.Env{body: body}}) do
        for product <- Meeseeks.all(body, css("div.liste-produkt")) do
            name = Meeseeks.one(product, css("h3.liste-produkt-name a"))
            price_meta = Meeseeks.one(product, xpath("//meta[@itemprop='price']"))
            currency_meta = Meeseeks.one(product, xpath("//meta[@itemprop='priceCurrency']"))
            availability_meta = Meeseeks.one(product, xpath("//link[@itemprop='availability']"))

            # Available?
            in_stock = case Meeseeks.attr(availability_meta, "href") do
                "http://schema.org/InStock" -> true
                _ -> false
            end

            # Name
            %{name: product_name, amount: package_amount, boxes: boxes} = Crawler.Helper.name(Meeseeks.text(name))
            %{"product_id" => product_id} = Regex.named_captures(~r/::(?<product_id>[\d]+).html/i, Meeseeks.attr(name, "href"))

            # Price
            {price, _} = Float.parse(Meeseeks.attr(price_meta, "content"))

            %Crawler.Struct{
                name: product_name,
                url: Meeseeks.attr(name, "href"),
                price: price,
                currency: Meeseeks.attr(currency_meta, "content"),
                in_stock: in_stock,
                amount: package_amount,
                boxes: boxes,
                product_id: product_id
            }
        end
    end
end
