namespace :notifications do
  desc "Deliver recent trades notification"
  task :trades => :environment do  
    Lockfile.lock(:notify_trades) do
      User.where(:notify_on_trade => true).each do |u|
        purchases = Trade.where(:buyer_id => u.id).where("id > ?", u.last_notified_trade_id).all
        sales = Trade.where(:seller_id => u.id).where("id > ?", u.last_notified_trade_id).all
        
        unless purchases.blank? && sales.blank?         
          UserMailer.trade_notification(u, sales, purchases).deliver
          u.update_attribute(:last_notified_trade_id, [purchases.map(&:id), sales.map(&:id)].flatten.max)
        end
      end
    end
  end
end