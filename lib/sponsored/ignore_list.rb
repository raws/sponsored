module Sponsored
  class IgnoreList
    def ignore?(message)
      ignored_users.include? message.user.user.downcase
    end

    private

    def ignored_users
      @ignored_users ||= ENV.fetch('SPONSORED_IGNORED_USERS', '').split(',').map(&:downcase)
    end
  end
end
