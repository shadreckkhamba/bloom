class PartnersController < ApplicationController
  before_action :require_login, except: [:accept, :confirm]

  # GET /partner/invite — show the shareable link (owner only)
  def invite
    @wedding = current_wedding
    return redirect_to dashboard_path, alert: "Only the wedding owner can manage partner invites." unless wedding_owner?

    # Generate a token if one doesn't exist yet
    @wedding.regenerate_partner_invite_token! unless @wedding.partner_invite_token.present?
  end

  # POST /partner/invite/regenerate — issue a fresh token
  def regenerate
    @wedding = current_wedding
    return redirect_to dashboard_path, alert: "Only the wedding owner can manage partner invites." unless wedding_owner?

    @wedding.regenerate_partner_invite_token!
    redirect_to partner_invite_path, notice: "New invite link generated."
  end

  # GET /partner/accept?token=... — landing page for the partner
  def accept
    @token   = params[:token].to_s.strip
    @wedding = Wedding.find_by(partner_invite_token: @token)

    if @wedding.nil?
      return render :invalid_token
    end

    if @wedding.has_partner?
      return render :already_taken
    end

    # If already logged in and already has a wedding, block them
    if logged_in? && current_user.wedding.present? && current_user.wedding != @wedding
      return render :conflict
    end

    # Stash the token in session so it survives through login/signup
    session[:partner_token] = @token
  end

  # POST /partner/accept — confirm joining
  def confirm
    @token   = params[:token].to_s.strip
    @wedding = Wedding.find_by(partner_invite_token: @token)

    if @wedding.nil? || @wedding.has_partner?
      return redirect_to root_path, alert: "This invite link is no longer valid."
    end

    # "Create account" button — redirect to signup with token in URL
    if params[:intent] == "signup"
      session[:partner_token] = @token
      return redirect_to signup_path(partner_token: @token)
    end

    # If not logged in, redirect to signup carrying the token
    unless logged_in?
      session[:partner_token] = @token
      return redirect_to signup_path(partner_token: @token)
    end

    # Can't join your own wedding as partner
    if @wedding.owner?(current_user)
      return redirect_to dashboard_path, alert: "You're already the owner of this wedding."
    end

    # Can't join if already in a different wedding
    if current_user.wedding.present?
      return redirect_to dashboard_path, alert: "You're already linked to a wedding."
    end

    @wedding.update!(partner_id: current_user.id, partner_invite_token: nil)
    session.delete(:partner_token)
    redirect_to dashboard_path, notice: "You've joined #{@wedding.couple_names}'s wedding! 💍"
  end

  # DELETE /partner — owner removes partner link
  def destroy
    @wedding = current_wedding
    return redirect_to dashboard_path, alert: "Only the wedding owner can manage partner invites." unless wedding_owner?

    @wedding.update!(partner_id: nil, partner_invite_token: nil)
    redirect_to dashboard_path, notice: "Partner unlinked from this wedding."
  end
end
