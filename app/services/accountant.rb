# This service will provide adjustment in deposits and transaction table
# Don't make this class handle other task
class Accountant

  #                                                              Included/Required
  # ==============================================================================


  #                                                                     Initialize
  # ==============================================================================
  # def initialize args

  #   # Parse args into instance_variable
  #   args.each do |k,v|
  #     instance_variable_set("@#{k}", v) unless v.nil?
  #   end

  # end

  #                                                                  Class Methods
  # ==============================================================================
  class << self

    def build()
      new()
    end

    def current_balance(arg)
      Deposit.where(owner: arg[:owner]).desc(:created_at).try(:first)
    end

    def is_withdrawal_processing?(member)
      Deposit.find_by(owner: member, status: DepositStatus.requested).present?
    end

    # Request withdrawal
    def withdrawal(arg)
      # Check if user have deposit or not
      raise if Deposit.where(owner: arg[:owner]).desc(:created_at).try(:first).try(:balance).to_i <= 0
      current_balance = arg[:owner].current_balance.balance

      amount = arg[:amount].to_i
      if amount > current_balance
        amount = current_balance
      end

      # Check if there is any withdraw request processed exists
      # Dont crate if previous request still processed
      unless WithdrawalDeposit.where(owner: arg[:owner], status: DepositStatus.requested).present?
        code = DepositCode.find_by(cname: "withdrawal")
        deposit = WithdrawalDeposit.create(
          owner: arg[:owner],
          deposit_code: code,
          description: "Withdraw",
          amount: amount,
          withdrawal_bank: arg[:bank_account],
          code: code.code,
          account_entry: code.account_entry,
          status: DepositStatus.requested,
          verified: true,
          meta: arg[:meta]
        )

        return deposit

      else
        raise
      end
    rescue
      return nil
    end

    def raise_winner_prize(winner, arg = {})
      code = DepositCode.prize
      contest = winner.contest
      # TODO: Calculate with tax/fee
      amount = winner.prize
      description = "Winner prize contest #{contest.try(:title)}"
      deposit = WinnerPrizeDeposit.create(
        deposit_code: code,
        owner: winner.designer,
        winner: winner,
        contest: contest,
        description: description,
        amount: amount,
        code: code.code,
        verified: true,
        account_entry: code.account_entry
      )
      return deposit
    rescue
      return nil
    end


    def raise_store_prize(store_purchase, arg = {})
      code = DepositCode.prize
      store_item = store_purchase.item
      amount = store_purchase.prize
      description = "Payment store item #{store_item.try(:number)}"

      deposit = StorePrizeDeposit.create(
        deposit_code: code,
        owner: store_item.owner,
        store_item: store_item,
        store_purchase: store_purchase,
        description: description,
        amount: amount,
        code: code.code,
        verified: true,
        account_entry: code.account_entry
      )
      return deposit
    rescue
      return nil
    end


    def raise_no_winner_prize(winner, arg = {})
      code = DepositCode.no_winner_prize
      contest = winner.contest

      amount = winner.prize
      description = "Contest no winner prize from #{contest.try(:title)}"
      deposit = NoWinnerPrizeDeposit.create(
        deposit_code: code,
        owner: winner.designer,
        winner: winner,
        contest: contest,
        description: description,
        amount: amount,
        code: code.code,
        verified: true,
        account_entry: code.account_entry
      )
      return deposit
    rescue
      return nil
    end


    def raise_affiliate_commission(obj, arg = {})
      # Raise if obj doesn't have affiliate
      claim = obj.affiliate_referred_by
      affiliate = claim.affiliate
      raise if claim.blank?

      code = DepositCode.find_by(cname: "affiliate_commission")
      case obj.class
      when Contest
        # Calculate commission by package
        # Komisi berupa angka
        amount = claim.commission.send "#{obj.package.cname}_commission"
      when StorePurchase
        amount = obj.item.calculate_sell_price * claim.commission.commission.to_f
      end

      description = "Claim affiliate"
      deposit = AffiliateCommissionDeposit.create(
        deposit_code: code,
        owner: affiliate.publisher,
        affiliate_claim: claim,
        description: description,
        amount: amount,
        code: code.code,
        verified: true,
        account_entry: code.account_entry
      )
      return deposit
    rescue
      return nil
    end


    def payment(invoice, arg)
      code = DepositCode.payment
      # TODO: Calculate with tax/fee
      description = "Payment invoice #{invoice.try(:number)} #{arg[:amount]}"
      deposit = PaymentDeposit.create(
        deposit_code: code,
        owner: invoice.owner,
        invoice: invoice,
        description: description,
        amount: arg[:amount],
        code: code.code,
        verified: true,
        account_entry: code.account_entry
      )
      return deposit
    end

    def top_up

    end

    def adjust_transaction(arg)

    end

    # Use method missing because this class working same task (input and adjustment)
    def method_missing(action, *args, &block)
      return nil
    end

  end


  #                                                               Instance Methods
  # ==============================================================================

end
