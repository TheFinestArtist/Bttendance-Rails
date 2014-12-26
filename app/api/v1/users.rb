module V1
  class Users < Grape::API
    include Grape::Kaminari

    resource :users do
      helpers do
        def unsecured_emails
          ['apple0@apple.com', 'apple1@apple.com', 'apple2@apple.com',
            'apple3@apple.com', 'apple4@apple.com', 'apple5@apple.com',
            'apple6@apple.com', 'apple7@apple.com', 'apple8@apple.com',
            'apple9@apple.com']
        end
      end

      desc 'Returns a list of users, paginated'
      paginate per_page: 10
      get '', rabl: 'users/users' do
        users = User.all
        @users = paginate(Kaminari.paginate_array(users))
      end


      desc 'Returns a specific user of email'
      get 'search', rabl: 'users/user' do
        @user = User.find_by_email(params.email.downcase)
        @user ? @user : error_with('User', 404)
      end


      desc 'Returns a specific user of id'
      get ':id', rabl: 'users/user' do
        @user = User.find_by_id(params[:id])
        @user ? @user : error_with('User', 404)
      end


      desc 'Registers a user and optionally a device and returns the new user object'
      params do
        requires :user, type: Hash do
          requires :email, type: String, desc: 'Email'
          requires :password, type: String, desc: 'Password'
          requires :name, type: String, desc: 'Name'
          optional :locale, type: String, desc: 'Locale'
          requires :devices_attributes, type: Array do
            requires :platform, type: String, desc: 'Platform'
            optional :uuid, type: String, desc: 'UUID'
            optional :mac_address, type: String, desc: 'MAC Address'
          end
        end
      end
      post '', rabl: 'users/user' do
        @user = User.new(permitted_params[:user])

        if @user.save
          @user
        else
          error_with(@user, 422)
        end
      end


      desc 'Updates a user and returns the updated user object'
      params do
        requires :user, type: Hash do
          optional :password, type: String, desc: 'Password'
          optional :new_password, type: String, desc: 'New Password'
          optional :email, type: String, desc: 'Email'
          optional :name, type: String, desc: 'Name'
          optional :locale, type: String, desc: 'Locale'
          optional :preferences_attributes, type: Hash do
            optional :clicker, type: Boolean, desc: 'Clicker'
            optional :attendance, type: Boolean, desc: 'Attendance'
            optional :notice, type: Boolean, desc: 'Notice'
            optional :curious, type: Boolean, desc: 'Curious'
          end
          optional :devices_attributes, type: Array do
            optional :id, type: Integer, desc: 'ID'
            optional :platform, type: String, desc: 'Platform'
            optional :uuid, type: String, desc: 'UUID'
            optional :mac_address, type: String, desc: 'MAC Address'
            optional :notification_key, type: String, desc: 'Notification Key'
            optional :_destroy, type: Boolean, desc: 'Destroy'
          end
          optional :schools_users_attributes, type: Array do
            optional :school_id, type: Integer, desc: 'School ID'
            optional :identity, type: String, desc: 'Identity'
            optional :state, type: String, desc: 'State'
            optional :_destroy, type: Boolean, desc: 'Destroy'
          end
          optional :courses_users_attributes, type: Array do
            optional :course_id, type: Integer, desc: 'Course ID'
            optional :state, type: String, desc: 'State'
            optional :_destroy, type: Boolean, desc: 'Destroy'
          end
        end
      end
      put ':id', rabl: 'users/user' do
        @user = User.find_by_id(params[:id])
        if @user
          update_params = permitted_params[:user]
          if update_params[:new_password].present?
            if @user.authenticate(update_params[:password])
              update_params[:password] = update_params[:new_password]
              update_params.delete :new_password
              # Send update_password email              
              UserMailer.update_password(@user).deliver
            else
              error_with(401)
            end
          end

          # Update schools and courses join models manually
          # TODO: Abstract (app-level)
          if update_params[:schools_users_attributes].present?
            update_params[:schools_users_attributes].each do |schools_user|
              found_schools_user = @user.schools_users.find_by_school_id(schools_user[:school_id])
              if found_schools_user && schools_user[:_destroy]
                found_schools_user.destroy
              elsif found_schools_user
                found_schools_user.update_attributes(schools_user)
              else !found_schools_user
                @user.schools_users.new(schools_user)
              end
            end
            update_params.delete(:schools_users_attributes)
          end
          if update_params[:courses_users_attributes].present?
            update_params[:courses_users_attributes].each do |courses_user|
              found_courses_user = @user.courses_users.find_by_course_id(courses_user[:course_id])
              if found_courses_user && courses_user[:_destroy]
                found_courses_user.destroy
              elsif found_courses_user
                found_courses_user.update_attributes(courses_user)
              else !found_courses_user
                @user.courses_users.new(courses_user)
              end
            end
            update_params.delete(:courses_users_attributes)
          end

          if @user.update_attributes(update_params)
            @user
          else
            error_with(@user, 422)
          end
        else
          error_with('User', 404)
        end
      end


      desc 'Sends a reset password email to a user'
      params do
        requires :email, type: String, desc: 'Email'
      end
      post 'reset' do
        @user = User.find_by_email(params[:email])
        if @user
          UserMailer.reset(@user).deliver
          status 204
        else
          error_with('User', 404)
        end
      end


      desc 'Authenticates a user and returns the user object'
      params do
        requires :email, type: String, desc: 'Email'
        requires :password, type: String, desc: 'Password'
        requires :devices_attributes, type: Hash do
          requires :platform, type: String, desc: 'Platform'
          optional :uuid, type: String, desc: 'UUID'
          optional :mac_address, type: String, desc: 'MAC Address'
        end
      end
      post 'login', rabl: 'users/user' do
        @user = User.find_by_email(params[:email])
        # Check for Apple.com emails
        if @user && unsecured_emails.include?(params[:email])
          @user
        elsif @user
          if @user.authenticate(params[:password])
            device = Device.find_by(permitted_params[:devices_attributes])
            # Device not yet registered to any user, add it to this user
            if !device
              if @user.devices.create(permitted_params[:devices_attributes])
                @user
              else
                # Fail silently
                # TODO: Handle (logging/retry?)
                @user
              end
            elsif device && device.user_id == @user.id
              # User owns this device already, return user
              @user
            else
              # User doesn't own this device
              error!({ error: {type: 'log', title: 'title', message: 'Device registered to another user'}  }, 400)
            end
          else
            error_with(401)
          end
        else
          error_with('User', 404)
        end
      end


      desc 'Returns a user\'s courses'
      get ':id/courses', rabl: 'courses/courses' do
        @user = User.find_by_id(params[:id])

        if @user
          @courses = @user.courses
        else
          error_with('User', 404)
        end
      end


      desc 'Returns a user\'s preferences'
      get ':id/preferences', rabl: 'preferences/preference' do
        @user = User.find_by_id(params[:id])

        if @user
          @preferences = @user.preferences
        else
          error_with('User', 404)
        end
      end
    end
  end
end
