# PagyInfiniteScroll

A Rails gem that adds infinite scroll functionality using Pagy and Stimulus. Load initial records and automatically fetch more as users scroll down - perfect for optimizing pages with large datasets.

## Features

- 🚀 Easy integration with existing Rails apps
- 📦 Built on Pagy (fast, lightweight pagination)
- ⚡ Stimulus controller for smooth infinite scrolling
- 🎨 Customizable HTML rendering
- 🔧 Configurable scroll threshold and items per page
- 💾 Preserves URL parameters during scroll

## Installation

Add to your Gemfile:

```ruby
gem 'pagy_infinite_scroll', '~> 0.2.0'
```

Then run:

```bash
bundle install
rails generate pagy_infinite_scroll:install
```

The generator will automatically detect your JavaScript setup and configure accordingly:

### For importmap-rails (auto-configured ✅)
The generator will:
- Add pin to `config/importmap.rb`
- Add import to `app/javascript/application.js`
- Auto-register controller with Stimulus
- **No manual steps needed!**

### For jsbundling-rails (esbuild/webpack/rollup)
The generator will:
- Create `config/initializers/pagy_infinite_scroll.rb`
- Copy controller to `app/javascript/controllers/pagy_infinite_scroll_controller.js`
- Display registration instructions
- Run `yarn build` after setup

## Quick Start

This gem provides **two approaches** for infinite scrolling:

1. **Server-Side Rendering** (Simple) - HTML rendered on the server using `.js.erb` templates
2. **JSON API** (Advanced) - JSON responses with client-side HTML rendering

Choose the approach that fits your needs!

---

## Approach 1: Server-Side Rendering (Recommended for Simple Use Cases)

This approach is simpler and requires minimal JavaScript knowledge. Perfect for standard CRUD operations.

### 1. Controller Setup

Use the gem's helper methods:

```ruby
class ProductsController < ApplicationController
  def index
    @pagy, @products = pagy_infinite_scroll(Product.all, limit: 50)

    respond_to do |format|
      format.html
      format.js  # Responds to .js.erb template
    end
  end
end
```

### 2. View Setup (HTML)

```erb
<!-- app/views/products/index.html.erb -->
<%= infinite_scroll_container(@pagy, products_path(format: :js),
      data: { render_mode: 'js' }) do %>
  <%= infinite_scroll_items_container(tag: 'div', class: 'products-list') do %>
    <%= render @products %>
  <% end %>
  <%= infinite_scroll_loading_indicator %>
<% end %>
```

### 3. Create JavaScript Response Template

```erb
<!-- app/views/products/index.js.erb -->
<%= pagy_infinite_scroll_append '.products-list', @pagy, @products %>
```

**That's it!** The gem automatically:
- Renders your `_product.html.erb` partial for each item
- Appends the HTML to the container
- Updates pagination state
- No JavaScript customization needed!

---

## Approach 2: JSON API (For Complex Use Cases)

Use this approach when you need:
- API reusability (mobile apps, SPAs)
- Complex client-side logic
- Full control over rendering

### 1. Controller Setup

```ruby
class ProductsController < ApplicationController
  def index
    @pagy, @products = pagy_infinite_scroll(Product.all, limit: 50)

    respond_to do |format|
      format.html
      format.json do
        render json: pagy_infinite_scroll_json(@pagy, @products) { |product|
          {
            id: product.id,
            title: product.title,
            price: product.price
          }
        }
      end
    end
  end
end
```

### 2. View Setup

```erb
<%= infinite_scroll_container(@pagy, products_path(format: :json)) do %>
  <%= infinite_scroll_items_container do %>
    <%= render @products %>
  <% end %>
  <%= infinite_scroll_loading_indicator %>
<% end %>
```

### 3. Create Custom Stimulus Controller

**For JSON API approach, you MUST override the `createItemHTML` method** to tell the gem how to render your specific HTML.

**For jsbundling-rails apps:**

Create a custom Stimulus controller that extends the gem's base controller:

```javascript
// app/javascript/controllers/products_scroll_controller.js
import PagyInfiniteScrollController from "./pagy_infinite_scroll_controller"

export default class extends PagyInfiniteScrollController {
  // Override this method to customize HTML for loaded items
  createItemHTML(record) {
    return `
      <div class="product-card">
        <h3>${record.title}</h3>
        <p class="price">$${record.price}</p>
        <span class="badge">${record.category}</span>
      </div>
    `
  }
}
```

Register it in `app/javascript/controllers/index.js`:

```javascript
import ProductsScrollController from "./products_scroll_controller"
application.register("products-scroll", ProductsScrollController)
```

**For importmap-rails apps:**

The controller is available globally as `window.PagyInfiniteScrollController`:

```javascript
// app/javascript/controllers/products_scroll_controller.js
class ProductsScrollController extends window.PagyInfiniteScrollController {
  createItemHTML(record) {
    return `
      <div class="product-card">
        <h3>${record.title}</h3>
        <p class="price">$${record.price}</p>
        <span class="badge">${record.category}</span>
      </div>
    `
  }
}

// Register with Stimulus
Stimulus.register("products-scroll", ProductsScrollController)
```

Use in your view:

```erb
<div data-controller="products-scroll"
     data-products-scroll-url-value="<%= products_path(format: :json) %>"
     data-products-scroll-page-value="1"
     data-products-scroll-has-more-value="<%= @pagy.next.present? %>">
  ...
</div>
```

### Real-World Example: Form with Checkboxes

```javascript
// app/javascript/controllers/distribution_preferences_scroll_controller.js
import PagyInfiniteScrollController from "./pagy_infinite_scroll_controller"

export default class extends PagyInfiniteScrollController {
  createItemHTML(record) {
    const isChecked = record.selected ? 'checked' : ''

    return `
      <div class="flex items-center gap-4 p-4">
        <input type="checkbox"
               name="product_ids[]"
               value="${record.id}"
               id="product_${record.id}"
               ${isChecked}
               class="form-checkbox">

        <label for="product_${record.id}" class="flex-1">
          <div class="font-medium">${record.title}</div>
          ${record.vendor_name ? `
            <span class="badge">${record.vendor_name}</span>
          ` : ''}
          <span class="text-gray-500">
            ${record.variants_count} variants
          </span>
        </label>
      </div>
    `
  }
}
```

**Key Points:**
- Only ~60 lines of custom JavaScript needed
- The gem handles all the scroll detection, AJAX, and state management
- You only define the HTML structure for your specific use case
- This keeps your code DRY and maintainable

## Configuration

Edit `config/initializers/pagy_infinite_scroll.rb`:

```ruby
PagyInfiniteScroll.configure do |config|
  config.items_per_page = 50      # Items per page (default: 50)
  config.scroll_threshold = 100   # Pixels from bottom to trigger load (default: 100)
  config.loading_indicator = true # Show loading indicator (default: true)
  config.preserve_state = true    # Preserve URL params (default: true)
  config.debounce_delay = 500     # Debounce for search in ms (default: 500)
  config.render_mode = 'json'     # Rendering mode: 'json' or 'js' (default: 'json')
end
```

## Data Attributes Reference

### Container Attributes
- `data-pagy-infinite-scroll-url-value` - JSON endpoint URL (required)
- `data-pagy-infinite-scroll-page-value` - Current page number (default: 1)
- `data-pagy-infinite-scroll-has-more-value` - Has more pages? (required, true/false)
- `data-pagy-infinite-scroll-threshold-value` - Scroll threshold in pixels (optional)

### Targets
- `data-pagy-infinite-scroll-target="itemsContainer"` - Where to append items
- `data-pagy-infinite-scroll-target="loadingIndicator"` - Loading indicator element

## Events

The controller dispatches custom events you can listen to:

```javascript
// In your custom controller
connect() {
  super.connect()

  this.element.addEventListener('pagy-infinite-scroll:loaded', (event) => {
    console.log('Loaded page:', event.detail.page)
    console.log('Has more:', event.detail.hasMore)
    console.log('Count:', event.detail.count)
  })

  this.element.addEventListener('pagy-infinite-scroll:error', (event) => {
    console.error('Error:', event.detail.error)
  })
}
```

## Troubleshooting

### Items not loading on scroll

1. **Check browser console** for JavaScript errors
2. **Verify JSON endpoint** returns correct format:
   ```json
   {
     "records": [...],
     "pagy": {
       "page": 1,
       "pages": 10,
       "next": 2,
       "count": 500
     }
   }
   ```
3. **Check Network tab** to see if AJAX requests are being made
4. **Verify controller is connected** - should see console log on page load

### Controller not found error

Run `yarn build` (or `npm run build`) to rebuild JavaScript bundle.

### Helpers not available in controller

Restart your Rails server after installing the gem.

### Items render as JSON instead of HTML

You need to create a custom controller that extends the base controller and overrides the `createItemHTML()` method (see "Custom HTML Rendering" section above).

## JavaScript Setup: importmap vs jsbundling

This gem works with **both** importmap-rails and jsbundling-rails:

### importmap-rails ✅
- **Setup**: Automatic via generator
- **Controller**: Standalone file, auto-registers with Stimulus
- **Extending**: Use `window.PagyInfiniteScrollController` as base class
- **Advantages**: Zero build step, simpler setup
- **File location**: Served from gem's assets

### jsbundling-rails (esbuild/webpack/rollup) ✅
- **Setup**: Manual file copy (bundlers can't access gem paths)
- **Controller**: Import from `./pagy_infinite_scroll_controller`
- **Extending**: Use ES6 `import` and `extends`
- **Advantages**: Full ES6 module support, tree-shaking
- **File location**: `app/javascript/controllers/`

Both setups support the same features and API!

## Requirements

- Rails 7.0+
- Pagy gem (add `gem 'pagy'` to your Gemfile)
- Stimulus (Hotwire)
- Either importmap-rails OR jsbundling-rails (esbuild, webpack, or rollup)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hassanharoon86/pagy_infinite_scroll/issues

## License

The gem is available as open source under the terms of the MIT License.
