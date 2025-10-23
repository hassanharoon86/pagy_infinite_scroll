import { application } from "@hotwired/stimulus"
import InfiniteScrollController from "./infinite_scroll_controller"

application.register("pagy-infinite-scroll", InfiniteScrollController)

export { InfiniteScrollController }
