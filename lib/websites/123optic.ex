# Importer for 123optic.com type of websites
defmodule Crawler.Websites.OneTwoThreeOptic do
    import Meeseeks.CSS

    def execute do
        urls_to_fetch = urls()
        items = Enum.map(urls_to_fetch, fn(url) ->
            url
            |> Crawler.Client.post(%{products_sort: 5, products_per_site: 1000})
            |> parse_html
        end)

        List.flatten(items)
    end

    # URLS to fetch
    def urls() do
        [
            "https://www.123optic.com/eu-en/daily-lenses/",
            "https://www.123optic.com/eu-en/weekly-lenses/",
            "https://www.123optic.com/eu-en/monthly-lenses/"
        ]
    end

    # HTML Parser
    def parse_html({:ok, %Tesla.Env{body: body}}) do
        for product <- Meeseeks.all(body, css("ul.products li.column")) do
            name = Meeseeks.one(product, css("h2.product__title a"))
            lens_amount = Meeseeks.one(product, css("h2.product__title span.subtitle_badge"))
            price = Meeseeks.one(product, css("div.product__price"))
            product_div = Meeseeks.one(product, css("div.product"))

            %{name: product_name} = Crawler.Helper.name(Meeseeks.text(name))

            # Package amount
            package_amount = case Regex.named_captures(~r/(?<amount>[\d]+) lenses/i, Meeseeks.text(lens_amount)) do
                %{"amount" => package_amount} -> String.to_integer(package_amount)
                _ -> nil
            end

            # Price
            price = case Regex.named_captures(~r/€ (?<first_price>[\d]+) ,(?<second_price>[\d]+)/i, Meeseeks.text(price)) do
                %{"first_price" => first_price, "second_price" => second_price} -> "#{first_price}.#{second_price}"
                _ -> nil
            end
            {price, _} = Float.parse(price)

            %Crawler.Struct{
                name: product_name,
                url: Meeseeks.attr(name, "href"),
                amount: package_amount,
                product_id: Meeseeks.attr(product_div, "data-id-product"),
                price: price
            }
        end
    end
end