# https://github.com/rails/rails/issues/2483
# https://github.com/rails/rails/issues/3047

class ActionDispatch::Session::AbstractStore
  def call(env)
    # the only place I could find that knows how to mutate out the `:all` was the CookieJar, so we use that before Rack gets an invalid :domain
    ActionDispatch::Request.new(env).cookie_jar.handle_options(@default_options)
    super
  end
end
