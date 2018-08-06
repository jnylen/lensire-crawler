defmodule Crawler.Helper do
    # Pretty up the name
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

    def name_only(name) do
        # Clean up name
        name = Regex.replace(~r/(\d+)( |)x( |)(\d+) (Stück|stk\.)/i, name, "")
        name = Regex.replace(~r/([\d]+)( pack| tageslinsen| pk|-box|box|-pack|-boxes| boxes|pk|\/box| linser|er pack|er-box|er|stk| stk| stück|pcs| pcs| lenses|pc| pc)(s|)/i, name, "")
        name = Regex.replace(~r/contact lens(es|)/i, name, "")
        name = Regex.replace(~r/(contacts|Linser|lins|Piilolinssit)$/i, name, "")
        name = Regex.replace(~r/\[(Daily|Weekly|Monthly) contacts\]/i, name, "")
        name = Regex.replace(~r/(Tageslinsen|Tageslinse|Tages|Monatskontak)/i, name, "")
        name = Regex.replace(~r/(Daily|Weekly|Monthly|1-2 Week) (contacts)( Acuvue|)/i, name, "")
        name = Regex.replace(~r/(CIBA Vision|CooperVision|Cooper Vision|Bausch & Lomb)/i, name, "")
        name = Regex.replace(~r/Sparpaket( für|) (\d+) (Monate|M)/i, name, "")
        name = Regex.replace(~r/\-(\d+)%/i, name, "")
        name = String.replace(name, ~r/ +/, " ")
        name = String.trim(name)
        name = String.replace(name, ~r/(Kontaktlinsen von \/ Alcon|Kontaktlinsen von Johnson & Johnson)/i, "")
        name = String.replace(name, ~r/Kontaktlinsen, von \/ Alcon$/i, "")
        name = String.trim(name)
        name = String.replace(name, ~r/(Lentilles de contact| mit Stärke|Kontaktlinsen)/i, "")
        name = String.replace(name, ~r/ (realisation|kampanj)$/i, "")
        name = String.replace(name, ~r/\[\]/, "")
        name = String.replace(name, ~r/\(\)/, "")
        name = String.replace(name, ~r/ Box$/i, "")
        name = String.replace(name, ~r/ -$/, "")
        name = String.replace(name, ~r/,$/, "")
        name = String.replace(name, ~r/\!$/, "")
        name = String.replace(name, ~r/(Daily|Weekly|Monthly|Montly|1-2 Week)$/i, "")
        name = String.replace(name, ~r/\+ free/i, "")
        name = String.replace(name, ~r/new/i, "")
        name = String.replace(name, ~r/starter set/i, "")
        
        # Clean up more
        name = String.replace(name, ~r/\'/, "")
        name = String.replace(name, ~r/\"/, "")
        name = String.replace(name, ~r/\)/, "")
        name = String.replace(name, ~r/\(/, "")
        name = String.replace(name, ~r/ +/, " ")
        name = String.replace(name, ~r/, -/, " -")
        name = String.replace(name, ~r/&amp;/, "&")

        name = String.trim(name)

        name
    end

    def parse_money(amount) do
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