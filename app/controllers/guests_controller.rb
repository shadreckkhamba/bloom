require "csv"

class GuestsController < ApplicationController
  before_action :require_login
  before_action :require_wedding

  def index
    @wedding = current_user.wedding
    @guests  = @wedding.guests.includes(:rsvp).order(:name)
    @guest   = Guest.new
  end

  def create
    @wedding = current_user.wedding
    @guest   = @wedding.guests.build(guest_params)

    respond_to do |format|
      if @guest.save
        format.turbo_stream
        format.html { redirect_to guests_path, notice: "#{@guest.name} added." }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("guest-form-errors",
            partial: "guests/form_errors", locals: { guest: @guest })
        }
        format.html { redirect_to guests_path, alert: @guest.errors.full_messages.to_sentence }
      end
    end
  end

  def import
    @wedding = current_user.wedding
    file = params[:file]

    unless file&.content_type&.include?("csv") || file&.original_filename&.end_with?(".csv")
      return redirect_to guests_path, alert: "Please upload a valid CSV file."
    end

    count = 0
    CSV.foreach(file.path, headers: true) do |row|
      name  = row["Name"]&.strip
      phone = row["Phone"]&.strip
      next if name.blank? || phone.blank?
      next if @wedding.guests.exists?(phone: phone)

      @wedding.guests.create!(name: name, phone: phone)
      count += 1
    end

    redirect_to guests_path, notice: "#{count} guest#{"s" if count != 1} imported successfully 🌸"
  rescue CSV::MalformedCSVError
    redirect_to guests_path, alert: "CSV file appears to be malformed."
  end

  def send_invitations
    @wedding = current_user.wedding
    guests   = @wedding.guests.where(invitation_sent_at: nil)

    guests.each do |guest|
      # WhatsApp integration placeholder — replace with Twilio / Meta API
      message = whatsapp_message(guest, @wedding)
      Rails.logger.info "[WhatsApp] To: #{guest.phone} | #{message}"
      guest.update!(invitation_sent_at: Time.current)
    end

    redirect_to guests_path, notice: "Invitations sent to #{guests.count} guest#{"s" if guests.count != 1} 💍"
  end

  def destroy
    guest = current_user.wedding.guests.find(params[:id])
    guest.destroy
    redirect_to guests_path, notice: "Guest removed."
  end

  def mark_sent
    guest = current_user.wedding.guests.find(params[:id])
    guest.update!(invitation_sent_at: Time.current)
    redirect_to guests_path, notice: "#{guest.name} marked as sent."
  end

  private

  def guest_params
    params.require(:guest).permit(:name, :phone)
  end

  def whatsapp_message(guest, wedding)
    <<~MSG.strip
      Hello #{guest.name} 💍
      #{wedding.bride_name} and #{wedding.groom_name} would be honored by your presence at their wedding.
      Please confirm your attendance below:
      #{guest.invitation_url}
      With love, Bloom by Florence 🌸
    MSG
  end
end
