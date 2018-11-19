defmodule Crawler.Websites.Nissen do
  import Meeseeks.CSS

  @moduledoc """
      Parses Nissen.fi and turns it into a struct
  """

  def execute do
    # Url
    url = "https://www.nissen.fi/piilolinssit?p=1"

    # Get available pages
    pages =
      url
      |> Crawler.Client.get()
      |> get_pages


    page_links = [url] ++ pages

    items =
      Enum.map(page_links, fn url ->
        url
        |> Crawler.Client.get()
        |> parse_html
      end)

    List.flatten(items)
  end

  # Get pages
  def get_pages({:ok, %Tesla.Env{body: body}}) do
    for page <- Meeseeks.all(body, css("ul.pages-items li.item a.page")) do
      Meeseeks.attr(page, "href")
    end
  end

  # HTML Parser
  def parse_html({:ok, %Tesla.Env{body: body}}) do
    for product <- Meeseeks.all(body, css("ol.products li.product-item")) do
      name = Meeseeks.one(product, css("strong.product-item-name a"))
      regular_price = Meeseeks.one(product, css("span.price-final_price span span.price"))

      price =
        Meeseeks.text(regular_price)
        |> String.replace(",", ".")

      lens_amount =
        case Regex.named_captures(
               ~r/(?<amount>[\d]+)/i,
               Meeseeks.text(Meeseeks.one(product, css("div.package-size")))
             ) do
          %{"amount" => amount} -> String.to_integer(amount)
          _ -> nil
        end

      # Name
      %{name: product_name} = Crawler.Helper.name(Meeseeks.text(name))

      %{amount: price_amount, currency: currency} = Crawler.Helper.parse_money(price)

      product_id = Meeseeks.one(product, css("div.price-box"))

      %Crawler.Struct{
        name: product_name,
        url: Meeseeks.attr(name, "href"),
        price: price_amount,
        currency: currency,
        amount: lens_amount,
        product_id: Meeseeks.attr(product_id, "data-product-id")
      }
    end
  end
end
