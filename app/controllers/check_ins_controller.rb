# /check_ins/{new, create}
class CheckInsController < ApplicationController
  def new
    @check_in = CheckIn.new
  end

  def create
    @check_in = CheckIn.new(check_in_params)
    if @check_in.save
      flash[:notice] = "check in created!"
      redirect_to root_path
    else
      render :new
    end
  end

  private def check_in_params
    check_in_params =
      params.require(:check_in).permit(permitted_check_in_params)
    check_in_params[:account] = current_account
    remove_empty_log_entries(check_in_params)
    merge_worked_at_and_account_into_log_entries(check_in_params)
    check_in_params
  end

  private def merge_worked_at_and_account_into_log_entries(check_in_params)
    worked_at = check_in_params.delete(:worked_at)
    check_in_params[:log_entries_attributes].each do |_id, log_entry|
      log_entry[:worked_at] = worked_at
      log_entry[:account] = current_account
    end
  end

  private def remove_empty_log_entries(check_in_params)
    check_in_params[:log_entries_attributes].each do |id, log_entry|
      if log_entry[:quality].blank? || log_entry[:amount].blank?
        check_in_params[:log_entries_attributes].delete(id)
        next
      end
    end
  end

  private def permitted_check_in_params
    [:worked_at, log_entries_attributes: [:amount,
                                          :quality,
                                          :notes,
                                          :activity_id]]
  end
end