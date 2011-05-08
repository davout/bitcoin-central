module ActionMailerDefaults
  def mail_with_logo(args, &block)
    attachments.inline['bitcoin.png'] = File.read(File.join(Rails.root, "public", "images", "bitcoin.png"))
    mail_without_logo(args, &block)
  end

  def self.included(base)
    base.class_eval do
      default :from => "Bitcoin Central support <support@bitcoin-central.net>"
      layout 'mailers'
      alias_method_chain :mail, :logo
    end
  end
end

ActionMailer::Base.send :include, ActionMailerDefaults
