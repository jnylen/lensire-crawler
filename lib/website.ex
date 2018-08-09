##
## Base file for websites
##

defmodule Crawler.Website do
    def execute(website) do
        website_module = case website do
            "123optic" -> "OneTwoThreeOptic"
            "1a-sehen" -> "Oneasehen"
            "1asehen"  -> "Oneasehen"
            sitename   -> sitename
        end

        # Create module name
        module = "Elixir.Crawler.Websites.#{website_module}" |> String.to_atom

        module.execute
        |> export_to_json(website)
    end

    def export_to_json(items, file_name) do
        {:ok, file} = File.open "websites/#{file_name}.json", [:write]

        IO.binwrite file, Jason.encode!(items)

        File.close file
    end
end