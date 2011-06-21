# This forces every model to explicitly whitelist accessible attributes
ActiveRecord::Base.send(:attr_accessible, nil)

# This is necessary to prevent errors when using AR's DB session store
ActiveRecord::Base.send(:attr_accessible, :session_id)