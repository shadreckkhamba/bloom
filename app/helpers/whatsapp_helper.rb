module WhatsappHelper
  # Generates a WhatsApp Click-to-Chat URL with a pre-filled invitation message.
  # Florence clicks this — WhatsApp opens with the message ready to send.
  def whatsapp_invite_url(guest, wedding)
    phone = normalise_whatsapp_phone(guest.phone)
    message = <<~MSG
      Hello #{guest.name} 💍

      #{wedding.bride_name} and #{wedding.groom_name} would be honored by your presence at their wedding.

      📅 #{wedding.wedding_date.strftime("%A, %d %B %Y")}

      Please confirm your attendance here:
      #{invitation_url(guest.token, host: request.host_with_port, protocol: request.protocol)}

      With love, Bloom by Florence 🌸
    MSG

    "https://wa.me/#{phone}?text=#{ERB::Util.url_encode(message.strip)}"
  end

  private

  # Converts local format (0999...) to international (265999...)
  def normalise_whatsapp_phone(phone)
    phone.to_s.gsub(/[\s\-+]/, "").sub(/^0/, "265")
  end
end
