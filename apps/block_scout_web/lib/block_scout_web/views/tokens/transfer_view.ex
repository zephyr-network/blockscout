defmodule BlockScoutWeb.Tokens.TransferView do
  use BlockScoutWeb, :view

  alias BlockScoutWeb.Tokens.OverviewView

  def next_page_button(conn, contract, next_page_params) do
    next_page_url = token_transfer_path(conn, :index, contract, Map.delete(next_page_params, "type"))

    """
      <div class="button button-secondary button-small float-right mt-4" data-token-transfers-next-page data-next-page-link=#{
      next_page_url
    }>
        #{gettext("Older")}
      </div>
    """
  end
end
