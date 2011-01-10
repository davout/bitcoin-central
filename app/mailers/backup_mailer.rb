class BackupMailer < ActionMailer::Base
  default :from => "Bitcoin Central support <support@bitcoin-central.net>"

  def wallet_backup(recipient, wallet)
    attachments["wallet_#{DateTime.now.strftime("%Y_%m_%d_%H_%M.dat.gpg")}"] = File.read(wallet)

    attachments.inline['bitcoin.png'] = File.read(File.join(Rails.root, "public", "images", "bitcoin.png"))

    mail :to => recipient,
      :subject => "Wallet backup #{DateTime.now.strftime("%d/%m/%Y %H:%M")}"
  end
end
