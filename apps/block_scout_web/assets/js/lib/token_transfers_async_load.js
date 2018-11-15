import $ from 'jquery'

const tokenTransferListing = (element, pageUrl) => {
  const $element = $(element)
  const $loading = $element.find('[data-loading-token-transfers]')
  const $errorMessage = $element.find('[data-error-message]')
  $.getJSON(pageUrl)
    .done(response => $element.html(response.transfers.join('') + response.next_page_button))
    .fail(fail => {
      $loading.hide()
      $errorMessage.show()
    })
}

const pageLink = window.location.href + (window.location.search ? '&type=JSON' : '?type=JSON')

$('[data-token-transfers-listing]').on('click', '[data-token-transfers-next-page]', (event) => {
  const $button = $(event.target)
  const nextPageLink = $button.data('next-page-link')

  history.pushState({}, null, nextPageLink)

  $button.html(`
    <span class='loading-spinner-small mr-2'>
      <span class='loading-spinner-block-1'></span>
      <span class='loading-spinner-block-2'></span>
    </span>
  `)

  tokenTransferListing($button.closest('[data-token-transfers-listing]'), nextPageLink + '&type=JSON')
})

$('[data-token-transfers-listing]').on('click', '[data-error-message]', (event) => {
  const $link = $(event.target)
  const $loading = $('[data-loading-token-transfers]')

  $link.hide()
  $loading.show()

  tokenTransferListing($link.closest('[data-token-transfers-listing]'), pageLink)
})

$('[data-token-transfers-listing]').each((_index, element) => tokenTransferListing(element, pageLink))
