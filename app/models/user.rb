class User < ActiveRecord::Base
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
          # :token_authenticatable

  has_many :task_lists, foreign_key: :owner_id

  before_save :ensure_authentication_token

  after_create :create_task_list

  def clear_authentication_token!
    update_attribute(:authentication_token, nil)
  end

  def create_task_list
    task_lists.create!(name: "My first list")
  end

  def first_list
    task_lists.first
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def reset_authentication_token!
    self.update_attribute(:authentication_token, generate_authentication_token)
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
