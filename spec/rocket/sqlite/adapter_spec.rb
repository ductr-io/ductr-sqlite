# frozen_string_literal: true

RSpec.describe Rocket::SQLite::Adapter do
  let(:name) { :my_adapter }
  let(:config) { { hello: :test } }
  let(:adapter) { described_class.new(name, **config) }

  describe "adapter registration" do
    let(:registered) { Rocket.adapter_registry.find_by_type(:sqlite) }

    it "registers as :sqlite" do
      expect { registered }.not_to raise_error
    end

    it "registers the adapter class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#initialize" do
    it "sets the adapter's name" do
      expect(adapter.name).to eq(name)
    end

    it "sets the adapter's configuration" do
      expect(adapter.instance_variable_get(:@config)).to eq(config)
    end
  end

  describe "#open!" do
    let(:db_double) { instance_double(Sequel::Database) }

    before do
      allow(Sequel).to receive(:sqlite).and_return(db_double)
      allow(adapter).to receive(:close!)
    end

    context "without error" do
      it "opens the db with config" do
        adapter.open!
        expect(Sequel).to have_received(:sqlite).with(**config)
      end

      it "returns the db instance" do
        expect(adapter.open!).to eq(db_double)
      end

      it "sets the @db instance var" do
        adapter.open!
        expect(adapter.instance_variable_get(:@db)).to eq(db_double)
      end
    end
  end

  describe "#close!" do
    before do
      adapter.instance_variable_set(:@db, 42)
      adapter.close!
    end

    it "destroys the db instance" do
      expect(adapter.instance_variable_get(:@db)).to be_nil
    end
  end
end
