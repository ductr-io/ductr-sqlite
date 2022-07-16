# frozen_string_literal: true

RSpec.describe Rocket::SQLite::BasicLookup do
  let(:lookup) { described_class.new("dummy_context", :dummy_method) }
  let(:adapter_double) { instance_double(Rocket::SQLite::Adapter) }

  describe "control registration" do
    let(:registered) { Rocket::SQLite::Adapter.lookup_registry.find_by_type(:basic) }

    it "registers as :basic" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#process" do
    let(:db_double) { instance_double(Sequel::Database) }
    let(:row) { instance_double(Hash) }

    before do
      allow(adapter_double).to receive(:open!).and_return(db_double)
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(lookup).to receive(:adapter).and_return(adapter_double)
      allow(lookup).to receive(:call_method).and_return([])
    end

    context "when the database is opened" do
      before do
        lookup.process(row)
      end

      it "doesn't open the database" do
        expect(adapter_double).not_to have_received(:open!)
      end

      it "calls the job method with row and db" do
        expect(lookup).to have_received(:call_method).with(row, db_double)
      end
    end

    context "when the database is closed" do
      before do
        allow(adapter_double).to receive(:db).and_return(nil)
        lookup.process(row)
      end

      it "opens the database" do
        expect(adapter_double).to have_received(:open!)
      end
    end

    context "when there is no matching row" do
      it "returns the row" do
        expect(lookup.process(row)).to eq(row)
      end
    end

    context "when there is a matching row" do
      before do
        allow(lookup).to receive(:call_method).and_return([:match])
        allow(row).to receive(:merge).and_return(:row_with_matched)
      end

      it "merges the row with the mathing row" do
        lookup.process(row)
        expect(row).to have_received(:merge).with(:match)
      end

      it "returns the row merged with matching row" do
        expect(lookup.process(row)).to eq(:row_with_matched)
      end
    end
  end
end
