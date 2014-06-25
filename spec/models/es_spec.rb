require 'spec_helper'

describe Es do
  skip "add some examples to (or delete) #{__FILE__}"

  it 'should defined default INDEX' do
    index = 'tw_testing'
    expect(Es::INDEX).to eq index
  end

  it 'should incorrect when INDEX name not same as default variable' do
    index = 'tw_testings'
    expect(index).not_to eq Es::INDEX
  end

  it 'should defined default TYPE' do
    type = 'tasklist'
    expect(Es::TASKLIST).to eq type
  end

  it 'should incorrect when INDEX name not same as default variable' do
    type = 'tasklists'
    expect(type).not_to eq Es::TASKLIST
  end
end
