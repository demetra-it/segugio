# frozen_string_literal: true

FactoryBot.define do
  sequence(:post_status) { %w[draft preview published hidden deleted].sample }
  sequence(:post_titles) { |n| "Post #{n}" }

  factory :post, class: Post do
    title { generate(:post_titles) }
    body { Faker::ChuckNorris.fact }
    status { generate(:post_status) }
  end
end
