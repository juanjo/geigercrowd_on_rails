require_relative '../test_helper'

class SampleTest < ActiveSupport::TestCase
  context "sample" do
    setup do
      @sample = Factory :sample
      @instrument = @sample.instrument
      @other_location = Factory :other_location
      @user = @sample.user
    end

    context "relationships" do
      should "belong to instrument" do
        instrument = @sample.instrument
        assert_equal [ @sample ], instrument.samples
      end

      should "have a user" do
        timestamp = DateTime.now
        sample = @instrument.samples.create value: 1.2345, timestamp: timestamp
        assert sample.valid?
        assert @instrument.user.samples.include? sample
        assert_equal @instrument.user, sample.user
      end

      should "have a data type" do
        assert_equal @instrument.data_type, @sample.data_type
      end
    end

    should "take its instrument's location if not specified" do
      new_sample = @instrument.samples.create value: 12.34, timestamp: DateTime.now
      assert_valid new_sample
      assert_equal @instrument.location, @instrument.samples.last.location
    end
    
    should "not be valid given no location and belonging to an instrument without location" do
      @instrument.location = nil
      @instrument.save
      new_sample = @instrument.samples.new value: 12.34, timestamp: DateTime.now
      assert_equal false, new_sample.save
    end
    
    should "not accept a location when belonging to an instrument with location" do
      new_sample = @instrument.samples.new value: 12.34, timestamp: DateTime.now, location: @other_location
      assert_equal false, new_sample.save
    end

    context "restrictions" do
      setup do
        @other_user = Factory :user
      end

      should "not allow to save_as other user" do
        @sample.value += 1
        @sample.save_as @other_user
        assert !@sample.valid?
        assert_equal({ :base => [ "Permission denied" ]}, @sample.errors)
      end

      should "allow to save_as owner" do
        @sample.value += 1
        @sample.save_as @user
        assert @sample.valid?
      end
    end

    context "scopes" do
      should "find samples after some point in time" do
        sample = Factory :sample, timestamp: 1.week.ago
        assert Sample.after((1.week + 1.day).ago).find(sample.id)
        assert_raise ActiveRecord::RecordNotFound do
          assert Sample.after((1.week - 1.day).ago).find(sample.id)
        end
      end

      should "find samples before some point in time" do
        sample = Factory :sample, timestamp: 1.week.ago
        assert Sample.before((1.week - 1.day).ago).find(sample.id)
        assert_raise ActiveRecord::RecordNotFound do
          assert Sample.before((1.week + 1.day).ago).find(sample.id)
        end
      end
    end
  end
end
