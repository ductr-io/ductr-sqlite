# frozen_string_literal: true

RSpec.describe Ductr::SQLite::BasicDestination do
  let(:destination) { described_class.new("dummy_context", :dummy_method) }
  let(:adapter_double) { instance_double(Ductr::SQLite::Adapter) }

  describe "control registration" do
    let(:registered) { Ductr::SQLite::Adapter.destination_registry.find(:basic) }

    it "registers as :basic" do
      expect(registered).not_to be_nil
    end

    it "registers the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#write" do
    let(:db_double) { instance_double(Sequel::Database) }
    let(:row) { instance_double(Hash) }

    before do
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(destination).to receive(:adapter).and_return(adapter_double)
      allow(destination).to receive(:call_method)

      destination.write(row)
    end

    it "calls the job method with row and db" do
      expect(destination).to have_received(:call_method).with(db_double, row)
    end
  end
end
