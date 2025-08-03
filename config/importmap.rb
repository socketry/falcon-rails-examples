# Pin npm packages by running ./bin/importmap

pin "application", preload: true

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin "morphdom" # @2.7.7
pin "@socketry/live", to: "@socketry--live.js" # @0.14.0
pin "live"
