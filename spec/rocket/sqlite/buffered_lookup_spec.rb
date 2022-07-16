# frozen_string_literal: true

RSpec.describe Rocket::SQLite::BufferedLookup do
  let(:lookup) { described_class.new("dummy_context", :dummy_method) }
  let(:adapter_double) { instance_double(Rocket::SQLite::Adapter) }

  describe "control registration" do
    let(:registered) { Rocket::SQLite::Adapter.lookup_registry.find_by_type(:buffered) }

    it "registers as :buffered" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#on_flush" do
    let(:db_double) { instance_double(Sequel::Database) }
    let(:dummy_buffer) { [:row] }
    let(:yielder) { proc {} }

    before do
      allow(adapter_double).to receive(:open!).and_return(db_double)
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(lookup).to receive(:adapter).and_return(adapter_double)
      allow(lookup).to receive(:call_method)

      lookup.instance_variable_set(:@buffer, dummy_buffer)

      lookup.on_flush(&yielder)
    end

    context "when the database is opened" do
      it "doesn't open the database" do
        expect(adapter_double).not_to have_received(:open!)
      end
    end

    context "when the database is closed" do
      let(:db_double) { nil }

      it "opens the database" do
        expect(adapter_double).to have_received(:open!)
      end
    end

    it "calls the method with db, buffer and the yielder block" do # rubocop:disable RSpec/MultipleExpectations
      expect(lookup).to have_received(:call_method).with(db_double, dummy_buffer) do |&block|
        expect(block).to be(yielder)
      end
    end
  end
end
