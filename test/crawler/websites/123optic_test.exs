defmodule Crawler.Websites.OneTwoThreeOpticTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "returns an list of products" do
    use_cassette "123optic" do
      products = Crawler.Websites.OneTwoThreeOptic.execute
      assert length(products) > 0

      single_product = List.first(products)
      assert %Crawler.Struct{} = single_product
    end
  end
end
