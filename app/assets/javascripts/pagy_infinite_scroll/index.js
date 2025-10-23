// Pagy Infinite Scroll - Main Entry Point
// This file provides the controller for manual registration

import PagyInfiniteScrollController from "./infinite_scroll_controller"

// Export for manual registration in host app
export { PagyInfiniteScrollController }
export default PagyInfiniteScrollController

// Auto-register if Stimulus application is available globally
if (typeof window !== 'undefined' && window.Stimulus) {
  window.Stimulus.register("pagy-infinite-scroll", PagyInfiniteScrollController)
}
