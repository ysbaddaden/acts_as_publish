require 'test/unit'
require 'rubygems'
gem 'activerecord', '>= 3.0.0.beta1'
require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Post < ActiveRecord::Base
  acts_as_publish
end

class PublishTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Schema.define(:version => 1) do
      create_table :posts do |t|
        t.boolean  :published, :default => true
        t.datetime :published_at
      end
    end
    
    Post.create! :published_at => Time.now - 1.day
    Post.create! :published => true,  :published_at => Time.now - 2.days
    Post.create! :published => false, :published_at => Time.now - 1.month
    Post.create! :published => false, :published_at => Time.now - 2.months
    Post.create! :published => true,  :published_at => Time.now + 1.month
    Post.create! :published => true,  :published_at => Time.now + 2.months
    Post.create! :published => false, :published_at => Time.now + 1.month
    Post.create! :published => false, :published_at => Time.now + 2.months
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  test "published" do
    assert_equal 2, Post.published.count
    assert_equal [1, 2], Post.published.order(:id).map(&:id)
  end

  test "unpublished" do
    assert_equal 6, Post.unpublished.count
    assert_equal [3, 4, 5, 6, 7, 8], Post.unpublished.order(:id).map(&:id)
  end

  test "published?" do
    assert Post.find(1).published?
    assert Post.find(2).published?
    assert !Post.find(3).published?
    assert !Post.find(4).published?
    assert !Post.find(5).published?
    assert !Post.find(6).published?
    assert !Post.find(7).published?
    assert !Post.find(8).published?
  end

  test "(un)publish" do
    Post.unpublish(1)
    assert !Post.find(3).published?
    
    Post.find(3).publish
    assert Post.find(3).published?
    
    Post.publish(3)
    assert Post.find(3).published?
    
    Post.find(5).unpublish
    assert !Post.find(5).published?
  end

  test "defaults" do
    post = Post.create!
    assert post.published == true
    assert_not_nil post.published_at
    post.delete
  end
end

