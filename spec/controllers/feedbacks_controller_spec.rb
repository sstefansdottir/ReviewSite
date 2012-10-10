require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe FeedbacksController do
  before(:each) do
    @review = FactoryGirl.create(:review)
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  # This should return the minimal set of attributes required to create a valid
  # Feedback. As you add validations to Feedback, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { review_id: @review.id,
      user_id: @user.id}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # FeedbacksController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all feedbacks as @feedbacks" do
      feedback = Feedback.create! valid_attributes
      get :index, {:review_id => @review.id}, valid_session
      assigns(:feedbacks).should eq([feedback])
    end
    describe "as another user" do
      before(:each) do
        FactoryGirl.create(:feedback, :review => @review, :user => @user)
        @new_user = FactoryGirl.create(:user)
        sign_in(@new_user)
        @new_feedback = FactoryGirl.create(:feedback, :review => @review, :user => @new_user)
      end
      it "doesn't show feedback from the first user" do
        get :index, {:review_id => @review.id}, valid_session
        assigns(:feedbacks).should eq([@new_feedback])
      end
    end
    describe "as admin user" do
      before(:each) do
        @feedback = Feedback.create! valid_attributes
        sign_in(FactoryGirl.create(:admin_user))
      end
      it "Can see feedback from other users" do
        get :index, {:review_id => @review.id}, valid_session
        assigns(:feedbacks).should eq([@feedback])
      end
    end
  end

  describe "GET show" do
    it "assigns the requested feedback as @feedback" do
      feedback = Feedback.create! valid_attributes
      get :show, {:id => feedback.to_param, :review_id => @review.id}, valid_session
      assigns(:feedback).should eq(feedback)
    end
    it "CAN show feedback that has been 'submitted'" do
      feedback = FactoryGirl.create(:feedback, :submitted => true, :review => @review, :user => @user)
      get :show, {:id => feedback.to_param, :review_id => @review.id}, valid_session
      assigns(:feedback).should eq(feedback)
      response.should be_success
    end

    describe "with feedback from the user" do
      before(:each) do
        @feedback = Feedback.create! valid_attributes
      end

      it "disallows seeing feedback submitted by other people" do
        @other_user = FactoryGirl.create(:user)
        sign_in(@other_user)

        get :show, {:id => @feedback.to_param, :review_id => @review.id}, valid_session

        response.should redirect_to(root_url)
      end
    end
  end


  describe "GET new" do
    it "assigns a new feedback as @feedback" do
      get :new, {:review_id => @review.id}, valid_session
      assigns(:feedback).should be_a_new(Feedback)
      assigns(:user_name).should eq(@user.name)
    end
    it "loads the existing feedback if one exists for this user" do
      feedback = FactoryGirl.create(:feedback, :review => @review, :user => @user)
      get :new, {:review_id => @review.id}, valid_session
      assigns(:feedback).should eq(feedback)
      assigns(:user_name).should eq(@user.name)
    end
  end

  describe "GET edit" do
    it "assigns the requested feedback as @feedback" do
      feedback = Feedback.create! valid_attributes
      get :edit, {:id => feedback.to_param, :review_id => @review.id}, valid_session
      assigns(:feedback).should eq(feedback)
      assigns(:user_name).should eq(@user.name)
    end
    it "cannot edit feedback that has been 'submitted'" do
      feedback = FactoryGirl.create(:feedback, :submitted => true, :review => @review, :user => @user)
      get :edit, {:id => feedback.to_param, :review_id => @review.id}, valid_session
      response.should redirect_to(root_url)
    end
    describe "for another user" do
      before(:each) do
        @feedback = Feedback.create! valid_attributes
        @other_user = FactoryGirl.create(:user)
        sign_in(@other_user)
        @other_feedback = FactoryGirl.create(:feedback, :review => @review, :user => @other_user)
      end
      it "cannot edit another user's feedback" do
        get :edit, {:id => @feedback.to_param, :review_id => @review.id}, valid_session
        response.should redirect_to(root_url)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Feedback" do
        expect {
          post :create, {:feedback => {}, :review_id => @review.id}, valid_session
        }.to change(Feedback, :count).by(1)
      end

      it "assigns a newly created feedback as @feedback" do
        post :create, {:feedback => {}, :review_id => @review.id}, valid_session
        assigns(:feedback).should be_a(Feedback)
        assigns(:feedback).should be_persisted
        assigns(:feedback).user.should eq(@user)
        assigns(:feedback).review.should eq(@review)
      end
      it "sets the submitted to false by default" do
        post :create, {:feedback => {}, :review_id => @review.id}, valid_session
        assigns(:feedback).submitted.should == false
      end
      it "sets the submitted to true if clicked on the 'Submit Final' button" do
        post :create, {:feedback => {}, :review_id => @review.id, :submit_final_button => 'Submit Final'}, valid_session
        assigns(:feedback).submitted.should == true
      end

      it "redirects to the created feedback" do
        post :create, {:feedback => {}, :review_id => @review.id}, valid_session
        response.should redirect_to([@review, Feedback.last])
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved feedback as @feedback" do
        # Trigger the behavior that occurs when invalid params are submitted
        Feedback.any_instance.stub(:save).and_return(false)
        post :create, {:feedback => {}, :review_id => @review.id}, valid_session
        assigns(:feedback).should be_a_new(Feedback)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Feedback.any_instance.stub(:save).and_return(false)
        post :create, {:feedback => {}, :review_id => @review.id}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested feedback" do
        feedback = Feedback.create! valid_attributes
        # Assuming there are no other feedbacks in the database, this
        # specifies that the Feedback created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Feedback.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => feedback.to_param, :feedback => {'these' => 'params'}, :review_id => @review.id}, valid_session
      end

      it "assigns the requested feedback as @feedback" do
        feedback = Feedback.create! valid_attributes
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id}, valid_session
        assigns(:feedback).should eq(feedback)
      end

      it "redirects to the feedback" do
        feedback = Feedback.create! valid_attributes
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id}, valid_session
        response.should redirect_to([@review, feedback])
      end

      it "sets the submitted to false by default" do
        feedback = Feedback.create! valid_attributes
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id}, valid_session
        assigns(:feedback).submitted.should == false
      end
      it "sets the submitted to true if clicked on the 'Submit Final' button" do
        feedback = Feedback.create! valid_attributes
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id, :submit_final_button => 'Submit Final'}, valid_session
        assigns(:feedback).submitted.should == true
      end
      it "cannot update feedback that has been 'submitted'" do
        feedback = FactoryGirl.create(:feedback, :submitted => true, :review => @review, :user => @user)
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id}, valid_session
        response.should redirect_to(root_url)
      end
    end

    describe "with invalid params" do
      it "assigns the feedback as @feedback" do
        feedback = Feedback.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Feedback.any_instance.stub(:save).and_return(false)
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id}, valid_session
        assigns(:feedback).should eq(feedback)
      end

      it "re-renders the 'edit' template" do
        feedback = Feedback.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Feedback.any_instance.stub(:save).and_return(false)
        put :update, {:id => feedback.to_param, :feedback => {}, :review_id => @review.id}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested feedback" do
      feedback = Feedback.create! valid_attributes
      expect {
        delete :destroy, {:id => feedback.to_param, :review_id => @review.id}, valid_session
      }.to change(Feedback, :count).by(-1)
    end

    it "redirects to the feedbacks list" do
      feedback = Feedback.create! valid_attributes
      delete :destroy, {:id => feedback.to_param, :review_id => @review.id}, valid_session
      response.should redirect_to(review_feedbacks_url(@review))
    end
  end

end