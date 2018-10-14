defmodule Crawler.Websites.LensexpressTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
  end

  test "returns an list of products" do
    use_cassette "lensexpress" do
      products = Crawler.Websites.Lensexpress.execute
      assert length(products) > 0

      single_product = List.first(products)
      assert %Crawler.Struct{} = single_product
    end
  end
end
