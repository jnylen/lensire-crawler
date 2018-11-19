defmodule Crawler.Helper do

    @moduledoc """
        `Helper` is a library for different functions for parsing a contact lens item from
        various sources
    """

    @doc """
        `name` parses an name for package_amount, special types etc and sends it to `name_only`
        to be converted to a normal match-friendly name.

        ## Example:

            iex> Crawler.Helper.name("1 Day Acuvue TruEye 30 tageslinsen")
            %{amount: 30, boxes: nil, name: "1 Day Acuvue TruEye"}
    """
    def name(name) do
        add_pack_amounts = case Regex.named_captures(~r/\+ (?<amount>[\d]+)( pack| tageslinsen| pk|pk|-pack|\/box| linser|er-box|er|stk| stk| stück|pcs| pcs| lenses|pc| pc)(s|)/i, name) do
            %{"amount" => amount} -> String.to_integer(amount)
            _ -> nil
        end

        # Different types of saying pack
        pack_amounts = case Regex.named_captures(~r/(?<amount>[\d]+)( pack| tageslinsen| pk|pk|-pack|\/box| linser|er-box|er|stk| stk| stück|pcs| pcs| lenses|pc| pc)(s|)/i, name) do
            %{"amount" => amount} -> case add_pack_amounts do
                nil -> String.to_integer(amount)
                add -> add + String.to_integer(amount)
                end
            _ -> nil
        end

        # Boxes (original amount * box)
        boxes = case Regex.named_captures(~r/(?<amount>[\d]+)(-box|box|-boxes| boxes)(s|)/i, name) do
            %{"amount" => amount} -> String.to_integer(amount)
            _ -> nil
        end

        # Special parse. 2x360
        special = case Regex.named_captures(~r/(?<boxes>[\d]+)( |)x( |)(?<contacts>[\d]+)( Stück| stk\.)(s|)/i, name) do
            %{"boxes" => boxes, "contacts" => contacts} -> String.to_integer(boxes) * String.to_integer(contacts)
            _ -> nil
        end

        pack_amount = case special do
            nil -> pack_amounts
            pack_amount -> pack_amount
        end

        # Clean up the name
        name = name_only(name)

        %{name: name, amount: pack_amount, boxes: boxes}
    end

    @doc """
        `name_only` cleans a name up from various things such as brand names etc so its gets turned into a name
        that can be easily matched towards the product database.

        ## Example:

            iex> Crawler.Helper.name_only("1 Day Acuvue TruEye 30 tageslinsen")
            "1 Day Acuvue TruEye"
    """
    def name_only(name) do
        # Clean up name
        name
        |> String.replace(~r/(\d+)( |)x( |)(\d+) (Stück|stk\.)/i, "")
        |> String.replace(~r/([\d]+)( pack| tageslinsen| pk|-box|box|-pack|-boxes| boxes|pk|\/box| linser|er pack|er-box|er|stk| stk| stück|pcs| pcs| lenses|pc| pc)(s|)/i, "")
        |> String.replace(~r/contact lens(es|)/i, "")
        |> String.replace(~r/(contacts|Linser|lins|Piilolinssit)$/i, "")
        |> String.replace(~r/\[(Daily|Weekly|Monthly) contacts\]/i, "")
        |> String.replace(~r/(Tageslinsen|Tageslinse|Tages|Monatskontak|Monatslinsen)/i, "")
        |> String.replace(~r/(Daily|Weekly|Monthly|1-2 Week) (contacts)( Acuvue|)/i, "")
        |> String.replace(~r/(CIBA Vision|CooperVision|Cooper Vision|Bausch & Lomb|Johnson&Johnson|Bausch&Lomb|MPG&E|Johnson & Johnson|Alcon)/i, "")
        |> String.replace(~r/Sparpaket( für|) (\d+) (Monate|M)/i, "")
        |> String.replace(~r/\-(\d+)%/i, "")
        |> String.replace(~r/ +/, " ")
        |> String.trim
        |> String.replace(~r/(Kontaktlinsen von \/ Alcon|Kontaktlinsen von Johnson & Johnson)/i, "")
        |> String.replace(~r/Kontaktlinsen, von \/ Alcon$/i, "")
        |> String.trim
        |> String.replace(~r/(Lentilles de contact| mit Stärke|Kontaktlinsen)/i, "")
        |> String.replace(~r/ (realisation|kampanj)$/i, "")
        |> String.replace(~r/\[\]/, "")
        |> String.replace(~r/\(\)/, "")
        |> String.replace(~r/ Box$/i, "")
        |> String.replace(~r/ -$/, "")
        |> String.replace(~r/,$/, "")
        |> String.replace(~r/\!$/, "")
        |> String.replace(~r/(Daily|Weekly|Monthly|Montly|1-2 Week)$/i, "")
        |> String.replace(~r/\+ free/i, "")
        |> String.replace(~r/new/i, "")
        |> String.replace(~r/starter set/i, "")
        |> String.replace(~r/1Day/i, "1 Day")
        |> String.replace(~r/\'/, "")
        |> String.replace(~r/\"/, "")
        |> String.replace(~r/\)/, "")
        |> String.replace(~r/\(/, "")
        |> String.replace(~r/ +/, " ")
        |> String.replace(~r/, -/, " -")
        |> String.replace(~r/&amp;/, "&")
        |> String.trim
    end

    @doc """
        `parse_amount` parses a string of an price into the correct way we are doing it.

        ## Examples
            iex> Crawler.Helper.parse_money("10.00 EUR")
            %{amount: 10.0, currency: "EUR"}
    """
    def parse_money(amount) do
        amount = String.replace(amount, "€", "EUR")

        amount_new = Regex.run(~r/-?[0-9]{1,300}(,[0-9]{3})*(\.[0-9]+)?/, amount)
        |> List.first
        |> String.replace(~r/\,/, "")

        currency = Regex.run(~r/([A-Z]{3})/, amount)

        if currency do
            %{amount: String.to_float(amount_new), currency: List.first(currency)}
        else
            %{amount: nil, currency: nil}
        end
    end
end
