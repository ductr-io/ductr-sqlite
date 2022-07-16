# frozen_string_literal: true

RSpec.describe Rocket::SQLite::BasicSource do
  let(:source) { described_class.new("dummy_context", :dummy_method) }

  describe "control registration" do
    let(:registered) { Rocket::SQLite::Adapter.source_registry.find_by_type(:basic) }

    it "registers as :basic" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#each" do
    let(:yielder) { proc {} }
    let(:adapter_double) { instance_double(Rocket::SQLite::Adapter) }
    let(:db_double) { instance_double(Sequel::Database) }
    let(:query_double) { instance_double(Array) }

    before do
      allow(source).to receive(:adapter).and_return(adapter_double)
      allow(adapter_double).to receive(:open).and_yield(db_double)
      allow(source).to receive(:call_method).and_return(query_double)
      allow(query_double).to receive(:each)

      source.each(&yielder)
    end

    it "opens the database" do
      expect(adapter_double).to have_received(:open)
    end

    it "calls the method with db" do
      expect(source).to have_received(:call_method).with(db_double)
    end

    it "iterates on the query with the yielder" do # rubocop:disable RSpec/MultipleExpectations
      expect(query_double).to have_received(:each) do |&block|
        expect(block).to be(yielder)
      end
    end
  end
end
