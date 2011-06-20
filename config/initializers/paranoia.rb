# This forces every model to explicitly whitelist accessible attributes
ActiveRecord::Base.send(:attr_accessible, nil)