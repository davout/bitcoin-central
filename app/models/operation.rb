class Operation < ActiveRecord::Base
  has_many :account_operations

  validate :check_debit_credit_equality

  def check_debit_credit_equality
    # Debit and credit amounts should be equal for *each* currency
    account_operations.map(&:currency).uniq.each do |currency|
      unless account_operations.select{ |ao| ao.currency = currency }.map(&:amount).sum.zero?
        errors[:base] << I18n.t("errors.debit_not_equal_to_credit", :currency => currency)
      end
    end
  end
end
