defmodule BlockScoutWeb.Tokens.TransferController do
  use BlockScoutWeb, :controller

  alias BlockScoutWeb.Tokens.TransferView
  alias Explorer.Chain
  alias Phoenix.View

  import BlockScoutWeb.Chain, only: [split_list_by_page: 1, paging_options: 1, next_page_params: 3]

  def index(conn, %{"token_id" => address_hash_string, "type" => "JSON"} = params) do
    with {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string),
         {:ok, token} <- Chain.token_from_address_hash(address_hash),
         token_transfers <- Chain.fetch_token_transfers_from_token_hash(address_hash, paging_options(params)) do
      {token_transfers_paginated, next_page} = split_list_by_page(token_transfers)

      next_page_button =
        case next_page_params(next_page, token_transfers_paginated, params) do
          nil ->
            ""

          next_page_params ->
            TransferView.next_page_button(conn, token.contract_address_hash, next_page_params)
        end

      transfers_json =
        Enum.map(token_transfers, fn transfer ->
          View.render_to_string(
            TransferView,
            "_token_transfer.html",
            conn: conn,
            token: token,
            transfer: transfer
          )
        end)

      json(conn, %{transfers: transfers_json, next_page_button: next_page_button})
    else
      :error ->
        unprocessable_entity(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end

  def index(conn, %{"token_id" => address_hash_string}) do
    with {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string),
         {:ok, token} <- Chain.token_from_address_hash(address_hash) do
      render(
        conn,
        "index.html",
        token: token,
        holders_count_consolidation_enabled: Chain.token_holders_counter_consolidation_enabled?(),
        total_token_transfers: Chain.count_token_transfers_from_token_hash(address_hash),
        total_token_holders: Chain.count_token_holders_from_token_hash(address_hash)
      )
    else
      :error ->
        not_found(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
