JobVacancy::App.controllers :password_forget do
  get :new, :map => '/password_forget' do
    render 'new'
  end

  post :create do
    @user = User.find_by_email(params[:email])

    if@user
      @user.save_forget_password_token

      link = 'http://localhost:3000' + url(:password_forget, :edit, token: @user.password_reset_token)
      user_password_reset_mail = UserPasswordResetMail.new(@user)
      user_password_reset_mail.reset_mail(link)
    end

    render 'success'
  end

  get :edit, :map => '/password_forget/:token/edit' do
    @user = User.find_by_password_reset_token(params[:token])

    if @user && Time.now.utc < (@user.password_reset_sent_date.to_datetime + (1.0 / 24.0))
      render 'edit'
    elsif @user && Time.now.utc >= (@user.password_reset_sent_date.to_datetime + (1.0 / 24.0))
      @user.update_attributes(password_reset_token: 0, password_reset_sent_date: 0)
      redirect url(:sessions, :new), flash[:error] = 'Password reset token has expired.'
    else
      redirect url(:password_forget, :new)
    end
  end

  post :update, :map => "/password_forget/:token" do
    @user = User.find_by_password_reset_token(params[:token])

    if @user.update_attributes(params[:user])
      @user.update_attributes(password_reset_token: 0, password_reset_sent_date: 0)
      redirect url(:sessions, :new), flash[:notice] = 'Password has been reseted. Please login with your new password.'
    else
      render 'edit'
    end
  end
end

