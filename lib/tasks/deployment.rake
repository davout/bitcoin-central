namespace :deployment do
  desc "Renders  the different static pages from templates under views/static"
  task :render_static_pages => :environment do
    view_path = Rails.configuration.view_path

    Dir.glob(File.join(view_path, "static/*")).each do |page|
      page_name = "#{File.basename(page).gsub(/\.[^\.]+/, "")}.html"
      template = File.join("static", File.basename(page))

      File.open(File.join(Rails.root, "public", page_name), "w") do |f|
        f.write(ActionView::Base.new(view_path).render(:template => template, :layout => "layouts/static"))
      end
    end
  end
end