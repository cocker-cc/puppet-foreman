require 'spec_helper'

describe 'foreman::to_symbolized_yaml' do
  it 'should exist' do
    is_expected.not_to eq(nil)
  end

  it 'should handle Hash and symbolize keys' do
    is_expected.to run.with_params({'a' => 'b'}).and_return("---\n:a: b\n")
  end
  it 'should handle Hash and symbolize keys only at first-level' do
    is_expected.to run.with_params({'a' => 'A', 'b' => {'c' => 'C'}}).and_return("---\n:a: A\n:b:\n  c: C\n")
  end
  it 'should handle Array' do
    is_expected.to run.with_params(['a', 'b']).and_return("---\n- a\n- b\n")
  end

  it 'should handle Hash and should unwrap Sensitive' do
    is_expected.to run.with_params({'a' => sensitive('b')}, {}, false).and_return("---\n:a: b\n")
  end
  it 'should handle Array and should unwrap Sensitive' do
    is_expected.to run.with_params(['a', sensitive('b')], {}, false).and_return("---\n- a\n- b\n")
  end

  # Test of a Returnvalue of Datatype Sensitive does not work
  it 'should handle Hash, should unwrap Sensitive and return Sensitive' do
    pending 'should have a Returnvalue of Datatype Sensitive'
    is_expected.to run.with_params({'a' => sensitive('b')}).and_return(sensitive("---\n:a: b\n"))
  end
end
