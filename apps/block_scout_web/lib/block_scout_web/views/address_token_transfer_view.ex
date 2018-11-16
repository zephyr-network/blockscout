defmodule BlockScoutWeb.AddressTokenTransferView do
  use BlockScoutWeb, :view

  def next_page_button(conn, address_hash, contract_hash, next_page_params) do
    next_page_url = address_token_transfers_path(conn, :index, address_hash, contract_hash, next_page_params)

    """
    <div
      class="button button-secondary button-sm float-right mt-3"
      data-selector="next-page-button"
      data-next-page-link="#{next_page_url}">
      #{gettext("Older")}
    </div>
    """
  end
end
