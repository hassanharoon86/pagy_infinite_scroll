# frozen_string_literal: true

RSpec.describe PagyInfiniteScroll do
  it "has a version number" do
    expect(PagyInfiniteScroll::VERSION).not_to be nil
  end

  it "has a configuration" do
    expect(PagyInfiniteScroll.config).to be_a(PagyInfiniteScroll::Configuration)
  end
end
