module SerializableTransactions
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        alias_method_chain :transaction, :isolation
      end
    end
  end

  module ClassMethods
    # TODO : Passing args to the transaction_without_isolation breaks test :/
    def transaction_with_isolation(*args, &block)
      transaction_without_isolation do
        ActiveRecord::Base.
          connection.
          execute "SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE"

        block.call
      end
    end
  end
end

ActiveRecord::Base.send :include, SerializableTransactions
