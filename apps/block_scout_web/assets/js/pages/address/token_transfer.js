import $ from 'jquery'
import humps from 'humps'
import { createStore } from '../../lib/redux_helpers.js'

export const initialState = {
  requestLink: window.location.href
}

export function reducer (state = initialState, action) {
  switch (action.type) {
    case 'LOAD_TRANSFERS': {
      const $element = $('[data-selector="transactions-list"]')
      const $errorMessage = $('[data-selector="error-message"]')
      const $loadingMessage = $('[data-selector="loading-message"]')

      $.getJSON(state.requestLink, {type: 'JSON', block_number: $element.data('lastBlock')})
        .done(response => {
          response = humps.camelizeKeys(response)
          $loadingMessage.hide()

          if (response.transfers.length > 0) {
            $element.data('lastBlock', response.lastBlock)
            $element.html(response.transfers.join('') + response.nextPageButton)
            $('[data-selector="next-page-button"]').click((event) => {
              loadOlderTransactions()
            })
          } else {
            $element.html('')
            const $noTransactionsMessage = $('[data-selector="no-transactions-message"]')
            $noTransactionsMessage.show()
          }
        })
        .fail(fail => {
          $errorMessage.show()
          $loadingMessage.hide()
        })

      return Object.assign({}, state)
    }
    default:
      return state
  }
}

const $addressTokenTransferPage = $('[data-page="address-token-transfers"]')
var loadOlderTransactions = () => {}
if ($addressTokenTransferPage.length) {
  const store = createStore(reducer)

  loadOlderTransactions = () => store.dispatch({type: 'LOAD_TRANSFERS'});

  $('[data-selector="error-message"]').click((event) => {
    const $errorMessage = $(event.target)
    const $loadingMessage = $('[data-selector="loading-message"]')

    $errorMessage.hide()
    $loadingMessage.show()

    store.dispatch({type: 'LOAD_TRANSFERS'})
  })

  store.dispatch({type: 'LOAD_TRANSFERS'})
}
