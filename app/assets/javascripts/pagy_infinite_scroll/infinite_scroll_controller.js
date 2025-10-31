import { Controller } from "@hotwired/stimulus"

// Infinite Scroll Controller for Pagy
// Can be used standalone or extended
export default class PagyInfiniteScrollController extends Controller {
  static targets = ['itemsContainer', 'loadingIndicator']
  static values = {
    url: String,
    page: Number,
    loading: Boolean,
    hasMore: Boolean,
    threshold: { type: Number, default: 100 },
    preserveState: { type: Boolean, default: true },
    renderMode: { type: String, default: 'json' } // 'json' or 'js'
  }

  connect() {
    console.log('[PagyInfiniteScroll] Controller connected')
    this.pageValue = this.pageValue || 1
    this.loadingValue = false
    this.boundHandleScroll = this.handleScroll.bind(this)
    this.element.addEventListener('scroll', this.boundHandleScroll)

    // Make controller accessible for server-side updates
    this.element.pagyInfiniteScroll = this
  }

  disconnect() {
    this.element.removeEventListener('scroll', this.boundHandleScroll)
  }

  handleScroll() {
    const scrollThreshold = this.hasThresholdValue ? this.thresholdValue : 100
    const nearBottom = this.element.scrollHeight - this.element.scrollTop - this.element.clientHeight < scrollThreshold

    if (nearBottom && !this.loadingValue && this.hasMoreValue) {
      this.loadMore()
    }
  }

  async loadMore() {
    if (this.loadingValue || !this.hasMoreValue) return

    console.log('[PagyInfiniteScroll] Loading more items...')
    this.loadingValue = true
    this.showLoading()

    const nextPage = this.pageValue + 1

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set('page', nextPage)

      // Preserve current URL parameters
      const currentParams = new URLSearchParams(window.location.search)
      currentParams.forEach((value, key) => {
        if (key !== 'page') {
          url.searchParams.set(key, value)
        }
      })

      // Determine Accept header based on render mode
      const acceptHeader = this.renderModeValue === 'js'
        ? 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
        : 'application/json'

      const response = await fetch(url, {
        headers: {
          'Accept': acceptHeader,
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      // Handle different response types
      if (this.renderModeValue === 'js') {
        // For .js.erb responses, evaluate the JavaScript
        const jsCode = await response.text()
        eval(jsCode)
        // Note: State is updated by the server-rendered JS via pagy_infinite_scroll_append
      } else {
        // For JSON responses, use the client-side rendering
        const data = await response.json()

        // Dispatch event with data for custom handling
        const event = this.dispatch('beforeAppend', {
          detail: { data },
          cancelable: true
        })

        if (!event.defaultPrevented) {
          this.appendItems(data)
        }

        // Update pagination state
        this.pageValue = data.pagy.page
        this.hasMoreValue = data.pagy.next !== null

        console.log(`[PagyInfiniteScroll] Loaded page ${this.pageValue}, has more: ${this.hasMoreValue}`)

        // Dispatch success event
        this.dispatch('loaded', {
          detail: {
            page: this.pageValue,
            hasMore: this.hasMoreValue,
            count: data.records.length
          }
        })
      }

    } catch (error) {
      console.error('[PagyInfiniteScroll] Error loading more items:', error)
      this.dispatch('error', { detail: { error } })
    } finally {
      this.loadingValue = false
      this.hideLoading()
    }
  }

  appendItems(data) {
    if (!this.hasItemsContainerTarget) {
      console.warn('[PagyInfiniteScroll] No items container target found')
      return
    }

    const records = data.records || data.items || data.products || []

    records.forEach(record => {
      const html = this.createItemHTML(record)
      this.itemsContainerTarget.insertAdjacentHTML('beforeend', html)
    })
  }

  createItemHTML(record) {
    // This method should be overridden by the application
    // or use a custom event listener
    console.warn('[PagyInfiniteScroll] createItemHTML should be overridden')
    return `<div>${JSON.stringify(record)}</div>`
  }

  showLoading() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove('hidden')
    }
  }

  hideLoading() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.add('hidden')
    }
  }

  // Public API methods
  reset() {
    this.pageValue = 1
    this.hasMoreValue = true
    if (this.hasItemsContainerTarget) {
      this.itemsContainerTarget.innerHTML = ''
    }
  }

  reload() {
    this.reset()
    this.loadMore()
  }
}
