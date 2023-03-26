# frozen_string_literal: true

RSpec.describe Ductr::SQLite::BufferedDestination do
  let(:destination) { described_class.new("dummy_context", :dummy_method) }
  let(:adapter_double) { instance_double(Ductr::SQLite::Adapter) }

  describe "control registration" do
    let(:registered) { Ductr::SQLite::Adapter.destination_registry.find(:buffered) }

    it "registers as :buffered" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#on_flush" do
    let(:db_double) { instance_double(Sequel::Database) }
    let(:buffer) { [:buffer] }

    before do
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(destination).to receive(:adapter).and_return(adapter_double)
      allow(destination).to receive(:call_method)

      destination.instance_variable_set(:@buffer, buffer)

      destination.on_flush
    end

    it "calls the job method with buffer and db" do
      expect(destination).to have_received(:call_method).with(db_double, buffer)
    end
  end
end
