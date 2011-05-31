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
        assert @instrument.origin.samples.include? sample
        assert_equal @instrument.origin, sample.user
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
    
    context "scopes" do
      should "return samples after some point in time" do
        sample = Factory :sample, timestamp: 1.week.ago
        assert Sample.after((1.week + 1.day).ago).find(sample.id)
        assert_raise ActiveRecord::RecordNotFound do
          assert Sample.after((1.week - 1.day).ago).find(sample.id)
        end
      end

      should "return samples before some point in time" do
        sample = Factory :sample, timestamp: 1.week.ago
        assert Sample.before((1.week - 1.day).ago).find(sample.id)
        assert_raise ActiveRecord::RecordNotFound do
          assert Sample.before((1.week + 1.day).ago).find(sample.id)
        end
      end
    end
  end

  context "Samples with location" do
    setup do
      @sample_ny = Factory :sample, location_attributes:
        { latitude: 40.7143528, longitude: -74.0059731 }
      @sample_sf = Factory :sample, location_attributes:
        { latitude: 37.7749295, longitude: -122.4194155 }
      @origin = "Berlin, Germany"
    end

    should "be sortable by distance" do
      assert_equal [ @sample_ny, @sample_sf ],
        Sample.geo_scope(origin: @origin).order("distance asc")
      assert_equal [ @sample_sf, @sample_ny ],
        Sample.geo_scope(origin: @origin).order("distance desc")
    end
  end
end
