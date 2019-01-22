JobVacancy::App.controllers :job_offers do
  before :create, :mylist, :edit do
    if !signed_in?
      redirect('/login')
    end
  end

  get :jobs, :map => '/jobs' do
    render 'jobs'
  end

  get :new, :map => '/jobs/new' do
    @job_offer = JobOffer.new
    render 'new'
  end

  get :mylist, :map => '/jobs/mylist' do
    @job_offers = JobOffer.where("user_id = ?", current_user.id)

    render 'mylist', :locals => { job_offers: @job_offers }
  end

  get :edit, :map => '/jobs/myjobs/:id/edit' do
    job = JobOffer.find_by_id(params[:id])

    if job && job.user.id != current_user.id
      redirect url(:job_offers, :mylist)
    end

    render 'edit', :locals => { job_offer: job }
  end

  post :create, :map => '/jobs/create' do
    @job_offer = JobOffer.new(params[:job_offer])

    if @job_offer && @job_offer.valid?
      @job_offer.write_attribute(:user_id, current_user.id)
      @job_offer.save
      redirect url(:job_offers, :mylist), flash[:notice] = "Job is saved"
    end

    render 'new'
  end

  put :update, :map => '/jobs/myjobs/:id' do
    @job_offer = JobOffer.find_by_id(params[:id])

    if @job_offer == nil
      redirect url(:job_offers, :mylist)
    end

    begin
      if @job_offer.update_attributes!(params[:job_offer])
        redirect url(:job_offers, :mylist), flash[:notice] = 'Job offer was updated.'
      end
    rescue ActiveRecord::RecordInvalid
      redirect url(:job_offers, :edit, id: params[:id]), flash[:error] = 'Job offer changes were not valid'
    end

    redirect url(:job_offers, :edit, id: params[:id]), flash[:error] = 'Job offer was not updated.'
  end
end