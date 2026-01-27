# frozen_string_literal: true

require 'pagy'

# Default items per page
Pagy::DEFAULT[:items] = 10

# Overflow handling - return empty results for pages beyond total
Pagy::DEFAULT[:overflow] = :empty_page
