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
      allow(adapter_double).to receive(:open!).and_return(db_double)
      allow(destination).to receive(:adapter).and_return(adapter_double)
      allow(destination).to receive(:call_method)

      destination.instance_variable_set(:@buffer, buffer)
    end

    context "when the database is opened" do
      before do
        allow(adapter_double).to receive(:db).and_return(db_double)
        destination.on_flush
      end

      it "doesn't open the database" do
        expect(adapter_double).not_to have_received(:open!)
      end

      it "calls the job method with buffer and db" do
        expect(destination).to have_received(:call_method).with(buffer, db_double)
      end
    end

    context "when the database is closed" do
      before do
        allow(adapter_double).to receive(:db).and_return(nil)
        destination.on_flush
      end

      it "opens the database" do
        expect(adapter_double).to have_received(:open!)
      end
    end
  end
end
