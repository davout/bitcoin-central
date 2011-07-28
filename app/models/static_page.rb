class StaticPage < ActiveRecord::Base
  attr_accessible :name, :title, :locale, :contents
  
  validates :name,
    :presence => true
  
  validates :title,
    :presence => true
  
  validates :locale,
    :presence => true,
    :inclusion => { :in => nil }
  
  validates :contents,
    :presence => true
  
  def self.get_page(name, locale)
    with_name(name).with_locale(locale).first or with_name(name).with_locale(I18n.default_locale)
  end
  
  
  protected
  
    def self.with_name(name)
      where(:name => name)
    end

    def self.with_locale(locale)
      where("locale = #{locale}")
    end
end
