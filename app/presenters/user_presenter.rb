# frozen_string_literal: true

require 'delegate'
# Presenter for user
class UserPresenter < SimpleDelegator
  def reviews_votes
    @reviews_votes ||= "Reviews #{model.reviews.count} Votes #{model.votes.count}"
  end

  def following_count
    @followings_count ||= model.following.count
  end

  def followers_count
    @followers_count ||= model.followers.count
  end

  def action(current_user)
    return 'profile' if model == current_user
    @action ||= current_user.followings?(model) ? 'unfollow' : 'follow'
  end

  private

  def model
    __getobj__
  end
end