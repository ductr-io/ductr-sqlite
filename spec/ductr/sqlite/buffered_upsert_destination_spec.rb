# frozen_string_literal: true

RSpec.describe Ductr::SQLite::BufferedUpsertDestination do
  let(:destination) { described_class.new("dummy_context", :dummy_method) }
  let(:adapter_double) { instance_double(Ductr::SQLite::Adapter) }

  describe "control registration" do
    let(:registered) { Ductr::SQLite::Adapter.destination_registry.find(:buffered_upsert) }

    it "registers as :buffered_upsert" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#on_flush" do
    let(:db_double) { instance_double(Sequel::Database) }
    let(:dummy_excluded) { { a: :a_excluded } }
    let(:buffer) { [{ a: :b }] }

    before do
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(destination).to receive(:adapter).and_return(adapter_double)
      allow(destination).to receive(:excluded).and_return(dummy_excluded)
      allow(destination).to receive(:call_method)

      destination.instance_variable_set(:@buffer, buffer)

      destination.on_flush
    end

    it "calls the job method with buffer, excluded hash and db" do
      expect(destination).to have_received(:call_method).with(db_double, dummy_excluded, buffer)
    end
  end

  describe "#excluded" do
    let(:buffer) { [{ a: :b }] }

    before do
      destination.instance_variable_set(:@buffer, buffer)
    end

    it "maps keys with qualified identifiers into a hash" do
      expect(destination.send(:excluded)).to eq({ a: Sequel[:excluded][:a] })
    end
  end
end
