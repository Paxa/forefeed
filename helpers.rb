module Sinatra
  module Helpers
    module Haml
      module Links
        def domain(tld_length = 1)
          'localhost:4567'
        end

        def asset_url(path, tld_length = 1)
          '/' + path
        end
      end
    end
  end
end
