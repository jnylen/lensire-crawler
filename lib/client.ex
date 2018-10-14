defmodule Crawler.Client do
    use Tesla

    @moduledoc """
        HTTP Client for parsing websites
    """

    plug Tesla.Middleware.Compression, format: "gzip"
    plug Tesla.Middleware.Headers, [{"user-agent", "Lensire.com Crawler/1.0"}]
    plug Tesla.Middleware.FollowRedirects
    plug Tesla.Middleware.FormUrlencoded
end
