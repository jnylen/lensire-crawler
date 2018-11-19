defmodule Crawler.Website do

    @moduledoc """
        `Website` is the base library for all websites which means
        this is run towards all of the website parsers.
    """

    @doc """
        `execute` is run towards an `website` which can be any
        website listed in the README.
    """
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

    @doc """
        `export_to_json` turns an array of `structs` into an json format and writes it
        to a file inside of `websites` folder.
    """
    def export_to_json(items, file_name) do
        {:ok, file} = File.open "websites/#{file_name}.json", [:write]

        IO.binwrite file, Jason.encode!(items)

        File.close file
    end
end
