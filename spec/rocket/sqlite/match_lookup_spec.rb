# frozen_string_literal: true

RSpec.describe Rocket::SQLite::MatchLookup do
  let(:options) { %i[one two] }
  let(:lookup) { described_class.new("dummy_context", :dummy_method, merge: options) }
  let(:adapter_double) { instance_double(Rocket::SQLite::Adapter) }

  describe "control registration" do
    let(:registered) { Rocket::SQLite::Adapter.lookup_registry.find_by_type(:match) }

    it "registers as :match" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#from_key" do
    it "returns the first entry of the :merge option" do
      expect(lookup.from_key).to eq(options.first)
    end
  end

  describe "#to_key" do
    it "returns the last entry of the :merge option" do
      expect(lookup.to_key).to eq(options.last)
    end
  end

  describe "#on_flush" do
    let(:adapter_double) { instance_double(Rocket::SQLite::Adapter) }
    let(:db_double) { instance_double(Sequel::Database) }
    let(:buffer) { [{ one: 1 }] }

    before do
      allow(adapter_double).to receive(:open!).and_return(db_double)
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(lookup).to receive(:adapter).and_return(adapter_double)
      allow(lookup).to receive(:call_method).and_return([])

      lookup.instance_variable_set(:@buffer, buffer)
    end

    context "when the database is opened" do
      it "doesn't open the database" do
        lookup.on_flush
        expect(adapter_double).not_to have_received(:open!)
      end
    end

    context "when the database is closed" do
      let(:db_double) { nil }

      it "opens the database" do
        lookup.on_flush
        expect(adapter_double).to have_received(:open!)
      end
    end

    context "when there is no matching row in the buffer" do
      before do
        allow(lookup).to receive(:call_method).and_return([:dummy])
        allow(lookup).to receive(:buffer_find).and_return(nil)
      end

      it "yields the row untouched" do
        expect { |b| lookup.on_flush(&b) }.to yield_with_args(:dummy)
      end
    end

    context "when there is a matching row in the buffer" do
      before do
        allow(lookup).to receive(:call_method).and_return([{ one: 1 }])
        allow(lookup).to receive(:buffer_find).and_return({ two: 2 })
      end

      it "yields the row untouched" do
        expect { |b| lookup.on_flush(&b) }.to yield_with_args({ one: 1, two: 2 })
      end
    end
  end

  describe "#buffer_find" do
    let(:buffer) { [{ one: 1 }] }
    let(:row) { { two: 1 } }

    before do
      lookup.instance_variable_set(:@buffer, buffer)
    end

    it "finds the matching row in the buffer" do
      expect(lookup.send(:buffer_find, row)).to eq(buffer.first)
    end

    context "when there are multiple matching rows in the buffer" do
      let(:buffer) { [{ one: 1, first: true }, { one: 1, first: false }] }

      it "returns the first occurence" do
        expect(lookup.send(:buffer_find, row)).to eq(buffer.first)
      end
    end

    context "when there is no matching row in the buffer" do
      let(:buffer) { [{ one: 2 }] }

      it "returns nil" do
        expect(lookup.send(:buffer_find, row)).to be_nil
      end
    end
  end

  describe "#buffer_keys" do
    let(:buffer) { [{ one: 1, two: 2 }, { one: 2, two: 1 }] }

    before do
      lookup.instance_variable_set(:@buffer, buffer)
    end

    it "returns all merging keys of the buffer" do
      expect(lookup.send(:buffer_keys)).to eq([1, 2])
    end
  end
end
