# PagyInfiniteScroll

A Rails gem that adds infinite scroll functionality using Pagy and Stimulus.

## Installation

```ruby
gem 'pagy_infinite_scroll'
```

## Quick Start

### Controller
```ruby
class ProductsController < ApplicationController
  def index
    @pagy, @products = pagy_infinite_scroll(Product.all)

    respond_to do |format|
      format.html
      format.json do
        render json: pagy_infinite_scroll_json(@pagy, @products) { |product|
          { id: product.id, title: product.title }
        }
      end
    end
  end
end
```

### View
```erb
<%= infinite_scroll_container(@pagy, products_path(format: :json)) do %>
  <%= infinite_scroll_items_container do %>
    <%= render @products %>
  <% end %>
  <%= infinite_scroll_loading_indicator %>
<% end %>
```

See full documentation at: https://github.com/hassanharoon86/pagy_infinite_scroll
