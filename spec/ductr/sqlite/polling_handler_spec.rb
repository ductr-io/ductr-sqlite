# frozen_string_literal: true

RSpec.describe Ductr::SQLite::PollingHandler do
  let(:adapter_double) { instance_double(Ductr::SQLite::Adapter) }
  let(:method_double) { instance_double(Method) }
  let(:handler) { described_class.new(method_double, adapter_double) }

  describe "#initialize" do
    it "init method instance variable" do
      expect(handler.instance_variable_get(:@method)).to be(method_double)
    end

    it "init adapter instance variable" do
      expect(handler.instance_variable_get(:@adapter)).to be(adapter_double)
    end

    it "init last_triggering_key instance variable to nil" do
      expect(handler.instance_variable_get(:@last_triggering_key)).to be_nil
    end
  end

  describe "#call" do
    let(:db_double) { instance_double(Sequel::Database) }

    before do
      allow(adapter_double).to receive(:open).and_yield(db_double)
    end

    context "when triggering_key and last_triggering_key are equal" do
      before do
        allow(method_double).to receive(:call).and_yield(nil)
      end

      it "returns false" do
        expect(handler.call).to be(false)
      end
    end

    context "when triggering_key and last_triggering_key are different" do
      before do
        allow(method_double).to receive(:call).and_yield(:different)
      end

      it "sets last_triggering_key to the yielded value" do
        handler.call
        expect(handler.instance_variable_get(:@last_triggering_key)).to be(:different)
      end

      it "returns true" do
        expect(handler.call).to be(true)
      end
    end
  end
end
