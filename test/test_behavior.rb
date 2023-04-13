# frozen_string_literal: true

require_relative 'helper'

class TestBehavior < Minitest::Test
  def test_generate_should_return_an_object_corresponding_to_the_given_type
    assert_instance_of Behaviors::FakeBehavior, Behavior.generate(:fake_behavior, nil)
  end

  def test_generate_should_raise_on_invalid_type
    assert_raises NoSuchBehaviorError do
      Behavior.generate(:foo, nil)
    end
  end

  def test_complain
    SysLogger.expects(:log).with(:error, 'foo')
    refute Behavior.allocate.bypass.complain('foo')
  end
end
