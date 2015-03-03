# == Schema Information
#
# Table name: product_apps
#
#  id         :integer          not null, primary key
#  role       :integer          not null
#  product_id :integer          not null
#  user_id    :integer
#  color_id   :integer
#  category   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl
require 'core_ext/string'

ROLES_HASH ||= {
          face: ProductApp::FACE_ROLES.map { |e| e.snakecase.to_sym},
          eyes: ProductApp::EYE_ROLES.map { |e| e.snakecase.to_sym},
          lips: ProductApp::LIP_ROLES.map { |e| e.snakecase.to_sym},
          cheek: ProductApp::CHEEK_ROLES.map { |e| e.snakecase.to_sym}
        }

SIZE ||= {
          face: ProductApp::FACE_ROLES.size - 1,
          eyes: ProductApp::EYE_ROLES.size - 1,
          lips: ProductApp::LIP_ROLES.size - 1,
          cheek: ProductApp::CHEEK_ROLES.size - 1
        }



FactoryGirl.define do
  factory :product_app do
    category [:face, :eyes, :lips, :cheeks][Random.rand(3)]
    # association product, factory: :product
    role  {ROLES_HASH[category][Random.rand(SIZE[category])]}
    user_id 3
    color_id 1
    subrole nil
    product
    
    # trait :random_role do
    #   role 1
    #   # role  {ROLES[category][Random.rand(SIZE[category])]}
    # end
    
    # trait :face_role do
    #   role :face
    # end
    #
    # trait :eye_role do
    #   role :eyes
    # end
    #
    # trait :lips_role do
    #   role :lips
    # end
    #
    # trait :cheeks_role do
    #   role :cheeks
    # end
  end
end
